import 'package:http/http.dart' as http;
import 'package:flutter_application/core/network/refresh_exceptions.dart';
import 'package:flutter_application/core/network/session_event_bus.dart';
import 'package:flutter_application/core/network/token_refresh_coordinator.dart';

/// Decorates every outgoing request with silent-refresh-and-retry-on-401
/// behavior, transparently to every datasource that already depends on the
/// `http.Client` abstraction.
///
/// Because this extends [http.BaseClient] it IS a valid `http.Client`
/// (Liskov Substitution) — swapping the DI registration for `http.Client`
/// is the only change needed for every existing datasource to benefit,
/// with zero changes to their own code (Open/Closed Principle).
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final TokenRefreshCoordinator _coordinator;
  final SessionEventBus _sessionEventBus;

  /// Marks a request as already retried once, to prevent infinite loops.
  static const _retryHeader = 'x-retried-after-refresh';

  AuthenticatedHttpClient({
    required http.Client inner,
    required TokenRefreshCoordinator coordinator,
    required SessionEventBus sessionEventBus,
  }) : _inner = inner,
       _coordinator = coordinator,
       _sessionEventBus = sessionEventBus;

  bool _isAuthEndpoint(Uri url) =>
      url.path.contains('/auth/refresh') ||
      url.path.contains('/auth/signin') ||
      url.path.contains('/auth/signout') ||
      url.path.contains('/auth/verify');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Auth endpoints are called through their own datasource with a raw
    // client — this wrapper must never intercept them, or a failed refresh
    // would recursively try to refresh itself.
    if (_isAuthEndpoint(request.url)) {
      return _inner.send(request);
    }

    final isRetry = request.headers.containsKey(_retryHeader);
    final bodyBytes = await request.finalize().toBytes();

    final response = await _inner.send(_cloneRequest(request, bodyBytes));
    if (response.statusCode != 401 || isRetry) {
      return response;
    }

    // Drain the 401 body so the connection can be reused for the retry.
    await response.stream.drain();

    try {
      final session = await _coordinator.refresh();
      final retryRequest = _cloneRequest(
        request,
        bodyBytes,
        overrideToken: session.accessToken,
        markRetried: true,
      );
      return await _inner.send(retryRequest);
    } on AuthSessionExpiredException {
      _sessionEventBus.emitExpired();
      return response;
    } on NetworkRefreshException {
      return response;
    }
  }

  http.BaseRequest _cloneRequest(
    http.BaseRequest original,
    List<int> bodyBytes, {
    String? overrideToken,
    bool markRetried = false,
  }) {
    final clone = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..bodyBytes = bodyBytes
      ..followRedirects = original.followRedirects
      ..persistentConnection = original.persistentConnection;

    if (overrideToken != null) {
      clone.headers['Authorization'] = 'Bearer $overrideToken';
    }
    if (markRetried) {
      clone.headers[_retryHeader] = '1';
    }
    return clone;
  }

  @override
  void close() => _inner.close();
}
