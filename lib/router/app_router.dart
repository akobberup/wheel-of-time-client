// Router konfiguration til Wheel of Time app
// Bruger GoRouter for korrekt browser historik-integration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/login_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/task_list_detail_screen.dart';
import '../screens/task_list_members_screen.dart';
import '../screens/task_history_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/legal_info_screen.dart';
import '../screens/documentation_screen.dart';

/// Provider til GoRouter instansen
/// Lytter på auth state for at håndtere redirects
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Redirect baseret på auth state
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final currentPath = state.uri.path;

      // Vent på auth loading
      if (isLoading) return null;

      // Offentlige ruter der ikke kræver auth
      final publicRoutes = [
        '/login',
        '/forgot-password',
        '/reset-password',
        '/privacy-policy',
        '/security',
        '/support',
        '/account-deletion',
        '/documentation',
      ];
      final isPublicRoute = publicRoutes.any((r) => currentPath.startsWith(r));

      // Redirect til login hvis ikke autentificeret og ikke på offentlig rute
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect til home hvis autentificeret og på login
      if (isAuthenticated && currentPath == '/login') {
        return '/';
      }

      return null;
    },

    routes: [
      // Hovedskærm (bottom navigation)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Glemt adgangskode
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Nulstil adgangskode (med token parameter)
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),

      // Opgaveliste detaljer
      GoRoute(
        path: '/lists/:listId',
        name: 'list-detail',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final listName = state.uri.queryParameters['name'];
          return TaskListDetailScreen(
            taskListId: listId,
            taskListName: listName,
          );
        },
        routes: [
          // Medlemmer af opgaveliste
          GoRoute(
            path: 'members',
            name: 'list-members',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['listId']!);
              final listName = state.uri.queryParameters['name'] ?? '';
              final primaryColorHex = state.uri.queryParameters['primaryColor'];
              final secondaryColorHex = state.uri.queryParameters['secondaryColor'];

              return TaskListMembersScreen(
                taskListId: listId,
                taskListName: listName,
                primaryColor: primaryColorHex != null ? _parseHexColor(primaryColorHex) : null,
                secondaryColor: secondaryColorHex != null ? _parseHexColor(secondaryColorHex) : null,
              );
            },
          ),
          // Opgave historik
          GoRoute(
            path: 'tasks/:taskId',
            name: 'task-history',
            builder: (context, state) {
              final taskId = int.parse(state.pathParameters['taskId']!);
              final taskName = state.uri.queryParameters['name'] ?? '';
              final primaryColorHex = state.uri.queryParameters['primaryColor'];
              final secondaryColorHex = state.uri.queryParameters['secondaryColor'];
              return TaskHistoryScreen(
                taskId: taskId,
                taskName: taskName,
                primaryColor: primaryColorHex != null ? Color(int.parse(primaryColorHex, radix: 16)) : null,
                secondaryColor: secondaryColorHex != null ? Color(int.parse(secondaryColorHex, radix: 16)) : null,
              );
            },
          ),
        ],
      ),

      // Notifikationer
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Indstillinger
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Profil
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Privatlivspolitik
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LegalInfoScreen(type: LegalInfoType.privacyPolicy),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Sikkerhed
      GoRoute(
        path: '/security',
        name: 'security',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LegalInfoScreen(type: LegalInfoType.security),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Support
      GoRoute(
        path: '/support',
        name: 'support',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LegalInfoScreen(type: LegalInfoType.support),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Sletning af konto
      GoRoute(
        path: '/account-deletion',
        name: 'account-deletion',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LegalInfoScreen(type: LegalInfoType.accountDeletion),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Dokumentation
      GoRoute(
        path: '/documentation',
        name: 'documentation',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DocumentationScreen(),
          transitionsBuilder: _fadeSlideTransition,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
    ],
  );
});

/// Parser hex color string til Color objekt
Color? _parseHexColor(String hexString) {
  try {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF');
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 6) {
      buffer.write('FF');
      buffer.write(hexString);
    } else {
      return null;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e) {
    return null;
  }
}

/// Custom fade + slide transition som bruges i design guidelines
Widget _fadeSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(0.0, 0.02);
  const end = Offset.zero;
  const curve = Curves.easeInOutCubic;

  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  final offsetAnimation = animation.drive(tween);

  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: offsetAnimation,
      child: child,
    ),
  );
}
