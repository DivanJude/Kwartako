import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/state/finance_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../navigation/presentation/main_navigation_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _timerFinished = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.75, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    // Start transition timer
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _timerFinished = true;
        });
        _checkNavigation();
      }
    });

    // Check if database is already loaded, otherwise listen for load completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<FinanceProvider>(context, listen: false);
        if (provider.isInitialized) {
          _checkNavigation();
        } else {
          provider.addListener(_onProviderUpdate);
        }
      }
    });
  }

  void _onProviderUpdate() {
    if (mounted) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      if (provider.isInitialized) {
        provider.removeListener(_onProviderUpdate);
        _checkNavigation();
      }
    }
  }

  void _checkNavigation() {
    if (_timerFinished && !_navigated && mounted) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      if (provider.isInitialized) {
        _navigated = true;
        _navigateToNextScreen();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    try {
      Provider.of<FinanceProvider>(context, listen: false).removeListener(_onProviderUpdate);
    } catch (_) {}
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (mounted) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final nextScreen = provider.hasCompletedOnboarding
          ? const MainNavigationContainer()
          : const OnboardingScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Soft background light flares
                Positioned(
                  top: size.height * 0.2,
                  left: size.width * 0.15,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.07),
                          blurRadius: 80,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.2,
                  right: size.width * 0.1,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withOpacity(0.05),
                          blurRadius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Content
                Center(
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Custom Geometric Logo
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: LogoPainter(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App Name
                          Text(
                            'KwartaKo',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  foreground: Paint()
                                    ..shader = AppColors.accentGradient.createShader(
                                      const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                    ),
                                ),
                          ),
                          const SizedBox(height: 12),
                          // Tagline
                          Text(
                            'Track today. Improve next week.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// LogoPainter draws a modern geometric "K" combined with a growth chart
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw left vertical stem (representing solid foundation)
    final rect1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.25, size.width * 0.14, size.height * 0.5),
      const Radius.circular(6),
    );
    paint.shader = AppColors.accentGradient.createShader(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.25, size.width * 0.14, size.height * 0.5),
    );
    canvas.drawRRect(rect1, paint);

    // Draw top diagonal stroke (representing incoming income/planning)
    final pathTop = Path();
    pathTop.moveTo(size.width * 0.46, size.height * 0.46);
    pathTop.lineTo(size.width * 0.68, size.height * 0.26);
    pathTop.lineTo(size.width * 0.76, size.height * 0.34);
    pathTop.lineTo(size.width * 0.54, size.height * 0.54);
    pathTop.close();
    
    paint.shader = const LinearGradient(
      colors: [AppColors.accentCyan, AppColors.secondaryBlue],
    ).createShader(Rect.fromLTWH(size.width * 0.46, size.height * 0.26, size.width * 0.3, size.height * 0.28));
    canvas.drawPath(pathTop, paint);

    // Draw bottom diagonal stroke with arrow head (representing saving growth/forward progress)
    final pathBottom = Path();
    pathBottom.moveTo(size.width * 0.46, size.height * 0.52);
    pathBottom.lineTo(size.width * 0.66, size.height * 0.72);
    pathBottom.lineTo(size.width * 0.74, size.height * 0.64);
    pathBottom.lineTo(size.width * 0.54, size.height * 0.44);
    pathBottom.close();
    
    paint.shader = const LinearGradient(
      colors: [AppColors.primaryBlue, AppColors.successGreen],
    ).createShader(Rect.fromLTWH(size.width * 0.46, size.height * 0.44, size.width * 0.28, size.height * 0.28));
    canvas.drawPath(pathBottom, paint);

    // Draw a small decorative accent dot (representing the "coach insight" guiding the user)
    paint.shader = null;
    paint.color = AppColors.successGreen;
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.72), 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
