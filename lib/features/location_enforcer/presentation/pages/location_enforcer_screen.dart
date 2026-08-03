import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';
import 'package:flutter_application/features/location_enforcer/presentation/cubit/location_enforcer_cubit.dart';
import 'package:flutter_application/features/location_enforcer/presentation/cubit/location_enforcer_state.dart';

class LocationEnforcerScreen extends StatefulWidget {
  const LocationEnforcerScreen({super.key});

  @override
  State<LocationEnforcerScreen> createState() => _LocationEnforcerScreenState();
}

class _LocationEnforcerScreenState extends State<LocationEnforcerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check status as soon as screen opens
    context.read<LocationEnforcerCubit>().checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when returning to the app
      context.read<LocationEnforcerCubit>().checkStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<LocationEnforcerCubit, LocationEnforcerState>(
        builder: (context, state) {
          if (state is LocationEnforcerChecking || state is LocationEnforcerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = state.status;
          
          String title = '';
          String description = '';
          IconData icon = Icons.location_off;
          String buttonText = '';
          VoidCallback? onPressed;

          switch (status) {
            case LocationStatus.serviceDisabled:
              title = 'GPS Desactivado';
              description = 'Por favor, enciende el GPS (Ubicación) de tu dispositivo para poder utilizar la aplicación.';
              icon = Icons.gps_off;
              buttonText = 'Activar GPS';
              onPressed = () => context.read<LocationEnforcerCubit>().openSettings();
              break;
            case LocationStatus.denied:
              title = 'Permiso de Ubicación';
              description = 'Esta aplicación requiere acceso a tu ubicación para funcionar correctamente. Por favor, otorga los permisos necesarios.';
              icon = Icons.location_on;
              buttonText = 'Dar Permiso';
              onPressed = () => context.read<LocationEnforcerCubit>().requestPermission();
              break;
            case LocationStatus.deniedForever:
              title = 'Permiso Denegado';
              description = 'Has denegado permanentemente el acceso a la ubicación. Debes habilitarlo manualmente desde la configuración de la aplicación.';
              icon = Icons.settings;
              buttonText = 'Abrir Configuración';
              onPressed = () => context.read<LocationEnforcerCubit>().openSettings();
              break;
            case LocationStatus.granted:
              // If granted, the router will automatically redirect away from this screen
              return const Center(child: CircularProgressIndicator());
            case LocationStatus.unknown:
              return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    icon,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }
}
