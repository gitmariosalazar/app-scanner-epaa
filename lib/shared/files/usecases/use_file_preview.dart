// shared/files/presentation/hooks/use_file_preview.dart
import 'package:flutter_application/shared/files/domain/repositories/file_repository.dart';
import 'package:flutter_application/shared/files/presentation/use_file_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../usecases/preview_file_use_case.dart';

final previewFileUseCaseProvider = Provider<PreviewFileUseCase>((ref) {
  final repo = ref.watch(fileRepositoryProvider);
  return PreviewFileUseCase(repo);
});

final useFilePreviewProvider =
    StateNotifierProvider<UseFilePreviewNotifier, UseFilePreviewResult>((ref) {
      final useCase = ref.watch(previewFileUseCaseProvider);
      return UseFilePreviewNotifier(useCase);
    });

// Resultado
class UseFilePreviewResult {
  final String? blobUrl;
  final bool loading;
  final String? error;

  const UseFilePreviewResult({this.blobUrl, this.loading = false, this.error});
}

// Notifier
class UseFilePreviewNotifier extends StateNotifier<UseFilePreviewResult> {
  final PreviewFileUseCase _useCase;

  UseFilePreviewNotifier(this._useCase) : super(const UseFilePreviewResult());

  Future<void> load(FileCategory type, String filename) async {
    state = const UseFilePreviewResult(loading: true);
    try {
      final bytes = await _useCase.execute(type: type, filename: filename);
      final url = Uri.dataFromBytes(bytes, mimeType: 'image/jpeg').toString();
      state = UseFilePreviewResult(blobUrl: url);
    } catch (e) {
      state = UseFilePreviewResult(error: e.toString());
    }
  }

  void clear() {
    state = const UseFilePreviewResult();
  }
}
