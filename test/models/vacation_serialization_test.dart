import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aarshjulet/models/enums.dart';
import 'package:aarshjulet/models/task.dart';
import 'package:aarshjulet/models/vacation_period.dart';

void main() {
  group('VacationMode enum', () {
    test('toJson/fromJson matcher server-navne', () {
      expect(VacationMode.NO_CHANGE.toJson(), 'NO_CHANGE');
      expect(VacationMode.ONLY_IN_VACATION.toJson(), 'ONLY_IN_VACATION');
      expect(VacationMode.NOT_IN_VACATION.toJson(), 'NOT_IN_VACATION');
      expect(VacationMode.fromJson('NOT_IN_VACATION'),
          VacationMode.NOT_IN_VACATION);
    });
  });

  group('Task vacationMode serialisering', () {
    test('UpdateTaskRequest encoder vacationMode som server-streng', () {
      const request = UpdateTaskRequest(vacationMode: VacationMode.ONLY_IN_VACATION);
      final json = jsonDecode(jsonEncode(request.toJson()));
      expect(json['vacationMode'], 'ONLY_IN_VACATION');
    });

    test('TaskResponse defaulter til NO_CHANGE når feltet mangler', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'taskListId': 1,
        'taskListName': 'Liste',
        'schedule': {
          'type': 'INTERVAL',
          'repeatUnit': 'DAYS',
          'repeatDelta': 1,
          'description': 'Daily',
        },
        'firstRunDate': '2026-07-05',
      };
      final response = TaskResponse.fromJson(json);
      expect(response.vacationMode, VacationMode.NO_CHANGE);
    });

    test('TaskResponse parser vacationMode fra server', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'taskListId': 1,
        'taskListName': 'Liste',
        'schedule': {
          'type': 'INTERVAL',
          'repeatUnit': 'DAYS',
          'repeatDelta': 1,
          'description': 'Daily',
        },
        'firstRunDate': '2026-07-05',
        'vacationMode': 'NOT_IN_VACATION',
      };
      final response = TaskResponse.fromJson(json);
      expect(response.vacationMode, VacationMode.NOT_IN_VACATION);
    });
  });

  group('VacationPeriod serialisering', () {
    test('CreateVacationPeriodRequest sender dato som ISO-streng', () {
      final request = CreateVacationPeriodRequest(
        name: 'Sommerferie',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 14),
      );
      final json = jsonDecode(jsonEncode(request.toJson()));
      expect(json['name'], 'Sommerferie');
      // Server LocalDate accepterer ISO-8601 (samme som firstRunDate)
      expect((json['startDate'] as String).startsWith('2026-07-01'), isTrue);
      expect((json['endDate'] as String).startsWith('2026-07-14'), isTrue);
    });

    test('UpdateVacationPeriodRequest serialiserer angivne felter', () {
      // Bemærk: som resten af kodebasen (UpdateUserSettingsRequest) sender
      // freezeds genererede toJson også null-felter med; serveren ignorerer
      // null ved partial update, så kun de angivne felter opdateres reelt.
      final request = UpdateVacationPeriodRequest(
        name: 'Nyt navn',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 10),
      );
      final json = jsonDecode(jsonEncode(request.toJson()));
      expect(json['name'], 'Nyt navn');
      expect((json['startDate'] as String).startsWith('2026-03-01'), isTrue);
      expect((json['endDate'] as String).startsWith('2026-03-10'), isTrue);
    });

    test('VacationPeriodResponse parser server-svar', () {
      final json = {
        'id': 3,
        'userId': 9,
        'name': 'Vinterferie',
        'startDate': '2026-02-08',
        'endDate': '2026-02-15',
      };
      final response = VacationPeriodResponse.fromJson(json);
      expect(response.id, 3);
      expect(response.userId, 9);
      expect(response.name, 'Vinterferie');
      expect(response.startDate, DateTime(2026, 2, 8));
      expect(response.endDate, DateTime(2026, 2, 15));
    });
  });
}
