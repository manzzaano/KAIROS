class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const tunnel = '/tunnel';
  static const focus = '/focus';
  static const confessional = '/confessional';
  static const settings = '/settings';
  static const create = '/create';
  static const stats = '/stats';
  static const geofence = '/geofence';
}

class Timings {
  static const splashDelay = Duration(milliseconds: 2000);
  static const fadeIn = Duration(milliseconds: 600);
  static const pageTransition = Duration(milliseconds: 320);
  static const focusMinutes = 90;
  static const tick = Duration(seconds: 1);
  static const typingPulse = Duration(milliseconds: 900);
}
