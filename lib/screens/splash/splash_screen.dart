import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loading = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.main);
    });
  }

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Spacer(),
              Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/moodpulse_logo_icon.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'Logo MoodPulse',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MoodPulse',
                    style: TextStyle(
                      fontSize: 26,
                      height: 34 / 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Catat mood, bangun kebiasaan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 20 / 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E4948),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Semantics(
                label: 'Memuat aplikasi',
                child: AnimatedBuilder(
                  animation: _loading,
                  builder: (context, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final phase = (_loading.value - index / 6) % 1.0;
                      final opacity = 0.4 + 0.6 * (1 - (phase * 2 - 1).abs());
                      return Container(
                        width: 7,
                        height: 7,
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Versi 1.0',
                style: TextStyle(
                  fontSize: 11,
                  height: 14 / 11,
                  color: Color(0xFF6F7978),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
