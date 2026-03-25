import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart'; // For AppRoutes

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final Function(XFile)? onAnalyze;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;

  const DashboardScreen({
    super.key,
    this.userName = "Kullanıcı",
    this.onAnalyze,
    this.onSettings,
    this.onBack,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _handleCameraCapture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        debugPrint("DASHBOARD_DEBUG: Camera Image Path: ${photo.path}");
        setState(() => _selectedImage = photo);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("DASHBOARD_DEBUG: Gallery Image Path: ${image.path}");
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      debugPrint("Gallery error: $e");
    }
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
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), // pt-8 px-6 pb-6
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  border: const Border(bottom: BorderSide(color: AppColors.gray100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Wrapped in Expanded
                        child: FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            from: 20,
                            child: Row(
                                children: [
                                    if (widget.onBack != null)
                                        Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: InkWell(
                                                onTap: widget.onBack,
                                                borderRadius: BorderRadius.circular(50),
                                                child: Container(
                                                    width: 40, height: 40,
                                                    decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                                                    child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                                                ),
                                            ),
                                        ),
                                    Expanded( // Wrapped Inner Column in Expanded
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    "Merhaba, ${widget.userName} 👋",
                                                    style: AppTypography.h2,
                                                    overflow: TextOverflow.ellipsis, // Add ellipsis
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "Vücut analizine hazır mısın?",
                                                    style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                    const SizedBox(width: 16),
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      from: 20,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.history, color: AppColors.emerald500, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: widget.onSettings,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.gray100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.settings, color: AppColors.gray600, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Image Preview or Upload Area
                      ZoomIn( // Using ZoomIn instead of FadeIn(scale)
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: _selectedImage != null ? _buildImagePreview() : _buildUploadPlaceholder(),
                      ),
                      
                      const SizedBox(height: 24),

                      // Action Buttons
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 400),
                        from: 20,
                        child: _buildActionButton(
                          icon: LucideIcons.camera,
                          title: "Kamera ile Çek",
                          subtitle: "Anlık fotoğraf çek",
                          gradientColors: [AppColors.primary, AppColors.purple600Tailwind],
                          onTap: _handleCameraCapture,
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 500),
                        from: 20,
                        child: _buildActionButton(
                          icon: LucideIcons.upload,
                          title: "Galeriden Seç",
                          subtitle: "Mevcut fotoğraf yükle",
                          gradientColors: [AppColors.accent, AppColors.emerald500],
                           onTap: _handleFileUpload,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Analyze Button
              if (_selectedImage != null)
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 600),
                  from: 20,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.8),
                      border: const Border(top: BorderSide(color: AppColors.gray100)),
                    ),
                    child: PrimaryButton(
                      onPressed: () => widget.onAnalyze?.call(_selectedImage!),
                      fullWidth: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.sparkles, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Analizi Başlat"),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.file(
            File(_selectedImage!.path),
            width: double.infinity,
            height: 320, // h-80
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) {
              debugPrint("DASHBOARD_DEBUG: Image Load Error: $e");
              final file = File(_selectedImage!.path);
              debugPrint("DASHBOARD_DEBUG: File exists: ${file.existsSync()}");
              if (file.existsSync()) {
                  debugPrint("DASHBOARD_DEBUG: File size: ${file.lengthSync()} bytes");
              }
              return Container(
                height: 320, 
                color: Colors.grey[200], 
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            const Icon(Icons.broken_image, color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text("Görsel yüklenemedi: $e", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                        ],
                    )
                ),
              );
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.destructive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                children: const [
                  Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Görsel yüklendi, analiz için hazır!",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray300, style: BorderStyle.solid, width: 4), // dashed border not native easily, using solid gray300
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.purple100, AppColors.emerald100]),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.camera, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text("Fotoğraf Yükle veya Çek", style: AppTypography.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "Talimatları takip ettiğinizden emin olun",
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20), // p-5
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16), // rounded-2xl
          border: Border.all(color: AppColors.gray200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 56, // w-14
              height: 56, // h-14
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12), // rounded-xl
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded( // Wrapped in Expanded
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(title, style: AppTypography.h3.copyWith(fontSize: 16)),
                        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground), overflow: TextOverflow.ellipsis),
                    ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
