import 'package:equatable/equatable.dart';
import '../../ai/models/ai_output.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final AiOutput aiOutput;
  final Map<String, dynamic> resultsUiMap;

  const ScannerSuccess(this.aiOutput, this.resultsUiMap);

  @override
  List<Object?> get props => [aiOutput, resultsUiMap];
}

class ScannerError extends ScannerState {
  final String message;
  final bool isInvalidPhoto;

  const ScannerError(this.message, {this.isInvalidPhoto = false});

  @override
  List<Object?> get props => [message, isInvalidPhoto];
}

class HistoryLoading extends ScannerState {}

class HistoryLoaded extends ScannerState {
  final List<Map<String, dynamic>> history;

  const HistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class HistoryError extends ScannerState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
