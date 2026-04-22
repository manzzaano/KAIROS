import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/confessional_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/geofence_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_stats_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/task_create_screen.dart';
import 'screens/tunnel_vision_screen.dart';
import 'utils/constants.dart';

CustomTransitionPage<T> _fadePage<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: Timings.pageTransition,
    reverseTransitionDuration: Timings.pageTransition,
    transitionsBuilder: (_, anim, __, w) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(curved),
          child: w,
        ),
      );
    },
  );
}

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggedIn = auth.isAuthenticated;
      final seen = auth.hasSeenOnboarding;

      if (loc == Routes.splash) return null;

      final publicRoutes = {Routes.login, Routes.register};
      if (!loggedIn && !publicRoutes.contains(loc)) return Routes.login;
      if (loggedIn && publicRoutes.contains(loc)) {
        return seen ? Routes.dashboard : Routes.onboarding;
      }
      if (loggedIn && !seen && loc != Routes.onboarding) return Routes.onboarding;
      if (loggedIn && seen && loc == Routes.onboarding) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, pageBuilder: (c, s) => _fadePage(const SplashScreen())),
      GoRoute(path: Routes.login, pageBuilder: (c, s) => _fadePage(const LoginScreen())),
      GoRoute(path: Routes.register, pageBuilder: (c, s) => _fadePage(const RegisterScreen())),
      GoRoute(path: Routes.onboarding, pageBuilder: (c, s) => _fadePage(const OnboardingScreen())),
      GoRoute(path: Routes.dashboard, pageBuilder: (c, s) => _fadePage(const DashboardScreen())),
      GoRoute(path: Routes.tunnel, pageBuilder: (c, s) => _fadePage(const TunnelVisionScreen())),
      GoRoute(path: Routes.focus, pageBuilder: (c, s) => _fadePage(const FocusScreen())),
      GoRoute(path: Routes.confessional, pageBuilder: (c, s) => _fadePage(const ConfessionalScreen())),
      GoRoute(path: Routes.settings, pageBuilder: (c, s) => _fadePage(const SettingsScreen())),
      GoRoute(path: Routes.create, pageBuilder: (c, s) => _fadePage(const TaskCreateScreen())),
      GoRoute(path: Routes.stats, pageBuilder: (c, s) => _fadePage(const ProfileStatsScreen())),
      GoRoute(path: Routes.geofence, pageBuilder: (c, s) => _fadePage(const GeofenceScreen())),
    ],
  );
}
