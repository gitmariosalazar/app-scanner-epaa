import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/services/speech_service.dart';
import 'speech_state.dart';

class SpeechCubit extends Cubit<SpeechState> {
  final SpeechService _speechService;

  SpeechCubit(this._speechService) : super(SpeechInitial());

  Future<void> startListening() async {
    try {
      final initialized = await _speechService.initialize();
      if (!initialized) {
        emit(const SpeechError('No se pudo inicializar el micrófono o faltan permisos.'));
        return;
      }

      emit(const SpeechListening(''));

      await _speechService.startListening((text) {
        emit(SpeechListening(text));
      });
    } catch (e) {
      emit(SpeechError(e.toString()));
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechService.stopListening();
      emit(SpeechInitial());
    } catch (e) {
      emit(SpeechError(e.toString()));
    }
  }
}
