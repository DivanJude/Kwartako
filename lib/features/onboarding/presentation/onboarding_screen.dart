import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/finance_provider.dart';
import '../../navigation/presentation/main_navigation_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = [
    OnboardingItem(
      title: 'Daily Tracking',
      tagline: 'Step 1 of the Weekly Loop',
      description: 'Log expenses easily and categorize them under Food, School, Wants, or Emergency. Knowledge is power.',
      illustrationType: IllustrationType.wallet,
      bulletPoints: [
        'Track spending in 3 seconds',
        'Sort transactions by simple categories',
        'Identify unnecessary impulse purchases'
      ],
    ),
    OnboardingItem(
      title: 'Saturday Night Reflections',
      tagline: 'Step 2 of the Weekly Loop',
      description: 'Every Saturday, pause and look back. KwartaKo acts as your mentor, reviewing your spending and savings.',
      illustrationType: IllustrationType.charts,
      bulletPoints: [
        'Compare performance with last week',
        'Uncover hidden "small expense" leaks',
        'Receive honest feedback from your coach'
      ],
    ),
    OnboardingItem(
      title: 'Sunday Budget Planning',
      tagline: 'Step 3 of the Weekly Loop',
      description: 'Look forward. Set your weekly allowance and let KwartaKo recommend the best allocation percentages.',
      illustrationType: IllustrationType.goals,
      bulletPoints: [
        'Plan allowance allocation dynamically',
        'Adjust percentages with interactive sliders',
        'Start Monday prepared and in control'
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _handleButtonPress() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Record onboarding completion status in database settings
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.completeOnboarding();

      // End of Onboarding - transition to the MainNavigationContainer
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationContainer(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final glassTheme = Theme.of(context).extension<GlassThemeExtension>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _slides.length - 1,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(
                      _currentPage == _slides.length - 1 ? '' : 'Skip',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Page Slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Vector Illustration Container
                          Container(
                            height: size.height * 0.28,
                            width: size.width * 0.75,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: glassTheme?.cardDecoration ?? BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CustomPaint(
                                painter: IllustrationPainter(slide.illustrationType),
                              ),
                            ),
                          ),

                          // Text Header & Tagline
                          Text(
                            slide.tagline.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Content Bullet Points
                          Column(
                            children: slide.bulletPoints.map((bullet) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppColors.successGreen,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        bullet,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section (Indicators + CTA Button)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Slide Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleButtonPress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1 ? 'Get Started' : 'Next Step',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
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
      ),
    );
  }
}

enum IllustrationType {
  wallet,
  charts,
  goals,
}

class OnboardingItem {
  final String title;
  final String tagline;
  final String description;
  final IllustrationType illustrationType;
  final List<String> bulletPoints;

  OnboardingItem({
    required this.title,
    required this.tagline,
    required this.description,
    required this.illustrationType,
    required this.bulletPoints,
  });
}

// Draw premium vector placeholders inside Flutter
class IllustrationPainter extends CustomPainter {
  final IllustrationType type;

  IllustrationPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    if (type == IllustrationType.wallet) {
      // 1. Draw Wallet Illustration (Daily Tracking)
      // Background glow
      paint.color = AppColors.primaryBlue.withOpacity(0.1);
      canvas.drawCircle(center, size.width * 0.35, paint);

      // Wallet body base
      final walletRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 120, height: 80),
        const Radius.circular(16),
      );
      paint.shader = AppColors.accentGradient.createShader(walletRect.outerRect);
      canvas.drawRRect(walletRect, paint);

      // Wallet flap
      final flapRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 10, center.dy - 20, 50, 40),
        const Radius.circular(8),
      );
      paint.shader = null;
      paint.color = AppColors.surface;
      canvas.drawRRect(flapRect, paint);

      // Wallet lock button
      paint.color = AppColors.accentCyan;
      canvas.drawCircle(Offset(center.dx + 35, center.dy), 6, paint);

      // Floating Coins
      paint.color = AppColors.warningYellow;
      canvas.drawCircle(Offset(center.dx - 30, center.dy - 50), 10, paint);
      paint.color = AppColors.warningYellow.withOpacity(0.7);
      canvas.drawCircle(Offset(center.dx + 40, center.dy - 60), 8, paint);
      paint.color = AppColors.warningYellow.withOpacity(0.5);
      canvas.drawCircle(Offset(center.dx - 55, center.dy + 10), 12, paint);
    } else if (type == IllustrationType.charts) {
      // 2. Draw Financial Charts (Reflections)
      // Background glow
      paint.color = AppColors.accentCyan.withOpacity(0.08);
      canvas.drawCircle(center, size.width * 0.35, paint);

      // Draw horizontal reference gridlines
      paint.color = Colors.white.withOpacity(0.05);
      paint.strokeWidth = 1.0;
      paint.style = PaintingStyle.stroke;
      for (int i = 0; i < 4; i++) {
        final y = center.dy - 40 + i * 25;
        canvas.drawLine(Offset(center.dx - 70, y), Offset(center.dx + 70, y), paint);
      }

      // Draw Bar charts (Weekly bars)
      paint.style = PaintingStyle.fill;
      final barWidth = 14.0;
      final barColors = [AppColors.textSecondary, AppColors.primaryBlue, AppColors.secondaryBlue, AppColors.successGreen];
      final barHeights = [40.0, 70.0, 55.0, 90.0];

      for (int i = 0; i < 4; i++) {
        final x = center.dx - 60 + i * 32;
        final h = barHeights[i];
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, center.dy + 40 - h, barWidth, h),
          const Radius.circular(4),
        );
        paint.color = barColors[i].withOpacity(0.85);
        canvas.drawRRect(barRect, paint);
      }

      // Draw trending line overlay
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3.0;
      paint.color = AppColors.accentCyan;
      final linePath = Path()
        ..moveTo(center.dx - 53, center.dy + 15)
        ..quadraticBezierTo(
          center.dx - 20, center.dy - 35,
          center.dx + 11, center.dy - 5,
        )
        ..lineTo(center.dx + 43, center.dy - 45);
      canvas.drawPath(linePath, paint);

      // Draw glowing end point of trendline
      paint.style = PaintingStyle.fill;
      paint.color = AppColors.accentCyan;
      canvas.drawCircle(Offset(center.dx + 43, center.dy - 45), 6, paint);
    } else {
      // 3. Draw Goals Target (Sunday Planning)
      // Background glow
      paint.color = AppColors.successGreen.withOpacity(0.08);
      canvas.drawCircle(center, size.width * 0.35, paint);

      // Draw concentric target circles
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4.0;
      paint.color = AppColors.primaryBlue.withOpacity(0.4);
      canvas.drawCircle(center, 60, paint);

      paint.color = AppColors.secondaryBlue.withOpacity(0.6);
      canvas.drawCircle(center, 40, paint);

      paint.color = AppColors.accentCyan;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, 18, paint);

      // Draw Arrow hitting center
      final arrowPath = Path();
      arrowPath.moveTo(center.dx + 65, center.dy - 65); // Arrow tail
      arrowPath.lineTo(center.dx + 8, center.dy - 8); // Arrow tip
      
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4.0;
      paint.color = Colors.white;
      canvas.drawPath(arrowPath, paint);

      // Arrow tip head
      final headPath = Path()
        ..moveTo(center.dx + 8, center.dy - 8)
        ..lineTo(center.dx + 22, center.dy - 8)
        ..lineTo(center.dx + 8, center.dy - 22)
        ..close();
      paint.style = PaintingStyle.fill;
      paint.color = AppColors.successGreen;
      canvas.drawPath(headPath, paint);

      // Star decoration
      paint.color = AppColors.warningYellow;
      _drawStar(canvas, Offset(center.dx - 50, center.dy - 30), 8, paint);
      _drawStar(canvas, Offset(center.dx + 40, center.dy + 40), 6, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset position, double radius, Paint paint) {
    // We can draw simple cross/star shapes with direct lines
    final starPath = Path()
      ..moveTo(position.dx - radius, position.dy)
      ..lineTo(position.dx + radius, position.dy)
      ..moveTo(position.dx, position.dy - radius)
      ..lineTo(position.dx, position.dy + radius);
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
