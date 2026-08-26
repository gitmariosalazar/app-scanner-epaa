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

  /// How long the app may stay backgrounded without network before the session
  /// is treated as idle-timed-out. Field workers often pocket their phone for
  /// extended periods — 4 h gives a full shift without interruption.
  static const Duration maxBackgroundIdleTime = Duration(hours: 4);

  /// Retry delay when a proactive refresh fails purely due to connectivity.
  static const Duration networkRetryDelay = Duration(seconds: 30);

  Timer? _refreshTimer;
  DateTime? _backgroundedAt;
  /// Tracks the last time the user interacted with the app (pointer event).
  /// Used to measure true idle time rather than just backgrounded time.
  DateTime? _lastActivityAt;
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

  /// Call this whenever the user interacts with the app (tap, scroll, etc.).
  /// Resets the idle clock so a brief background period after activity is not
  /// counted against the user.
  void recordUserActivity() {
    _lastActivityAt = DateTime.now();
  }

  /// Stops all monitoring. Call on logout.
  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _backgroundedAt = null;
    _lastActivityAt = null;
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

  /// Attempt a refresh specifically triggered by the app coming to the
  /// foreground. If the network is unavailable AND the user has been idle
  /// longer than [maxBackgroundIdleTime], the session is treated as expired.
  /// Otherwise the app continues with the current (possibly still-valid) token.
  Future<void> _attemptRefreshOnResume({
    required bool expireOnNetworkFailure,
  }) async {
    try {
      final session = await _coordinator.refresh();
      // Got a fresh pair of tokens — reschedule the proactive timer.
      _scheduleRefresh(session.accessToken);
    } on AuthSessionExpiredException {
      // Refresh token itself is gone — must re-login.
      _sessionEventBus.emitExpired();
    } on NetworkRefreshException {
      // No internet on resume.
      if (expireOnNetworkFailure) {
        // Idle too long AND no network to verify → expire for security.
        _sessionEventBus.emitExpired();
      }
      // else: short background + no network → keep going with current token.
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

    // Measure idle from the last recorded user activity (most accurate) or
    // from the moment the app was backgrounded (conservative fallback).
    final idleStart = _lastActivityAt != null &&
            backgroundedAt != null &&
            _lastActivityAt!.isAfter(backgroundedAt)
        ? _lastActivityAt
        : backgroundedAt;

    final wasIdleTooLong = idleStart != null &&
        DateTime.now().difference(idleStart) > maxBackgroundIdleTime;

    // Always refresh on resume — keeps the token fresh every time the user
    // opens the app, even after a short background period.
    _attemptRefreshOnResume(expireOnNetworkFailure: wasIdleTooLong);
  }
}
