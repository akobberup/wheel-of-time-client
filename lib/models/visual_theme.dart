import 'package:freezed_annotation/freezed_annotation.dart';

part 'visual_theme.freezed.dart';
part 'visual_theme.g.dart';

/// Visuelt tema til tasklists med farver til styling.
@freezed
class VisualThemeResponse with _$VisualThemeResponse {
  const factory VisualThemeResponse({
    required int id,
    required String name,
    required String displayName,
    required String primaryColor,
    required String secondaryColor,
  }) = _VisualThemeResponse;

  factory VisualThemeResponse.fromJson(Map<String, dynamic> json) =>
      _$VisualThemeResponseFromJson(json);
}
