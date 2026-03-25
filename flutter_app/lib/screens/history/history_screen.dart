import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_typography.dart';
import '../../../blocs/scanner/scanner_bloc.dart';
import '../../../blocs/scanner/scanner_event.dart';
import '../../../blocs/scanner/scanner_state.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onBack});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch load event when screen initializes
    context.read<ScannerBloc>().add(LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple50, AppColors.white, AppColors.emerald50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                     InkWell(
                        onTap: widget.onBack ?? () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                        ),
                     ),
                     const SizedBox(width: 16),
                     Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("Geçmiş Analizler", style: AppTypography.h2),
                            Text("Eski sonuçlarınızı inceleyin", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                        ],
                     )
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocBuilder<ScannerBloc, ScannerState>(
                  builder: (context, state) {
                    if (state is HistoryLoading || state is ScannerInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is HistoryError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.alertCircle, color: AppColors.destructive, size: 48),
                              const SizedBox(height: 16),
                              Text(state.message, style: AppTypography.bodySmall, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.read<ScannerBloc>().add(LoadHistoryEvent()),
                                child: const Text("Tekrar Dene"),
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (state is HistoryLoaded) {
                      if (state.history.isEmpty) {
                         return _buildEmptyState();
                      }
                      return _buildHistoryList(state.history);
                    }
                    
                    // Fallback
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple50,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.clock, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text("Henüz Analiz Yok", style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              "İlk vücut analizinizi yaparak\nsonuçlarınızı burada görebilirsiniz.",
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final dateObj = DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now();
        final dateStr = "${dateObj.day}/${dateObj.month}/${dateObj.year}";
        final double bmi = item['bmi']?.toDouble() ?? 0.0;
        final double fat = item['bodyFatPct']?.toDouble() ?? 0.0;
        
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.activity, color: AppColors.emerald500),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Analiz Sonucu", style: AppTypography.h3.copyWith(fontSize: 16)),
                      Text(dateStr, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("VKİ: ${bmi.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text("Yağ: %${fat.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
