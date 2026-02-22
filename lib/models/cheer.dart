import 'package:freezed_annotation/freezed_annotation.dart';

part 'cheer.freezed.dart';
part 'cheer.g.dart';

/// Model for en cheer-reaktion på en fuldført opgave
@freezed
class CheerResponse with _$CheerResponse {
  const factory CheerResponse({
    required int id,
    required int taskInstanceId,
    required int userId,
    required String userName,
    required String emoji,
    String? message,
    required DateTime createdAt,
  }) = _CheerResponse;

  factory CheerResponse.fromJson(Map<String, dynamic> json) =>
      _$CheerResponseFromJson(json);
}
