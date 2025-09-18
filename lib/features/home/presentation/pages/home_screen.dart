import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scanner App',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scanner Logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 32.0, top: 40.0),
                    child: Image.asset(
                      'assets/images/qr-code.png', // Replace with your scanner logo asset path
                      height: 120,
                      width: 120,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.qr_code_scanner,
                        size: 120,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Welcome Text
                  Text(
                    'Welcome to Scanner',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan QR codes or enter details manually',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Scan QR Code Button
                  _AnimatedButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan QR Code',
                    color: theme.colorScheme.primary,
                    onPressed: () => context.push('/scan'),
                  ),
                  const SizedBox(height: 16),
                  // Continue Manually Button
                  _AnimatedButton(
                    icon: Icons.edit,
                    label: 'Continue Manually',
                    color: Colors.grey.shade600,
                    onPressed: () => context.push('/manually-entry'),
                  ),
                  const SizedBox(height: 24),
                  // Additional Info or Footer
                  Text(
                    'Fast. Secure. Simple.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Animated Button Widget for Reusability and Animation
class _AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
