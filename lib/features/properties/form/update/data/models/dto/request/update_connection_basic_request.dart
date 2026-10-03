import 'dart:io';
import 'package:equatable/equatable.dart';

class UpdateConnectionBasicRequest extends Equatable {
  final String connectionId;
  final String? meterNumber;
  final List<File> photosFacade;
  final List<String> photosFacadeDescriptions;
  final List<File> photosMeter;
  final List<String> photosMeterDescriptions;

  const UpdateConnectionBasicRequest({
    required this.connectionId,
    this.meterNumber,
    this.photosFacade = const [],
    this.photosFacadeDescriptions = const [],
    this.photosMeter = const [],
    this.photosMeterDescriptions = const [],
  });

  @override
  List<Object?> get props => [
        connectionId,
        meterNumber,
        photosFacade,
        photosFacadeDescriptions,
        photosMeter,
        photosMeterDescriptions,
      ];
}
