import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak.freezed.dart';
part 'streak.g.dart';

@freezed
class StreakResponse with _$StreakResponse {
  const factory StreakResponse({
    required int id,
    required int taskId,
    required DateTime startDate,
    DateTime? endDate,
    @Default(true) bool isActive,
    @Default(0) int streakCount,
    @Default(0) int instanceCount,
  }) = _StreakResponse;

  factory StreakResponse.fromJson(Map<String, dynamic> json) =>
      _$StreakResponseFromJson(json);
}
