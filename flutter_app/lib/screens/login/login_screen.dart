import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/config/app_colors.dart';
import 'package:flutter_app/config/app_typography.dart';
import 'package:flutter_app/widgets/primary_button.dart';
import 'package:flutter_app/widgets/custom_text_field.dart';
import 'package:flutter_app/widgets/social_login_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const LoginScreen({super.key, this.onLogin, this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Gradient Background: from-purple-50 via-white to-emerald-50
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 64), // pt-16

                  // Header with Logo
                  ZoomIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: Center(
                      child: Container(
                        width: 80, // w-20
                        height: 80, // h-20
                        decoration: BoxDecoration(
                          gradient:
                              AppColors.logoGradient, // from-primary to-accent
                          borderRadius:
                              BorderRadius.circular(24), // rounded-3xl
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ], // shadow-lg
                        ),
                        child: const Icon(
                          LucideIcons.scan, // Scan icon
                          color: Colors.white,
                          size: 40, // w-10 h-10
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // mb-6

                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    from: 20,
                    child: Text(
                      'HOŞ GELDİNİZ',
                      style: AppTypography.display
                          .copyWith(fontSize: 40), // Ensuring display size
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8), // mt-2

                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 300),
                    from: 10,
                    child: Text(
                      "AI Body Scanner'a giriş yapın",
                      style: AppTypography.body.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(
                      height:
                          32), // Replaced Spacer to avoid infinite height in scroll view

                  // Form
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 400),
                    from: 20,
                    child: CustomTextField(
                      placeholder: "E-posta adresiniz",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 20), // gap-5 (20px)

                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 500),
                    from: 20,
                    child: CustomTextField(
                      placeholder: "Şifreniz",
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 16), // mt-4 relative

                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 600),
                    from: 20,
                    child: PrimaryButton(
                      onPressed: widget.onLogin,
                      fullWidth: true,
                      child: const Text("Giriş Yap"),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "veya",
                            style: TextStyle(
                                color: AppColors.mutedForeground, fontSize: 14),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                  ),

                  // Register Option
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 650),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Hesabınız yok mu?",
                            style: TextStyle(color: AppColors.mutedForeground)),
                        TextButton(
                          onPressed: widget.onRegister,
                          child: const Text("Kayıt Olun",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Social Login
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 700),
                    child: Column(
                      children: [
                        SocialLoginButton(
                          icon: SvgPicture.string(
                            '''<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M19.8 10.2273C19.8 9.51818 19.7364 8.83636 19.6182 8.18182H10.2V12.05H15.6109C15.3818 13.3 14.6727 14.3591 13.6091 15.0682V17.5773H16.8273C18.7091 15.8364 19.8 13.2727 19.8 10.2273Z" fill="#4285F4"/>
<path d="M10.2 20C12.9 20 15.1727 19.1045 16.8273 17.5773L13.6091 15.0682C12.7091 15.6682 11.5636 16.0227 10.2 16.0227C7.59545 16.0227 5.38182 14.2636 4.58636 11.9H1.25455V14.4909C2.90455 17.7591 6.30909 20 10.2 20Z" fill="#34A853"/>
<path d="M4.58636 11.9C4.38636 11.3 4.27273 10.6591 4.27273 10C4.27273 9.34091 4.38636 8.7 4.58636 8.1V5.50909H1.25455C0.572727 6.85909 0.2 8.38636 0.2 10C0.2 11.6136 0.572727 13.1409 1.25455 14.4909L4.58636 11.9Z" fill="#FBBC04"/>
<path d="M10.2 3.97727C11.6818 3.97727 13.0182 4.48182 14.0636 5.47273L16.9091 2.62727C15.1682 0.986364 12.8955 0 10.2 0C6.30909 0 2.90455 2.24091 1.25455 5.50909L4.58636 8.1C5.38182 5.73636 7.59545 3.97727 10.2 3.97727Z" fill="#EA4335"/>
</svg>''',
                            width: 20,
                            height: 20,
                          ),
                          text: "Google ile Giriş",
                          onPressed: widget.onLogin,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
