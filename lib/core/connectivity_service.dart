// ─────────────────────────────────────────
// YCT — Connectivity & timeout handling
// ─────────────────────────────────────────
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _conn = Connectivity();

  static Future<bool> isOnline() async {
    final result = await _conn.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  static String friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('timeout') || s.contains('timed out')) {
      return 'Connection timed out. Please check your internet and try again.';
    }
    if (s.contains('socket') || s.contains('network') || s.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (s.contains('permission') || s.contains('unauthorized')) {
      return 'Access denied. Please contact YCT support.';
    }
    if (s.contains('not found') || s.contains('404')) {
      return 'Content not found. It may have been moved or deleted.';
    }
    return 'Something went wrong. Please try again.';
  }
}
