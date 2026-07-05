import 'package:freezed_annotation/freezed_annotation.dart';

part 'vacation_period.freezed.dart';
part 'vacation_period.g.dart';

/// En brugers ferieperiode (feriekalender).
@freezed
class VacationPeriodResponse with _$VacationPeriodResponse {
  const factory VacationPeriodResponse({
    required int id,
    required int userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) = _VacationPeriodResponse;

  factory VacationPeriodResponse.fromJson(Map<String, dynamic> json) =>
      _$VacationPeriodResponseFromJson(json);
}

/// Request til oprettelse af en ferieperiode.
@freezed
class CreateVacationPeriodRequest with _$CreateVacationPeriodRequest {
  const factory CreateVacationPeriodRequest({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) = _CreateVacationPeriodRequest;

  factory CreateVacationPeriodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVacationPeriodRequestFromJson(json);
}

/// Request til partial update af en ferieperiode. Kun ikke-null felter sendes.
@freezed
class UpdateVacationPeriodRequest with _$UpdateVacationPeriodRequest {
  const factory UpdateVacationPeriodRequest({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) = _UpdateVacationPeriodRequest;

  factory UpdateVacationPeriodRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateVacationPeriodRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };
}
