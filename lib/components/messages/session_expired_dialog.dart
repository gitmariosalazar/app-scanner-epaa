import 'package:flutter/material.dart';

/// Mirrors the web frontends' session-expiration modal: shown when
/// [LoginCubit] emits `LoginSessionExpired` (idle timeout or a refresh that
/// could not be silently completed). Non-dismissible — the user must choose
/// to continue or log out.
class SessionExpiredDialog extends StatefulWidget {
  final Future<void> Function() onExtend;
  final Future<void> Function() onLogout;

  const SessionExpiredDialog({
    super.key,
    required this.onExtend,
    required this.onLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onExtend,
    required Future<void> Function() onLogout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          SessionExpiredDialog(onExtend: onExtend, onLogout: onLogout),
    );
  }

  @override
  State<SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<SessionExpiredDialog> {
  bool _isExtending = false;

  Future<void> _handleExtend() async {
    setState(() => _isExtending = true);
    await widget.onExtend();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleLogout() async {
    await widget.onLogout();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Sesión inactiva'),
        content: const Text(
          'Tu sesión ha estado inactiva por un tiempo prolongado. '
          '¿Deseas continuar trabajando?',
        ),
        actions: [
          TextButton(
            onPressed: _isExtending ? null : _handleLogout,
            child: const Text('Cerrar sesión'),
          ),
          FilledButton(
            onPressed: _isExtending ? null : _handleExtend,
            child: _isExtending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continuar sesión'),
          ),
        ],
      ),
    );
  }
}
