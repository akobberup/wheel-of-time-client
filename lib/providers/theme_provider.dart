import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// Fejlkoder for tema-relaterede fejl.
/// UI-laget kan bruge disse til at vise lokaliserede fejlbeskeder.
enum ThemeErrorCode {
  loadSettings,
  saveColor,
  saveDarkMode,
}

/// Repræsenterer appens tema tilstand med farve og mørk tilstand præferencer.
/// Håndterer både Material 3 ColorScheme generation og synkronisering med backend.
class ThemeState {
  final Color seedColor;
  final bool isDarkMode;
  final bool isLoading;
  final ThemeErrorCode? errorCode;

  ThemeState({
    this.seedColor = const Color(0xFF6750A4), // Standard lilla
    this.isDarkMode = false,
    this.isLoading = false,
    this.errorCode,
  });

  /// Genererer Material 3 lyst tema fra seed color
  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  /// Genererer Material 3 mørkt tema fra seed color
  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

  /// Returnerer det aktuelle tema baseret på isDarkMode
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  ThemeState copyWith({
    Color? seedColor,
    bool? isDarkMode,
    bool? isLoading,
    ThemeErrorCode? errorCode,
  }) {
    return ThemeState(
      seedColor: seedColor ?? this.seedColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode,
    );
  }
}

/// StateNotifier der håndterer tema tilstand og synkronisering med backend.
/// Indlæser brugerens tema præferencer ved opstart og opdaterer både lokalt og på serveren.
class ThemeNotifier extends StateNotifier<ThemeState> {
  final ApiService _apiService;

  ThemeNotifier(
    this._apiService,
  ) : super(ThemeState()) {
    _loadThemeSettings();
  }

  /// Indlæser tema indstillinger fra backend ved app start.
  /// Falder tilbage til standard indstillinger hvis indlæsning fejler.
  /// Tjekker først om brugeren er autentificeret for at undgå 401 fejl.
  Future<void> _loadThemeSettings() async {
    developer.log('🎨 Loading theme settings...', name: 'ThemeProvider');
    state = state.copyWith(isLoading: true);

    try {
      // Tjek om brugeren er logget ind før API kald
      final isAuthenticated = await _apiService.validateToken();
      if (!isAuthenticated) {
        developer.log('⏳ User not authenticated, skipping theme load from server', name: 'ThemeProvider');
        state = state.copyWith(isLoading: false);
        return;
      }

      final settings = await _apiService.getUserSettings();
      developer.log('✅ Theme settings loaded: ${settings.mainThemeColor}, dark: ${settings.darkModeEnabled}', name: 'ThemeProvider');

      state = state.copyWith(
        seedColor: settings.themeColor,
        isDarkMode: settings.darkModeEnabled,
        isLoading: false,
      );
    } catch (e) {
      developer.log('⚠️ Failed to load theme settings, using defaults: $e', name: 'ThemeProvider');
      // Brug standard værdier hvis indlæsning fejler
      state = state.copyWith(
        isLoading: false,
        errorCode: ThemeErrorCode.loadSettings,
      );
    }
  }

  /// Opdaterer tema farve og synkroniserer med backend.
  /// Opdaterer UI øjeblikkeligt og sender til backend asynkront.
  Future<void> updateThemeColor(Color newColor) async {
    developer.log('🎨 Updating theme color to: ${newColor.toHex()}', name: 'ThemeProvider');

    // Opdater UI øjeblikkeligt for responsiv oplevelse
    state = state.copyWith(seedColor: newColor);

    // Synkroniser med backend asynkront
    try {
      final request = UpdateUserSettingsRequest(
        mainThemeColor: newColor.toHex(),
      );
      await _apiService.updateUserSettings(request);
      developer.log('✅ Theme color synced to backend', name: 'ThemeProvider');
    } catch (e) {
      developer.log('⚠️ Failed to sync theme color: $e', name: 'ThemeProvider');
      state = state.copyWith(errorCode: ThemeErrorCode.saveColor);
    }
  }

  /// Skifter mellem lys og mørk tilstand og synkroniserer med backend.
  Future<void> toggleDarkMode() async {
    final newDarkMode = !state.isDarkMode;
    developer.log('🌓 Toggling dark mode to: $newDarkMode', name: 'ThemeProvider');

    // Opdater UI øjeblikkeligt
    state = state.copyWith(isDarkMode: newDarkMode);

    // Synkroniser med backend asynkront
    try {
      final request = UpdateUserSettingsRequest(
        darkModeEnabled: newDarkMode,
      );
      await _apiService.updateUserSettings(request);
      developer.log('✅ Dark mode synced to backend', name: 'ThemeProvider');
    } catch (e) {
      developer.log('⚠️ Failed to sync dark mode: $e', name: 'ThemeProvider');
      state = state.copyWith(errorCode: ThemeErrorCode.saveDarkMode);
    }
  }

  /// Genindlæser tema indstillinger fra backend.
  /// Nyttigt efter login eller for at synkronisere ændringer fra andre enheder.
  Future<void> refreshThemeSettings() async {
    await _loadThemeSettings();
  }
}

/// Provider til tema management.
/// Bruges til at få adgang til tema tilstand og funktioner i hele appen.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ThemeNotifier(apiService);
});

/// Preset farver til Material 3 tema valg.
/// Disse farver er valgt for god kontrast og Material You compliance.
const List<Color> presetThemeColors = [
  Color(0xFF6750A4), // Purple (standard)
  Color(0xFF1976D2), // Blue
  Color(0xFF00897B), // Teal
  Color(0xFF43A047), // Green
  Color(0xFFF57C00), // Orange
  Color(0xFFE53935), // Red
  Color(0xFFD81B60), // Pink
  Color(0xFF8E24AA), // Deep Purple
  Color(0xFF3949AB), // Indigo
  Color(0xFF00ACC1), // Cyan
  Color(0xFF7CB342), // Light Green
  Color(0xFFFDD835), // Yellow
];
