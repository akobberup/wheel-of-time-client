import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'invitation.freezed.dart';
part 'invitation.g.dart';

@freezed
class InvitationResponse with _$InvitationResponse {
  const factory InvitationResponse({
    required int id,
    required int taskListId,
    required String taskListName,
    required String emailAddress,
    required int initiatedByUserId,
    required String initiatedByUserName,
    required InvitationState currentState,
    required DateTime currentStateDate,
  }) = _InvitationResponse;

  factory InvitationResponse.fromJson(Map<String, dynamic> json) =>
      _$InvitationResponseFromJson(json);
}

@freezed
class CreateInvitationRequest with _$CreateInvitationRequest {
  const factory CreateInvitationRequest({
    required int taskListId,
    required String emailAddress,
  }) = _CreateInvitationRequest;

  factory CreateInvitationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvitationRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'taskListId': taskListId,
        'emailAddress': emailAddress,
      };
}
