import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';
import '../../services/api_service.dart';
import '../../ai/ai_result_mapper.dart'; // We can keep using the mapper if it works, or adapt it.

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ApiService apiService;

  ScannerBloc(this.apiService) : super(ScannerInitial()) {
    on<AnalyzePhotoEvent>(_onAnalyzePhoto);
    on<LoadHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onAnalyzePhoto(AnalyzePhotoEvent event, Emitter<ScannerState> emit) async {
    emit(ScannerLoading());
    try {
      final aiOutput = await apiService.analyzePhoto(event.image, event.userData);
      
      // Map to UI results using existing mapper
      final resultsUiMap = AiResultMapper.mapAiToResultsUi(
        aiOutput, 
        weight: event.userData['weight']?.toInt() ?? 0, 
        height: event.userData['height']?.toInt() ?? 0
      );

      emit(ScannerSuccess(aiOutput, resultsUiMap));
    } on FormatException catch (e) {
      if (e.message == 'invalid_photo') {
        emit(const ScannerError('Geçersiz fotoğraf.', isInvalidPhoto: true));
      } else {
        emit(ScannerError('Beklenmeyen format hatası: ${e.message}'));
      }
    } catch (e) {
      emit(ScannerError('Sunucuya bağlanılamadı veya bir hata oluştu: $e'));
    }
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<ScannerState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await apiService.getHistory();
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError('Geçmiş yüklenirken hata oluştu: $e'));
    }
  }
}
