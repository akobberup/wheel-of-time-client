import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vacation_period.dart';
import 'auth_provider.dart';

/// Provider der håndterer den aktuelle brugers feriekalender (ferieperioder).
class VacationPeriodsNotifier
    extends AsyncNotifier<List<VacationPeriodResponse>> {
  @override
  Future<List<VacationPeriodResponse>> build() async {
    final apiService = ref.read(apiServiceProvider);
    return apiService.getVacationPeriods();
  }

  /// Opretter en ny ferieperiode og genindlæser listen.
  Future<void> addPeriod(CreateVacationPeriodRequest request) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.createVacationPeriod(request);
    await _reload();
  }

  /// Opdaterer en ferieperiode og genindlæser listen.
  Future<void> updatePeriod(int id, UpdateVacationPeriodRequest request) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.updateVacationPeriod(id, request);
    await _reload();
  }

  /// Sletter en ferieperiode og genindlæser listen.
  Future<void> deletePeriod(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.deleteVacationPeriod(id);
    await _reload();
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(() => build());
  }

  /// Genindlæser ferieperioderne fra backend.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for den aktuelle brugers ferieperioder.
final vacationPeriodsProvider = AsyncNotifierProvider<VacationPeriodsNotifier,
    List<VacationPeriodResponse>>(
  VacationPeriodsNotifier.new,
);
