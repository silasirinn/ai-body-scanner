import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

class AnalyzePhotoEvent extends ScannerEvent {
  final XFile image;
  final Map<String, dynamic> userData;

  const AnalyzePhotoEvent(this.image, this.userData);

  @override
  List<Object> get props => [image, userData];
}

class LoadHistoryEvent extends ScannerEvent {}
