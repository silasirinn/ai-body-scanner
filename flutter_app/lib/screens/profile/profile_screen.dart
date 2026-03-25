import '../../ai/user_data_store.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import 'steps/step1.dart';
import 'steps/step2.dart';
import 'steps/step3.dart';
import 'steps/step4.dart';
import 'steps/step5.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const ProfileScreen({super.key, this.onComplete});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;

  void _nextPage() {
    if (_currentStep < 5) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      widget.onComplete?.call();
    }
  }

  void _prevPage() {
    if (_currentStep > 1) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      // If at step 1, go back to top navigation (Register screen)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple50, AppColors.white, AppColors.emerald50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackBtn(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text("Adım $_currentStep/5",
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  value: _currentStep / 5,
                                  strokeWidth: 3,
                                  backgroundColor: AppColors.gray200,
                                  color: AppColors.primary)),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.75, // Replaced Expanded to avoid Flex error inside scroll view
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ProfileStep1(onNext: (name) {
                        UserDataStore().updateName(name);
                        _nextPage();
                      }),
                      ProfileStep2(onNext: (age) {
                        UserDataStore().updateAge(age);
                        _nextPage();
                      }),
                      ProfileStep3(onNext: (gender) {
                        UserDataStore().updateGender(gender);
                        _nextPage();
                      }),
                      ProfileStep4(onNext: (weight, height) {
                        UserDataStore().updateMeasurements(weight, height);
                        _nextPage();
                      }),
                      ProfileStep5(onComplete: (goal) {
                        UserDataStore().updateGoal(goal);
                        widget.onComplete?.call();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackBtn() {
    return InkWell(
      onTap: _prevPage,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: AppColors.gray100, shape: BoxShape.circle),
        child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
      ),
    );
  }
}
