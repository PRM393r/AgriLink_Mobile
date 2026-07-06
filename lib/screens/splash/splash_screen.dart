import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _loadingFade;

  @override
  void initState() {
    super.initState();

    // Logo animation: scale + fade
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Text animation: slide + fade
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Loading animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Logo appears
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();

    // 2. Text slides up
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _textController.forward();

    // 3. Loading indicator
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _loadingController.forward();

    // 4. Wait then navigate
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkLogin();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B4332),
              Color(0xFF2D6A4F),
              Color(0xFF40916C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.canvas.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.canvas.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with scale + fade
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App name slide up + fade
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Text(
                        AppStrings.appName,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.canvas,
                          letterSpacing: 2.0,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle delayed fade
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      AppStrings.loginSubtitle,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.canvas.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Loading indicator
                  FadeTransition(
                    opacity: _loadingFade,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.canvas.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
