import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/log_entry.dart';

/// Persistent kø til client-logs med retry.
///
/// WARNING- og ERROR-logs lægges i en disk-baseret kø (SharedPreferences) før
/// de sendes til backend. Fejler afsendelsen (fx fordi backenden er nede under
/// en deploy) bliver de liggende og sendes ved næste flush. Dermed forsvinder
/// fejl ikke længere bare fordi de opstod mens serveren var utilgængelig.
///
/// Dette er det ENESTE sted der rører netværket for logs. Fejl i selve
/// afsendelsen logges KUN lokalt (developer.log) - aldrig tilbage i køen - så vi
/// undgår den selv-rekursion der ellers ville opstå når "serveren er nede".
class LogQueueService {
  final http.Client _client;
  final Future<SharedPreferences> Function() _prefsProvider;

  /// Nøgle hvorunder den ventende kø persisteres.
  static const String storageKey = 'pending_client_logs';

  /// Maksimalt antal entries i køen. Ældste droppes ved overløb (FIFO).
  static const int maxEntries = 200;

  /// Timeout for et enkelt log-POST.
  static const Duration sendTimeout = Duration(seconds: 5);

  /// Forhindrer at to flush kører samtidig (dobbeltsending / race).
  bool _flushing = false;

  LogQueueService({
    http.Client? client,
    Future<SharedPreferences> Function()? prefsProvider,
  })  : _client = client ?? http.Client(),
        _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  /// Lægger en log i den persistente kø og forsøger derefter et flush i
  /// baggrunden. Persisteringen afventes, så loggen er på disk når metoden
  /// returnerer; selve afsendelsen blokerer ikke kalderen.
  Future<void> enqueue(LogEntry entry) async {
    try {
      final prefs = await _prefsProvider();
      final list = _read(prefs);
      list.add(jsonEncode(entry.toJson()));

      // Hold køen bounded - drop de ældste hvis vi løber over.
      while (list.length > maxEntries) {
        list.removeAt(0);
      }

      await prefs.setStringList(storageKey, list);
    } catch (e) {
      // Kan ikke persistere - giv ikke op med en log-storm, bare noter lokalt.
      developer.log('LogQueue enqueue fejlede: $e', name: 'LogQueue');
      return;
    }

    unawaited(flush());
  }

  /// Sender en log med det samme uden at persistere (fire-and-forget).
  ///
  /// Bruges til INFO/DEBUG/analytics hvor tab ved nedetid er ligegyldigt.
  void sendImmediate(LogEntry entry) {
    unawaited(_sendOne(jsonEncode(entry.toJson())));
  }

  /// Tømmer køen mod backend. Sender ældste-først; ved første fejl stoppes der
  /// og resten bevares (rækkefølge bibeholdes, og en død server hamres ikke).
  Future<void> flush() async {
    if (_flushing) {
      return;
    }
    _flushing = true;
    try {
      final prefs = await _prefsProvider();

      while (true) {
        final list = _read(prefs);
        if (list.isEmpty) {
          break;
        }

        final raw = list.first;
        final ok = await _sendOne(raw);
        if (!ok) {
          // Stop ved første fejl - behold denne og resten til næste flush.
          break;
        }

        // Re-læs efter afsendelsen: enqueue kan have appended nye entries
        // under await'et. Vi fjerner kun den forreste (den vi netop sendte).
        final current = _read(prefs);
        if (current.isNotEmpty && current.first == raw) {
          current.removeAt(0);
          await prefs.setStringList(storageKey, current);
        } else {
          // Køen ændrede sig uventet under os - stop for at undgå at slette
          // forkert. Næste flush rydder op.
          break;
        }
      }
    } catch (e) {
      developer.log('LogQueue flush fejlede: $e', name: 'LogQueue');
    } finally {
      _flushing = false;
    }
  }

  /// Sender ét rå JSON-encoded log entry. Returnerer true ved succes.
  /// Fejl/timeout fanges og rapporteres KUN lokalt (ingen rekursion).
  Future<bool> _sendOne(String rawJson) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/logs'),
            headers: {'Content-Type': 'application/json'},
            body: rawJson,
          )
          .timeout(
            sendTimeout,
            onTimeout: () => http.Response('Timeout', 408),
          );

      if (response.statusCode >= 400) {
        developer.log(
          'LogQueue: backend svarede ${response.statusCode}',
          name: 'LogQueue',
        );
        return false;
      }
      return true;
    } catch (e) {
      developer.log('LogQueue: afsendelse fejlede: $e', name: 'LogQueue');
      return false;
    }
  }

  /// Læser køen som en mutérbar liste (tom liste hvis intet er gemt).
  List<String> _read(SharedPreferences prefs) {
    return prefs.getStringList(storageKey)?.toList() ?? <String>[];
  }

  void dispose() {
    _client.close();
  }
}
