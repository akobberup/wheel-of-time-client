import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/remote_logger_provider.dart';
import 'router/app_router.dart';
import 'services/background_task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Brug path-baseret URL strategi i stedet for hash-baseret (#)
  // Dette gør at URLs som /reset-password?token=... fungerer korrekt
  usePathUrlStrategy();

  // Aktiverer baggrunds-notifikationer på mobile platforme
  // Planlægger periodiske checks hver 30. minut for nye invitationer og forfaldne opgaver
  await BackgroundTaskService.initialize();

  final container = ProviderContainer();
  final logger = container.read(remoteLoggerProvider);

  // Opsæt global error handling for framework-fejl
  // Logger til remote service for debugging i production
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    logger.error(
      details.exceptionAsString(),
      category: 'flutter_error',
      error: details.exception,
      stackTrace: details.stack,
      metadata: {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString(),
      },
    );
  };

  // Fang asynkrone fejl der ikke håndteres af Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error(
      'Uncaught async error',
      category: 'async_error',
      error: error,
      stackTrace: stack,
    );
    return true; // Handled
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WheelOfTimeApp(),
    ),
  );
}

class WheelOfTimeApp extends ConsumerWidget {
  const WheelOfTimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Wheel of Time',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('da', ''), // Danish
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Brug dynamisk tema fra ThemeProvider baseret på brugerens valg
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // GoRouter til korrekt browser historik-håndtering
      routerConfig: router,
    );
  }
}
