import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/remote_logger_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'services/background_task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    return MaterialApp(
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle reset password route with token parameter
        if (settings.name?.startsWith('/reset-password') ?? false) {
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'];
          if (token != null) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            );
          }
        }

        // Handle other routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            );
          case '/forgot-password':
            return MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            );
          default:
            return null;
        }
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return authState.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
