// shared/utils/file_utils.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

class FileUtils {
  /// Descarga y guarda el archivo en el dispositivo
  static Future<void> saveAndOpenFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      // Abrir con la app predeterminada
      await Share.shareXFiles([XFile(file.path)], text: filename);
    } catch (e) {
      rethrow;
    }
  }
}
