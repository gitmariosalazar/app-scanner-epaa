import 'dart:async';

/// Events broadcast about the current session's lifecycle.
enum SessionEvent { expired }

/// Decouples the network/session-monitoring layer from presentation.
///
/// [AuthenticatedHttpClient] and [SessionWatcherService] (infrastructure)
/// publish to this bus; [LoginCubit] (presentation) subscribes to it. Neither
/// side needs a direct reference to the other — satisfies the Dependency
/// Inversion Principle without introducing a presentation dependency into
/// `core/network`.
class SessionEventBus {
  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get events => _controller.stream;

  void emitExpired() => _controller.add(SessionEvent.expired);

  void dispose() => _controller.close();
}
