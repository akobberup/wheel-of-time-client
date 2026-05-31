import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarshjulet/models/log_entry.dart';
import 'package:aarshjulet/services/log_queue_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  const storageKey = LogQueueService.storageKey;

  late MockHttpClient client;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    client = MockHttpClient();
  });

  LogEntry entry(String message) => LogEntry(
        level: LogLevel.error,
        message: message,
        timestamp: '2026-05-31T10:00:00.000Z',
        clientVersion: '1.0.0',
      );

  String encoded(String message) => jsonEncode(entry(message).toJson());

  /// Opsætter http-klienten til at svare med en sekvens af status-koder.
  /// Når sekvensen er opbrugt, genbruges den sidste kode.
  void stubResponses(List<int> statusCodes) {
    var call = 0;
    when(() => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer((_) async {
      final code =
          call < statusCodes.length ? statusCodes[call] : statusCodes.last;
      call++;
      return http.Response('', code);
    });
  }

  LogQueueService buildService() => LogQueueService(client: client);

  test('enqueue persisterer entry når afsendelse fejler', () async {
    SharedPreferences.setMockInitialValues({});
    stubResponses([500]); // backend nede
    final service = buildService();

    await service.enqueue(entry('boom'));
    // Lad det baggrunds-flush, som enqueue starter, køre færdigt.
    await service.flush();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(storageKey) ?? [];
    expect(stored, [encoded('boom')]);
  });

  test('enqueue sender og tømmer køen ved succes', () async {
    SharedPreferences.setMockInitialValues({});
    stubResponses([200]);
    final service = buildService();

    await service.enqueue(entry('ok'));
    await service.flush();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(storageKey) ?? [], isEmpty);
  });

  test('flush bevarer entries og rækkefølge ved partiel fejl', () async {
    SharedPreferences.setMockInitialValues({
      storageKey: [encoded('a'), encoded('b'), encoded('c')],
    });
    // Første lykkes, anden fejler -> stop med b og c tilbage.
    stubResponses([200, 500]);
    final service = buildService();

    await service.flush();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(storageKey) ?? [];
    expect(stored, [encoded('b'), encoded('c')]);
  });

  test('flush stopper ved første fejl uden at sende resten', () async {
    SharedPreferences.setMockInitialValues({
      storageKey: [encoded('a'), encoded('b'), encoded('c')],
    });
    stubResponses([500]);
    final service = buildService();

    await service.flush();

    // Kun ét forsøg (på den forreste), resten røres ikke.
    verify(() => client.post(any(),
        headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(storageKey), hasLength(3));
  });

  test('køen er bounded og dropper de ældste ved overløb', () async {
    // Fyld op til loftet, backend nede så intet fjernes ved flush.
    final initial =
        List.generate(LogQueueService.maxEntries, (i) => encoded('old$i'));
    SharedPreferences.setMockInitialValues({storageKey: initial});
    stubResponses([500]);
    final service = buildService();

    await service.enqueue(entry('newest'));
    await service.flush();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(storageKey) ?? [];
    expect(stored, hasLength(LogQueueService.maxEntries));
    // Ældste (old0) er droppet, nyeste er bagest.
    expect(stored.contains(encoded('old0')), isFalse);
    expect(stored.last, encoded('newest'));
  });

  test('fejlende flush genererer ikke nye kø-entries (ingen rekursion)',
      () async {
    SharedPreferences.setMockInitialValues({
      storageKey: [encoded('a')],
    });
    stubResponses([500]);
    final service = buildService();

    await service.flush();

    final prefs = await SharedPreferences.getInstance();
    // Stadig præcis 1 - en fejl må ikke logge sig selv tilbage i køen.
    expect(prefs.getStringList(storageKey), hasLength(1));
  });
}
