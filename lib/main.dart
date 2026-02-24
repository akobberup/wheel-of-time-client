import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/remote_logger_provider.dart';
import 'providers/cheer_provider.dart';
import 'providers/fcm_provider.dart';
import 'router/app_router.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Brug path-baseret URL strategi i stedet for hash-baseret (#)
  // Dette gør at URLs som /reset-password?token=... fungerer korrekt
  usePathUrlStrategy();

  // Initialiser Firebase og FCM for push notifications (kun mobile)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FcmService().initialize();
  }

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
      child: const AarshjuletApp(),
    ),
  );
}

class AarshjuletApp extends ConsumerStatefulWidget {
  const AarshjuletApp({super.key});

  @override
  ConsumerState<AarshjuletApp> createState() => _AarshjuletAppState();
}

class _AarshjuletAppState extends ConsumerState<AarshjuletApp> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // Initialiser FCM provider så den lytter til auth state ændringer
    // Dette sikrer at FCM token registreres ved login og afregistreres ved logout
    if (!kIsWeb) {
      ref.watch(fcmProvider);

      // Lyt til notification navigation events
      ref.listen<PendingNotificationNavigation?>(
        notificationNavigationProvider,
        (previous, next) {
          if (next != null) {
            _handleNotificationNavigation(next, router);
          }
        },
      );
    }

    return MaterialApp.router(
      title: 'Årshjulet',
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

  /// Håndterer navigation fra notification tap.
  void _handleNotificationNavigation(PendingNotificationNavigation navigation, GoRouter router) {
    debugPrint('FCM: Håndterer notification navigation: type=${navigation.type}');

    // For TASK_COMPLETED_BY_OTHER: sæt pending cheer så CheerBottomSheet åbnes
    if (navigation.type == 'TASK_COMPLETED_BY_OTHER' && navigation.taskInstanceId != null) {
      ref.read(pendingCheerProvider.notifier).state = navigation.taskInstanceId;
    }

    final route = navigation.getNavigationRoute();
    if (route != null) {
      debugPrint('FCM: Navigerer til: $route');

      // Brug en kort delay for at sikre at app'en er klar
      Future.delayed(const Duration(milliseconds: 100), () {
        router.go(route);
      });
    }

    // Ryd pending navigation
    ref.read(notificationNavigationProvider.notifier).clearPendingNavigation();
  }
}
