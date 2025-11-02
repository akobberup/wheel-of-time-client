// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitationResponseImpl _$$InvitationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$InvitationResponseImpl(
      id: (json['id'] as num).toInt(),
      taskListId: (json['taskListId'] as num).toInt(),
      taskListName: json['taskListName'] as String,
      emailAddress: json['emailAddress'] as String,
      initiatedByUserId: (json['initiatedByUserId'] as num).toInt(),
      initiatedByUserName: json['initiatedByUserName'] as String,
      currentState: $enumDecode(_$InvitationStateEnumMap, json['currentState']),
      currentStateDate: DateTime.parse(json['currentStateDate'] as String),
    );

Map<String, dynamic> _$$InvitationResponseImplToJson(
        _$InvitationResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskListId': instance.taskListId,
      'taskListName': instance.taskListName,
      'emailAddress': instance.emailAddress,
      'initiatedByUserId': instance.initiatedByUserId,
      'initiatedByUserName': instance.initiatedByUserName,
      'currentState': instance.currentState,
      'currentStateDate': instance.currentStateDate.toIso8601String(),
    };

const _$InvitationStateEnumMap = {
  InvitationState.PENDING: 'PENDING',
  InvitationState.SENT: 'SENT',
  InvitationState.ACCEPTED: 'ACCEPTED',
  InvitationState.DECLINED: 'DECLINED',
  InvitationState.CANCELLED: 'CANCELLED',
};

_$CreateInvitationRequestImpl _$$CreateInvitationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateInvitationRequestImpl(
      taskListId: (json['taskListId'] as num).toInt(),
      emailAddress: json['emailAddress'] as String,
    );

Map<String, dynamic> _$$CreateInvitationRequestImplToJson(
        _$CreateInvitationRequestImpl instance) =>
    <String, dynamic>{
      'taskListId': instance.taskListId,
      'emailAddress': instance.emailAddress,
    };
