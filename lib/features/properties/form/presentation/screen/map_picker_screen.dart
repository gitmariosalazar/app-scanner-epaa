// lib/features/properties/form/presentation/screen/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application/core/theme/app_colors.dart';

class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double lat, double lng) onLocationPicked;

  const MapPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationPicked,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  late CameraPosition _cameraPosition;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
      target: LatLng(widget.initialLat, widget.initialLng),
      zoom: 17,
    );
    _marker = Marker(
      markerId: const MarkerId('picked_location'),
      position: LatLng(widget.initialLat, widget.initialLng),
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final pos = _marker.position;
              context.pop({'lat': pos.latitude, 'lng': pos.longitude});
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        onMapCreated: (controller) => _controller = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {_marker},
        onTap: (latLng) {
          setState(() {
            _marker = _marker.copyWith(positionParam: latLng);
          });
          _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () async {
          // Verificar si el widget sigue montado antes de cualquier operación asíncrona
          if (!mounted) return;

          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

            final newPos = LatLng(position.latitude, position.longitude);

            // Verificar nuevamente antes de setState
            if (!mounted) return;

            setState(() {
              _marker = _marker.copyWith(positionParam: newPos);
            });

            _controller?.animateCamera(CameraUpdate.newLatLng(newPos));
          } catch (e) {
            // Verificar mounted antes de usar ScaffoldMessenger
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al obtener ubicación: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
