import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/blocs/speech/speech_cubit.dart';
import 'package:flutter_application/core/blocs/speech/speech_state.dart';
import 'package:flutter_application/core/di/injection.dart';
import 'package:flutter_application/core/services/speech_service.dart';

class MicSuffixButton extends StatefulWidget {
  final TextEditingController controller;

  const MicSuffixButton({
    super.key,
    required this.controller,
  });

  @override
  State<MicSuffixButton> createState() => _MicSuffixButtonState();
}

class _MicSuffixButtonState extends State<MicSuffixButton> {
  String _initialText = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpeechCubit(sl<SpeechService>()),
      child: BlocConsumer<SpeechCubit, SpeechState>(
        listener: (context, state) {
          if (state is SpeechListening) {
            if (state.text.isNotEmpty) {
              final newText = _initialText.isEmpty 
                  ? state.text 
                  : '$_initialText ${state.text}';
              widget.controller.text = newText;
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
            }
          } else if (state is SpeechError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isListening = state is SpeechListening;
          
          return IconButton(
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              final cubit = context.read<SpeechCubit>();
              if (!isListening) {
                _initialText = widget.controller.text;
                cubit.startListening();
              } else {
                cubit.stopListening();
              }
            },
          );
        },
      ),
    );
  }
}
