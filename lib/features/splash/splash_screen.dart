import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/screens/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _orbit1;
  late AnimationController _orbit2;
  late AnimationController _ripple;
  late AnimationController _pulse;
  late AnimationController _load;
  late AnimationController _particle;

  static const Color _g1 = Color(0xFF00C853);
  static const Color _g2 = Color(0xFF69F0AE);
  static const Color _g3 = Color(0xFF1DE9B6);

  @override
  void initState() {
    super.initState();
    _orbit1  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _orbit2  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
    _ripple  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _pulse   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _particle= AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _load    = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..forward();

    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        Navigator.pushReplacement(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const AuthScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
      }
    });
  }

  @override
  void dispose() {
    _orbit1.dispose(); _orbit2.dispose(); _ripple.dispose();
    _pulse.dispose();  _load.dispose();  _particle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE8FFF4),
              Color(0xFFB2FFD9),
              Color(0xFF69F0AE),
              Color(0xFF00E676),
            ],
            stops: [0.0, 0.25, 0.5, 0.78, 1.0],
          ),
        ),
        child: Stack(
          children: [

            CustomPaint(
              size: size,
              painter: _HexPainter(),
            ),

            AnimatedBuilder(
              animation: _particle,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ParticlePainter(_particle.value),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _ripple,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: List.generate(5, (i) {
                    final t = (_ripple.value + i / 5.0) % 1.0;
                    final r = 90.0 + t * 180.0;
                    final op = (1.0 - t) * 0.4;
                    return Container(
                      width: r * 2, height: r * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _g1.withOpacity(op),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _orbit1,
                builder: (_, __) => Transform.rotate(
                  angle: _orbit1.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _ArcOrbitPainter(
                      color: _g1,
                      arcCount: 3,
                      dotCount: 6,
                      lineOpacity: 0.35,
                      dotOpacity: 0.9,
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _orbit2,
                builder: (_, __) => Transform.rotate(
                  angle: -_orbit2.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(210, 210),
                    painter: _ArcOrbitPainter(
                      color: _g3,
                      arcCount: 4,
                      dotCount: 8,
                      lineOpacity: 0.25,
                      dotOpacity: 0.7,
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) {
                  return Container(
                    width: 148 + _pulse.value * 8,
                    height: 148 + _pulse.value * 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: _g1.withOpacity(0.7 + _pulse.value * 0.25),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _g1.withOpacity(0.25 + _pulse.value * 0.3),
                          blurRadius: 30 + _pulse.value * 30,
                          spreadRadius: 4 + _pulse.value * 8,
                        ),
                        BoxShadow(
                          color: _g2.withOpacity(0.15 + _pulse.value * 0.2),
                          blurRadius: 60 + _pulse.value * 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(26),
                    child: child,
                  );
                },
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.2, 0.2), duration: 1000.ms, curve: Curves.elasticOut)
                .fade(duration: 600.ms),

            Align(
              alignment: const Alignment(0, 0.44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF00796B), Color(0xFF00C853), Color(0xFF1DE9B6)],
                    ).createShader(b),
                    child: const Text(
                      'AeroCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                      ),
                    ),
                  )
                      .animate()
                      .fade(delay: 400.ms, duration: 700.ms)
                      .slideY(begin: 0.4, delay: 400.ms, duration: 700.ms, curve: Curves.easeOut),

                  const SizedBox(height: 8),

                  Text(
                    'G E S T I O N   M É D I C A L E',
                    style: TextStyle(
                      color: _g1.withOpacity(0.75),
                      fontSize: 11,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fade(delay: 750.ms, duration: 700.ms)
                      .slideY(begin: 0.3, delay: 750.ms, duration: 600.ms),
                ],
              ),
            ),

            Align(
              alignment: const Alignment(0, 0.83),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 240,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AnimatedBuilder(
                      animation: _load,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _load.value,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF1DE9B6), Color(0xFF00FF88)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initialisation du système...',
                    style: TextStyle(
                      color: _g1.withOpacity(0.65),
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fade(delay: 1000.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcOrbitPainter extends CustomPainter {
  final Color color;
  final int arcCount;
  final int dotCount;
  final double lineOpacity;
  final double dotOpacity;

  const _ArcOrbitPainter({
    required this.color,
    required this.arcCount,
    required this.dotCount,
    required this.lineOpacity,
    required this.dotOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;

    for (int a = 0; a < arcCount; a++) {
      final startAngle = (2 * math.pi / arcCount) * a;
      final sweepAngle = math.pi * 0.55;
      final paint = Paint()
        ..color = color.withOpacity(lineOpacity)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweepAngle, false, paint,
      );
    }

    for (int i = 0; i < dotCount; i++) {
      final angle = 2 * math.pi / dotCount * i;
      final isMain = i % 2 == 0;
      final dotPaint = Paint()
        ..color = color.withOpacity(dotOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isMain ? 4 : 2);
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        isMain ? 5.0 : 3.0,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcOrbitPainter old) =>
      old.color != color || old.arcCount != arcCount;
}

class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C853).withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const r = 32.0;
    const h = r * 1.732;
    const w = r * 2;

    for (double y = -r; y < size.height + r; y += h) {
      for (double x = -r; x < size.width + r; x += w * 1.5) {
        final off = (y ~/ h % 2 == 0) ? 0.0 : w * 0.75;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = math.pi / 180 * (60 * i - 30);
          final px = x + off + r * math.cos(a);
          final py = y + r * math.sin(a);
          if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 40; i++) {
      final px = rng.nextDouble() * size.width;
      final py = rng.nextDouble() * size.height;
      final phase = rng.nextDouble();
      final progress = (t + phase) % 1.0;
      final opacity = math.sin(progress * math.pi) * 0.4;
      final radius = 1.5 + rng.nextDouble() * 3;
      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()
          ..color = const Color(0xFF00C853).withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}
