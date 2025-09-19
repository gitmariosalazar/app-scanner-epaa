import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
    detectionTimeoutMs: 3000,
    autoStart: false,
  );

  Rect? _scanWindow;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          await _controller.start();
          debugPrint('Scanner started');
        } catch (e) {
          debugPrint('Error starting scanner: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al iniciar el escáner: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _handleScan(String code) async {
    try {
      final data = jsonDecode(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código QR escaneado correctamente: $code'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      debugPrint("Code detected as JSON: $data");

      if (data is Map<String, dynamic> && data.containsKey('acometidaId')) {
        debugPrint("Code detected as JSON: $data");
        final String baseUrl = Environment.apiUrl;
        final response = await http.get(
          Uri.parse(
            '$baseUrl/Readings/find-basic-reading/${data['acometidaId']}',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic>) {
            debugPrint("Response data as JSON from API: $responseData");
            if (mounted) {
              context.push('/form', extra: responseData).then((_) {
                Future.delayed(const Duration(milliseconds: 500), () async {
                  try {
                    if (_controller.value.isInitialized) {
                      await _controller.start();
                      debugPrint('Scanner restarted after navigation');
                    }
                  } catch (e) {
                    debugPrint('Error restarting scanner: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al reiniciar el escáner: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                });
              });
            }
          } else {
            debugPrint('Response is not a valid JSON object.');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Respuesta de la API no es un objeto JSON válido.',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _resumeScanning();
            }
          }
        } else {
          debugPrint('Error en la API: ${response.statusCode}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error en la API: ${response.statusCode}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _resumeScanning();
          }
        }
      } else {
        debugPrint('Código QR no contiene un acometidaId válido.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código QR no contiene un acometidaId válido.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resumeScanning();
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el código QR: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _resumeScanning();
      }
    }
  }

  Future<void> _resumeScanning() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        if (_controller.value.isInitialized) {
          await _controller.start();
          debugPrint('Scanner restarted after error');
        }
      } catch (e) {
        debugPrint('Error restarting scanner: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al reiniciar el escáner: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  Future<void> _scanFromPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se seleccionó ninguna imagen.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final result = await _controller.analyzeImage(image.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final String? code = result.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          _controller.stop();
          _handleScan(code);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se detectó un código QR en la imagen.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _resumeScanning();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se detectó un código QR en la imagen.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resumeScanning();
        }
      }
    } catch (e) {
      debugPrint('Error scanning image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear la imagen: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _resumeScanning();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escanear Código QR',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final scanAreaSize = width * 0.65;
              final left = (width - scanAreaSize) / 2;
              final top = (height - scanAreaSize) / 2;

              _scanWindow = Rect.fromLTWH(
                left,
                top,
                scanAreaSize,
                scanAreaSize,
              );

              return MobileScanner(
                controller: _controller,
                scanWindow: _scanWindow,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      _controller.stop();
                      _handleScan(code);
                    }
                  }
                },
              );
            },
          ),
          // Scanner Overlay
          _buildScannerOverlay(context),
          // Bottom Button Bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Torch Toggle Button
                _buildActionButton(
                  icon: _isTorchOn ? Icons.flash_off : Icons.flash_on,
                  label: _isTorchOn ? 'Apagar Linterna' : 'Encender Linterna',
                  onPressed: () async {
                    try {
                      await _controller.toggleTorch();
                      setState(() {
                        _isTorchOn = !_isTorchOn;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al alternar la linterna: $e'),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                // Scan from Photo Button
                _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Escanear desde Foto',
                  onPressed: _scanFromPhoto,
                ),
              ],
            ),
          ),
          // Instructions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Alinea el código QR dentro del marco',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scanAreaSize = width * 0.65;
        final left = (width - scanAreaSize) / 2;
        final top = (height - scanAreaSize) / 2;

        return Stack(
          children: [
            // Darkened area around
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Border with corner markers
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top-left corner
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCornerMarker(3.1416),
                    ),
                    // Top-right corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCornerMarker(-1.5708),
                    ),
                    // Bottom-left corner
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCornerMarker(1.5708),
                    ),
                    // Bottom-right corner
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCornerMarker(0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerMarker(double rotationAngleInRadians) {
    return Transform.rotate(
      angle: rotationAngleInRadians,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
