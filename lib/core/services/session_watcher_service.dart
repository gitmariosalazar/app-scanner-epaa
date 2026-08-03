import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/core/network/jwt_utils.dart';
import 'package:flutter_application/core/network/refresh_exceptions.dart';
import 'package:flutter_application/core/network/session_event_bus.dart';
import 'package:flutter_application/core/network/token_refresh_coordinator.dart';

/// Watches the active session's lifetime: proactively renews the access
/// token shortly before it expires, and treats a long backgrounded period
/// (app paused/minimized) as the mobile equivalent of "user went idle".
///
/// Single responsibility: session lifetime monitoring only. It has no
/// knowledge of Cubits or widgets — it only reports through
/// [SessionEventBus], keeping `core` decoupled from `presentation`.
class SessionWatcherService with WidgetsBindingObserver {
  final TokenRefreshCoordinator _coordinator;
  final SessionEventBus _sessionEventBus;

  /// Fire the proactive refresh this long before the access token expires.
  static const Duration refreshBuffer = Duration(seconds: 30);

  /// How long the app may sit backgrounded before the session is treated
  /// as idle-timed-out (mirrors MAX_IDLE_TIME_MS in the web frontends).
  static const Duration maxBackgroundIdleTime = Duration(minutes: 15);

  /// Retry delay when a proactive refresh fails purely due to connectivity.
  static const Duration networkRetryDelay = Duration(seconds: 30);

  Timer? _refreshTimer;
  DateTime? _backgroundedAt;
  bool _isObserving = false;

  SessionWatcherService({
    required TokenRefreshCoordinator coordinator,
    required SessionEventBus sessionEventBus,
  }) : _coordinator = coordinator,
       _sessionEventBus = sessionEventBus;

  /// Starts monitoring for the given (freshly issued) access token.
  /// Safe to call repeatedly — cancels any previously scheduled timer.
  void start(String accessToken) {
    if (!_isObserving) {
      WidgetsBinding.instance.addObserver(this);
      _isObserving = true;
    }
    _scheduleRefresh(accessToken);
  }

  /// Stops all monitoring. Call on logout.
  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _backgroundedAt = null;
    if (_isObserving) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserving = false;
    }
  }

  void _scheduleRefresh(String accessToken) {
    _refreshTimer?.cancel();

    final expMs = JwtUtils.getExpirationMs(accessToken);
    if (expMs == null) return; // no `exp` claim — nothing to schedule

    final delay =
        Duration(milliseconds: expMs - DateTime.now().millisecondsSinceEpoch) -
        refreshBuffer;

    if (delay.isNegative) {
      _attemptSilentRefresh();
      return;
    }
    _refreshTimer = Timer(delay, _attemptSilentRefresh);
  }

  Future<void> _attemptSilentRefresh() async {
    try {
      final session = await _coordinator.refresh();
      _scheduleRefresh(session.accessToken);
    } on AuthSessionExpiredException {
      _sessionEventBus.emitExpired();
    } on NetworkRefreshException {
      // Offline — keep trying instead of forcing a logout.
      _refreshTimer = Timer(networkRetryDelay, _attemptSilentRefresh);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt != null &&
        DateTime.now().difference(backgroundedAt) > maxBackgroundIdleTime) {
      _sessionEventBus.emitExpired();
    }
  }
}
