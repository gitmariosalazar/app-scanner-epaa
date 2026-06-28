// lib/shared/files/presentation/providers/file_providers.dart
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/shared/files/domain/repositories/file_repository.dart';
import 'package:flutter_application/shared/files/data/repositories/file_repository_impl.dart';
import 'package:flutter_application/shared/files/usecases/preview_file_use_case.dart';
import 'package:flutter_riverpod/legacy.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Interceptor JWT
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Token JWT agregado a la petición');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          print('❌ 401 Unauthorized - Token inválido o expirado');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// ==================== FILE PROVIDERS ====================

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FileRepositoryImpl(dio);
});

final previewFileUseCaseProvider = Provider<PreviewFileUseCase>((ref) {
  final repo = ref.watch(fileRepositoryProvider);
  return PreviewFileUseCase(repo);
});

// ==================== USE FILE PREVIEW ====================

final useFilePreviewProvider =
    StateNotifierProvider<UseFilePreviewNotifier, UseFilePreviewResult>((ref) {
      final useCase = ref.watch(previewFileUseCaseProvider);
      return UseFilePreviewNotifier(useCase);
    });

class UseFilePreviewResult {
  final String? blobUrl;
  final bool loading;
  final String? error;

  const UseFilePreviewResult({this.blobUrl, this.loading = false, this.error});
}

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

// ==================== HELPER TOKEN ====================

Future<String?> _getAuthToken() async {
  try {
    final loginCubit = di.sl<LoginCubit>();
    final state = loginCubit.state;

    if (state is LoginSuccess) {
      // Ajusta según cómo tengas el token en LoginSuccess
      return state.user.firstName; // Si tienes token en el state
      // return state.user.token; // Si el token está dentro de User
    }
  } catch (e) {
    print('Error obteniendo token: $e');
  }
  return null;
}
