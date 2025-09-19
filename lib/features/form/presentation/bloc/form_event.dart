part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

class SubmitFormEvent extends FormEvent {
  final int readingId;
  final double previousReading;
  final double currentReading;
  final int rentalIncomeCode;
  final String novelty;
  final int incomeCode;
  final String cadastralKey;
  final int sector;
  final int account;
  final String connectionId;
  final double averageConsumption;

  const SubmitFormEvent({
    required this.readingId,
    required this.currentReading,
    required this.previousReading,
    required this.rentalIncomeCode,
    required this.novelty,
    required this.incomeCode,
    required this.cadastralKey,
    required this.sector,
    required this.account,
    required this.connectionId,
    required this.averageConsumption,
  });

  @override
  List<Object> get props => [currentReading];
}
