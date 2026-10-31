import 'package:shared_preferences/shared_preferences.dart';

/// Preserves deep-link destinations across SplashScreen and Authentication
/// so when a student clicks a YouTube quiz link while logged out, they are
/// automatically taken to the requested quiz right after logging in.
class PendingDeepLinkService {
  PendingDeepLinkService._();

  static const String _pendingRouteKey = 'v2_pending_deep_link_route';
  static String? _inMemoryPendingRoute;

  static Future<void> setPendingRoute(String routeLocation) async {
    if (routeLocation.isEmpty ||
        routeLocation == '/' ||
        routeLocation.startsWith('/login') ||
        routeLocation.startsWith('/signup')) {
      return;
    }
    _inMemoryPendingRoute = routeLocation;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingRouteKey, routeLocation);
    } catch (_) {}
  }

  static String? peekPendingRouteSync() => _inMemoryPendingRoute;

  static Future<String?> consumePendingRoute() async {
    final mem = _inMemoryPendingRoute;
    _inMemoryPendingRoute = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_pendingRouteKey);
      if (stored != null) {
        await prefs.remove(_pendingRouteKey);
      }
      return mem ?? stored;
    } catch (_) {
      return mem;
    }
  }

  static Future<void> clearPendingRoute() async {
    _inMemoryPendingRoute = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingRouteKey);
    } catch (_) {}
  }
}
