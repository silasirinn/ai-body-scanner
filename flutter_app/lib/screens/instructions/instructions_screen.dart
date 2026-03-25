import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../widgets/primary_button.dart';

class InstructionsScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const InstructionsScreen({super.key, this.onNext, this.onBack});

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
                child: Stack(
                    children: [
                        // Scrollable Content
                        Positioned.fill(
                            child: ListView(
                                padding: const EdgeInsets.only(
                                    top: 100, // Space for Header
                                    left: 24, 
                                    right: 24, 
                                    bottom: 120 // Space for Button
                                ),
                                children: [
                                    _buildInstructionItem(
                                        index: 1,
                                        title: "Kıyafet ve Giysi",
                                        subtitle: "Dar Giysiler Giyin",
                                        description: "Analiz için lütfen tayt, şort, sporcu atleti gibi vücudunuzu saran dar giysiler giyin. Bol giysiler sonuçları tamamen yanlış çıkaracaktır.",
                                        content: Column(
                                            children: [
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Expanded(child: _buildCheckList(true, ["Tayt", "Şort", "Sporcu atleti"])),
                                                        const SizedBox(width: 12),
                                                        Expanded(child: _buildCheckList(false, ["Bol pantolon", "Geniş tişört", "Kapüşonlu"])),
                                                    ],
                                                )
                                            ],
                                        )
                                    ),
                                    _buildInstructionItem(
                                        index: 2,
                                        title: "Duruş ve Poz",
                                        subtitle: "Tam ve Düz Duruş",
                                        description: "Dik durun, kolları iki yana açın (A pozu veya T pozu), bacaklarınızı omuz genişliğinde ayırın.",
                                        content: Center(child: SvgPicture.string(
                                            '''<svg width="100" height="140" viewBox="0 0 100 140" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <ellipse cx="50" cy="20" rx="12" ry="15" fill="#8B5CF6" fill-opacity="0.2"/>
                                            <rect x="44" y="35" width="12" height="40" rx="6" fill="#8B5CF6" fill-opacity="0.2"/>
                                            <rect x="20" y="40" width="24" height="8" rx="4" fill="#8B5CF6" fill-opacity="0.2" transform="rotate(-15 32 44)"/>
                                            <rect x="56" y="40" width="24" height="8" rx="4" fill="#8B5CF6" fill-opacity="0.2" transform="rotate(15 68 44)"/>
                                            <rect x="40" y="75" width="8" height="50" rx="4" fill="#8B5CF6" fill-opacity="0.2"/>
                                            <rect x="52" y="75" width="8" height="50" rx="4" fill="#8B5CF6" fill-opacity="0.2"/>
                                            </svg>''',
                                            height: 140,
                                        )),
                                    ),
                                    _buildInstructionItem(
                                        index: 3,
                                        title: "Çekim Kapsamı",
                                        subtitle: "Tüm Vücut Kadrajda",
                                        description: "Fotoğraf başınızın üstünden ayaklarınıza kadar tüm vücudunuzu içermelidir.",
                                        content: Center(child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                                SvgPicture.string('''<svg width="50" height="80" viewBox="0 0 50 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <ellipse cx="25" cy="12" rx="8" ry="10" fill="#8B5CF6" fill-opacity="0.3"/>
                                                <rect x="21" y="22" width="8" height="25" rx="4" fill="#8B5CF6" fill-opacity="0.3"/>
                                                <rect x="18" y="47" width="5" height="28" rx="2.5" fill="#8B5CF6" fill-opacity="0.3"/>
                                                <rect x="27" y="47" width="5" height="28" rx="2.5" fill="#8B5CF6" fill-opacity="0.3"/>
                                                </svg>'''),
                                                Container(
                                                    width: 100, height: 140,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: AppColors.primary, width: 2, style: BorderStyle.none), // Dashed border needs custom painter, simpler:
                                                    ),
                                                    child: CustomPaint(painter: DashedRectPainter()),
                                                )
                                            ],
                                        )),
                                    ),
                                    _buildInstructionItem(
                                        index: 4,
                                        title: "Açı ve Mesafe",
                                        subtitle: "Doğru Açı ve Hiza",
                                        description: "Telefonu tam karşıdan ve bel hizanızda tutun. Aşağıdan veya yukarıdan çekim yapmayın.",
                                        content: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                                _buildAngleIcon("Yukarıdan", Colors.red),
                                                _buildAngleIcon("Düz", AppColors.emerald500, correct: true),
                                                _buildAngleIcon("Aşağıdan", Colors.red),
                                            ],
                                        )
                                    ),
                                    _buildInstructionItem(
                                        index: 5,
                                        title: "Arka Plan",
                                        subtitle: "Sade Bir Arka Plan Seçiniz",
                                        description: "Düz, tek renkli bir duvar önünde çekim yapın.",
                                        content: Row(
                                            children: [
                                                Expanded(child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: AppColors.emerald50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.emerald100)),
                                                    child: Column(children: [
                                                        Container(height: 48, color: Colors.grey[200]),
                                                        const SizedBox(height: 4),
                                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(LucideIcons.check, size: 12, color: Colors.green), SizedBox(width: 4), Expanded(child: Text("Sade duvar", style: TextStyle(color: Colors.green, fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis))])
                                                    ])
                                                )),
                                                const SizedBox(width: 8),
                                                Expanded(child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.red100)),
                                                    child: Column(children: [
                                                        Container(height: 48, decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://via.placeholder.com/150"), fit: BoxFit.cover))), // Placeholder pattern
                                                        const SizedBox(height: 4),
                                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(LucideIcons.x, size: 12, color: Colors.red), SizedBox(width: 4), Expanded(child: Text("Karmaşık", style: TextStyle(color: Colors.red, fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis))])
                                                    ])
                                                )),
                                            ],
                                        )
                                    ),
                                ],
                            ),
                        ),

                        // Fixed Header
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                                color: AppColors.white.withOpacity(0.9), // Glass effect
                                child: FadeInDown(
                                    delay: const Duration(milliseconds: 200),
                                    child: Row(
                                        children: [
                                            InkWell(
                                                onTap: onBack ?? () => Navigator.pop(context),
                                                borderRadius: BorderRadius.circular(50),
                                                child: Container(
                                                    width: 40, height: 40,
                                                    decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                                                    child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                                width: 48, height: 48,
                                                decoration: BoxDecoration(
                                                    gradient: AppColors.logoGradient,
                                                    borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(LucideIcons.camera, color: Colors.white),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text("Çekim Talimatları", style: AppTypography.h2),
                                                        Text("Doğru analiz için önemli", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                                    ],
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                            ),
                        ),

                         // Fixed Button at Bottom
                        Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.95),
                                    border: const Border(top: BorderSide(color: AppColors.gray100)),
                                ),
                                child: PrimaryButton(
                                    onPressed: onNext,
                                    fullWidth: true,
                                    child: const Text("Anladım, Devam Et"),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
  }

  Widget _buildInstructionItem({required int index, required String title, required String subtitle, required String description, Widget? content}) {
    return FadeInLeft(
        delay: Duration(milliseconds: 300 + index * 100),
        child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray100),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            Container(width: 32, height: 32, decoration: BoxDecoration(gradient: AppColors.logoGradient, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text("$index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            Expanded( // Wrapped in Expanded
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                        Text(title, style: AppTypography.h3), 
                                        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.primary))
                                    ]
                                )
                            ),
                        ],
                    ),
                    const SizedBox(height: 12),
                    Text(description, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                    if (content != null) ...[
                        const SizedBox(height: 16),
                        content,
                    ],
                ],
            ),
        ),
    );
  }

  Widget _buildCheckList(bool isCorrect, List<String> items) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(children: [Icon(isCorrect ? LucideIcons.check : LucideIcons.x, size: 16, color: isCorrect ? Colors.green : Colors.red), const SizedBox(width: 4), Expanded(child: Text(isCorrect ? "Doğru" : "Yanlış", style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)))]),
            const SizedBox(height: 8),
            ...items.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isCorrect ? AppColors.emerald50 : AppColors.red50, borderRadius: BorderRadius.circular(6)),
                child: Row(
                    children: [
                        Icon(isCorrect ? LucideIcons.check : LucideIcons.x, size: 12, color: isCorrect ? Colors.green : Colors.red), 
                        const SizedBox(width: 4), 
                        Expanded(child: Text(e, style: TextStyle(color: isCorrect ? Colors.green[800] : Colors.red[800], fontSize: 10)))
                    ]
                ),
            )),
        ],
    );
  }

  Widget _buildAngleIcon(String label, Color color, {bool correct = false}) {
     return Column(
         children: [
             Container(
                 width: 48, height: 48,
                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
                 child: Icon(correct ? LucideIcons.check : LucideIcons.camera, color: color),
             ),
             const SizedBox(height: 4),
             Text(label, style: TextStyle(color: color, fontSize: 10)),
         ],
     );
  }
}

class DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Simple dashed implementation
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    
    // Top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Right
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Bottom
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }
    // Left
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
