/// Konfiguration af app-version
///
/// Versionen injiceres ved build-tid fra git commit SHA
class VersionConfig {
  /// Git commit SHA - injiceres ved build-tid via --dart-define
  static const String version = String.fromEnvironment(
    'BUILD_VERSION',
    defaultValue: 'development',
  );

  /// Returnerer kort version (første 8 tegn af SHA)
  static String get shortVersion {
    return version.length > 8 ? version.substring(0, 8) : version;
  }

  /// Returnerer fuld version info til visning
  static String get displayVersion {
    return 'v$shortVersion';
  }
}
