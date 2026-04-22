import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_support.freezed.dart';
part 'client_support.g.dart';

enum ClientSupportStatus {
  @JsonValue('OK')
  ok,
  @JsonValue('UPDATE_RECOMMENDED')
  updateRecommended,
  @JsonValue('UPDATE_REQUIRED')
  updateRequired,
}

@freezed
class ClientSupportResponse with _$ClientSupportResponse {
  const factory ClientSupportResponse({
    required ClientSupportStatus status,
    required String currentVersion,
    required String minimumSupportedVersion,
    required String latestVersion,
  }) = _ClientSupportResponse;

  factory ClientSupportResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientSupportResponseFromJson(json);
}
