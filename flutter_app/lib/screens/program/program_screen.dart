import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../widgets/primary_button.dart';
import '../../ai/models/ai_output.dart';
import '../../ai/ai_result_mapper.dart';
import '../../ai/user_data_store.dart';

class ProgramScreen extends StatelessWidget {
  final Map<String, dynamic>? data;
  final VoidCallback? onBack;

  const ProgramScreen({super.key, this.data, this.onBack});

  @override
  Widget build(BuildContext context) {
    // Read arguments
    final aiOutput = ModalRoute.of(context)?.settings.arguments as AiOutput?;
    
    Map<String, dynamic> programData = {};
    if (aiOutput != null) {
        String goalText = UserDataStore().data.goal;
        if (goalText == 'lose') goalText = "Kilo Vermek";
        else if (goalText == 'gain') goalText = "Kilo Almak";
        else goalText = "Form Korumak";

        programData = AiResultMapper.mapAiToProgramUi(aiOutput, goalText: goalText);
    } else {
        programData = data ?? {};
    }

    // Mock Fallback if empty (e.g. direct preview)
    if (programData.isEmpty) {
        programData = {
            'goal': "Örnek Program",
            'calories': 2000,
            'macros': {'proteinPct': 30, 'carbsPct': 40, 'fatPct': 30},
            'mealPlan': [{'type': "Örnek Öğün", 'icon': "�", 'meals': ["Örnek içerik"]}],
            'exercises': [{'name': "Örnek Egzersiz", 'icon': "💪", 'duration': "10 dk"}]
        };
    }

    final goal = programData['goal'] as String;
    final calories = programData['calories'] as int;
    
    // Macros
    final macros = programData['macros'] as Map<String, dynamic>;
    final protein = macros['proteinPct'] as int;
    final carbs = macros['carbsPct'] as int;
    final fats = macros['fatPct'] as int;

    final mealPlan = List<Map<String, dynamic>>.from(programData['mealPlan']);
    final exercises = List<Map<String, dynamic>>.from(programData['exercises']);

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
                            padding: const EdgeInsets.only(top: 24, bottom: 16, left: 24, right: 24),
                            child: FadeInDown(
                                from: 20,
                                child: Column(
                                    children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: InkWell(
                                              onTap: onBack ?? () => Navigator.pop(context), // Default pop
                                              borderRadius: BorderRadius.circular(50),
                                              child: Container(
                                                  width: 40, height: 40,
                                                  decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                                                  child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                                              ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text("Size Özel Programınız Hazır!", style: AppTypography.h2, textAlign: TextAlign.center),
                                        const SizedBox(height: 4),
                                        Text("AI destekli kişisel sağlık planı", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                    ],
                                ),
                            ),
                        ),

                        Expanded(
                            child: ListView(
                                padding: const EdgeInsets.all(24),
                                children: [
                                    // Goal Card
                                    ZoomIn(
                                        child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.purple600Tailwind]),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                                            ),
                                            child: Column(
                                                children: [
                                                    Row(
                                                        children: [
                                                            Container(
                                                                padding: const EdgeInsets.all(12),
                                                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                                                child: const Text("📉", style: TextStyle(fontSize: 24)),
                                                            ),
                                                            const SizedBox(width: 16),
                                                            Expanded( // Wrapped in Expanded
                                                                child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                        const Text("Hedefiniz", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                                                        Text(goal, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                                                    ],
                                                                ),
                                                            )
                                                        ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                        children: [
                                                            const Icon(LucideIcons.flame, color: Colors.white, size: 32),
                                                            const SizedBox(width: 12),
                                                            Expanded( // Wrapped in Expanded
                                                                child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                        const Text("Günlük Kalori Hedefi", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                                                        Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                                                            textBaseline: TextBaseline.alphabetic,
                                                                            children: [
                                                                                Text("$calories", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                                                                const SizedBox(width: 4),
                                                                                const Text("kcal", style: TextStyle(color: Colors.white70)),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            )
                                                        ],
                                                    )
                                                ],
                                            ),
                                        ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Diet
                                    FadeInUp(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                    children: const [
                                                        Icon(LucideIcons.apple, color: AppColors.primary),
                                                        SizedBox(width: 8),
                                                        Text("Diyet Programı", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                    ],
                                                ),
                                                const SizedBox(height: 16),
                                                // Macro Chart & Lists (omitting complex pie chart for simplicity/speed, using list status)
                                                Container(
                                                    padding: const EdgeInsets.all(20),
                                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray200)),
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                            Expanded(child: _buildMacroItem("Karbonhidrat", carbs, Colors.purple)),
                                                            Expanded(child: _buildMacroItem("Protein", protein, Colors.green)),
                                                            Expanded(child: _buildMacroItem("Yağ", fats, Colors.orange)),
                                                        ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: mealPlan.length,
                                                itemBuilder: (context, index) {
                                                  final meal = mealPlan[index];
                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 12),
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray100)),
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Row(children: [Text(meal['icon'] as String, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8), Text(meal['type'] as String, style: const TextStyle(fontWeight: FontWeight.bold))]),
                                                            const SizedBox(height: 8),
                                                            ...(meal['meals'] as List<String>).map((m) => Padding(
                                                                padding: const EdgeInsets.only(bottom: 4),
                                                                child: Row(children: [const CircleAvatar(radius: 3, backgroundColor: AppColors.accent), const SizedBox(width: 8), Expanded(child: Text(m, style: const TextStyle(color: Colors.grey)))]),
                                                            )),
                                                        ],
                                                    ),
                                                  );
                                                }
                                              ),
                                            ],
                                        ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Sport
                                    FadeInUp(
                                        delay: const Duration(milliseconds: 200),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                    children: const [
                                                        Icon(LucideIcons.dumbbell, color: AppColors.accent),
                                                        SizedBox(width: 8),
                                                        Text("Spor Programı", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                    ],
                                                ),
                                                const SizedBox(height: 16),
                                                GridView.builder(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9),
                                                    itemCount: exercises.length,
                                                    itemBuilder: (c, i) => Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gray100)),
                                                        child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Text(exercises[i]['icon'] as String, style: const TextStyle(fontSize: 28)),
                                                                const SizedBox(height: 6),
                                                                Expanded(
                                                                    child: Align(
                                                                        alignment: Alignment.center,
                                                                        child: Text(
                                                                            exercises[i]['name'] as String, 
                                                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                                                                            textAlign: TextAlign.center, 
                                                                            maxLines: 3, 
                                                                            overflow: TextOverflow.ellipsis
                                                                        )
                                                                    )
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(exercises[i]['duration'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center, maxLines: 1),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
  }

  Widget _buildMacroItem(String label, int value, Color color) {
    return Column(
        children: [
            Stack(
                alignment: Alignment.center,
                children: [
                    CircularProgressIndicator(value: value/100, color: color, backgroundColor: color.withOpacity(0.1)),
                    Text("$value%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
        ],
    );
  }
}
