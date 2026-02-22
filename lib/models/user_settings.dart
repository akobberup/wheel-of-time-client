import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'enums.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Response model for user settings including theme and preferences
@freezed
class UserSettingsResponse with _$UserSettingsResponse {
  const factory UserSettingsResponse({
    required int id,
    required int userId,
    required String mainThemeColor,
    required bool darkModeEnabled,
    // Push notification preferences
    @Default(true) bool pushInvitations,
    @Default(true) bool pushInvitationResponses,
    @Default(true) bool pushTaskReminders,
    @Default(true) bool pushCheers,
    // Personlige oplysninger
    Gender? gender,
    int? birthYear,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserSettingsResponse;

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsResponseFromJson(json);
}

/// Request model for updating user settings (partial updates supported)
@freezed
class UpdateUserSettingsRequest with _$UpdateUserSettingsRequest {
  const factory UpdateUserSettingsRequest({
    String? mainThemeColor,
    bool? darkModeEnabled,
    // Push notification preferences
    bool? pushInvitations,
    bool? pushInvitationResponses,
    bool? pushTaskReminders,
    bool? pushCheers,
    // Personlige oplysninger
    Gender? gender,
    int? birthYear,
  }) = _UpdateUserSettingsRequest;

  factory UpdateUserSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserSettingsRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        if (mainThemeColor != null) 'mainThemeColor': mainThemeColor,
        if (darkModeEnabled != null) 'darkModeEnabled': darkModeEnabled,
        if (pushInvitations != null) 'pushInvitations': pushInvitations,
        if (pushInvitationResponses != null) 'pushInvitationResponses': pushInvitationResponses,
        if (pushTaskReminders != null) 'pushTaskReminders': pushTaskReminders,
        if (pushCheers != null) 'pushCheers': pushCheers,
        if (gender != null) 'gender': gender!.toJson(),
        if (birthYear != null) 'birthYear': birthYear,
      };
}

/// Extension to convert hex color string to Flutter Color
extension UserSettingsColorExtension on UserSettingsResponse {
  Color get themeColor {
    try {
      // Remove # if present and parse hex color
      final hexColor = mainThemeColor.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      // Fallback to purple if parsing fails
      return const Color(0xFF6750A4);
    }
  }
}

/// Extension to convert Color to hex string
extension ColorToHex on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }
}
