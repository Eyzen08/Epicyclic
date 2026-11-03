import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1450), () {
      if (!mounted) return;
      final seen = ref.read(localStoreProvider).onboardingSeen;
      context.go(seen ? '/home' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091226),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.1, -0.1),
            radius: 1.1,
            colors: [Color(0xFF16294A), Color(0xFF091226)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              const _SplashMark(size: 126),
              const SizedBox(height: 24),
              const Text(
                'Epicyclic',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Find Your Next Upgrade.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9DB0C9),
                ),
              ),
              const Spacer(flex: 6),
              const StepDots(
                count: 3,
                index: 0,
                activeColor: Color(0xFF4AA3FF),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SplashMarkPainter()),
    );
  }
}

class _SplashMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final unit = size.shortestSide;
    final orbit = unit * 0.40;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.045
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4AA3FF);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: orbit),
      0.4,
      5.4,
      false,
      ring,
    );
    canvas.drawCircle(center, unit * 0.20, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(center.dx + orbit * 0.40, center.dy - orbit * 0.92),
      unit * 0.09,
      Paint()..color = const Color(0xFF4AA3FF),
    );
    canvas.drawCircle(
      Offset(center.dx - orbit * 0.92, center.dy + orbit * 0.40),
      unit * 0.065,
      Paint()..color = const Color(0xFFB9D8FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.count,
    required this.index,
    this.activeColor,
  });

  final int count;
  final int index;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 10 : 9,
            height: i == index ? 10 : 9,
            decoration: BoxDecoration(
              color: i == index
                  ? (activeColor ?? const Color(0xFF2F8BF7))
                  : const Color(0xFF4B5563),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
