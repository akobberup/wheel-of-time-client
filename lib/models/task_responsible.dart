import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_responsible.freezed.dart';
part 'task_responsible.g.dart';

/// Strategi for tildeling af ansvar på en task.
enum ResponsibleStrategy {
  /// Alle medlemmer er ansvarlige (default)
  @JsonValue('ALL')
  all,

  /// Én bestemt person er altid ansvarlig
  @JsonValue('FIXED_PERSON')
  fixedPerson,

  /// Ansvaret roterer mellem udvalgte personer
  @JsonValue('ROUND_ROBIN')
  roundRobin,
}

/// Response DTO for en enkelt ansvarlig bruger på en task.
@freezed
class TaskResponsibleResponse with _$TaskResponsibleResponse {
  const factory TaskResponsibleResponse({
    /// TaskResponsible entitetens unikke ID.
    required int id,

    /// Brugerens unikke ID.
    required int userId,

    /// Brugerens visningsnavn.
    required String userName,

    /// Brugerens email-adresse.
    required String userEmail,

    /// Placering i rotationsrækkefølgen (0-baseret).
    required int sortOrder,
  }) = _TaskResponsibleResponse;

  factory TaskResponsibleResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponsibleResponseFromJson(json);
}

/// Response DTO for ansvarlig-konfiguration på en task.
@freezed
class TaskResponsibleConfigResponse with _$TaskResponsibleConfigResponse {
  const factory TaskResponsibleConfigResponse({
    /// Konfigurationens unikke ID.
    required int id,

    /// ID på den tilknyttede task.
    required int taskId,

    /// Strategi for tildeling af ansvarlige.
    required ResponsibleStrategy strategy,

    /// Nuværende rotationsindex ved ROUND_ROBIN strategi.
    int? currentRotationIndex,

    /// Liste af ansvarlige brugere i rotationsrækkefølge.
    @Default([]) List<TaskResponsibleResponse> responsibles,
  }) = _TaskResponsibleConfigResponse;

  factory TaskResponsibleConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponsibleConfigResponseFromJson(json);
}

/// Request DTO til konfiguration af ansvarlige på en task.
@freezed
class TaskResponsibleConfigRequest with _$TaskResponsibleConfigRequest {
  const factory TaskResponsibleConfigRequest({
    /// Strategi for tildeling af ansvarlige.
    required ResponsibleStrategy strategy,

    /// Liste af bruger-IDs der er ansvarlige for opgaven.
    /// Rækkefølgen afgør rotationsordenen ved ROUND_ROBIN strategi.
    @Default([]) List<int> responsibleUserIds,
  }) = _TaskResponsibleConfigRequest;

  factory TaskResponsibleConfigRequest.fromJson(Map<String, dynamic> json) =>
      _$TaskResponsibleConfigRequestFromJson(json);
}
