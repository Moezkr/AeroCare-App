import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiAssistantOverlay extends StatefulWidget {
  final bool isListening;
  final bool isAiThinking;
  final bool isSpeaking;
  final VoidCallback onClose;

  const AiAssistantOverlay({
    super.key,
    required this.isListening,
    required this.isAiThinking,
    required this.isSpeaking,
    required this.onClose,
  });

  @override
  State<AiAssistantOverlay> createState() => _AiAssistantOverlayState();
}

class _AiAssistantOverlayState extends State<AiAssistantOverlay>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _radarCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _scanCtrl;

  static const Color _cyan   = Color(0xFF00FF88);
  static const Color _blue   = Color(0xFF00C853);
  static const Color _violet = Color(0xFF1B5E20);
  static const Color _pink   = Color(0xFF69F0AE);

  final math.Random _rng = math.Random(42);

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _radarCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    _waveCtrl.dispose();
    _particleCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  Color get _stateColor {
    if (widget.isListening) return _cyan;
    if (widget.isAiThinking) return _violet;
    if (widget.isSpeaking) return _pink;
    return _blue;
  }

  String get _stateLabel {
    if (widget.isListening) return 'Je vous écoute...';
    if (widget.isAiThinking) return 'Analyse des données en cours...';
    if (widget.isSpeaking) return "L'IA vous répond...";
    return 'Initialisation...';
  }

  String get _stateBadge {
    if (widget.isListening) return 'ENREGISTREMENT';
    if (widget.isAiThinking) return 'TRAITEMENT IA';
    if (widget.isSpeaking) return 'RÉPONSE AUDIO';
    return 'EN ATTENTE';
  }

  IconData get _stateIcon {
    if (widget.isListening) return Icons.mic_rounded;
    if (widget.isAiThinking) return Icons.psychology_rounded;
    if (widget.isSpeaking) return Icons.volume_up_rounded;
    return Icons.auto_awesome;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.4,
          colors: [
            const Color(0xFF0A0A1A),
            const Color(0xFF050510),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          _HexGrid(),

          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(size.width, size.height),
              painter: _ParticlePainter(_particleCtrl.value, _stateColor, _rng),
            ),
          ),

          if (widget.isAiThinking)
            Center(
              child: AnimatedBuilder(
                animation: _scanCtrl,
                builder: (_, __) {
                  final opacity = (0.5 + 0.5 * (_scanCtrl.value < 0.5 ? _scanCtrl.value * 2 : (1 - _scanCtrl.value) * 2)).clamp(0.0, 1.0);
                  return Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _violet.withOpacity(opacity * 0.5),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                _buildTitleBar(),

                const Spacer(),

                _buildCentralOrb(size),

                const SizedBox(height: 28),

                SizedBox(
                  height: 60,
                  child: Center(
                    child: widget.isListening || widget.isSpeaking
                        ? _buildWaveform()
                        : widget.isAiThinking
                            ? _buildThinkingDots()
                            : const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 16),

                _buildStatusLabel(),

                const Spacer(),

                _buildBottomPanel(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 500.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
  }

  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _stateColor.withOpacity(0.7), width: 1.5),
              gradient: RadialGradient(colors: [
                _stateColor.withOpacity(0.15),
                Colors.transparent,
              ]),
            ),
            child: Icon(_stateIcon, color: _stateColor, size: 20),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2.seconds, color: _stateColor.withOpacity(0.4)),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assistant Médical IA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              AnimatedContainer(
                duration: 300.ms,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _stateColor.withOpacity(0.15),
                  border: Border.all(color: _stateColor.withOpacity(0.4)),
                ),
                child: Text(
                  _stateBadge,
                  style: TextStyle(
                    color: _stateColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
                color: Colors.white.withOpacity(0.06),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
            ),
          ).animate().scale(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildCentralOrb(Size size) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _orbitCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _orbitCtrl.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(260, 260),
                painter: _OrbitRingPainter(_stateColor, dotCount: 8),
              ),
            ),
          ),

          if (widget.isAiThinking)
            AnimatedBuilder(
              animation: _radarCtrl,
              builder: (_, __) => CustomPaint(
                size: const Size(220, 220),
                painter: _RadarPainter(_radarCtrl.value, _violet),
              ),
            ),

          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final scale = 1.0 + _pulseCtrl.value * 0.12;
              final opacity = 0.3 + _pulseCtrl.value * 0.5;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _stateColor.withOpacity(opacity),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),

          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _stateColor.withOpacity(0.3), width: 1),
            ),
          ),

          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              return Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _stateColor.withOpacity(0.25 + _pulseCtrl.value * 0.15),
                      _stateColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _stateColor.withOpacity(0.4 + _pulseCtrl.value * 0.3),
                      blurRadius: 40 + _pulseCtrl.value * 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              );
            },
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Icon(
              _stateIcon,
              key: ValueKey(_stateIcon),
              color: _stateColor,
              size: 48,
              shadows: [Shadow(color: _stateColor, blurRadius: 20)],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 1400.ms)
              .fade(begin: 0.7, end: 1.0, duration: 1400.ms),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    const barCount = 28;
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barCount, (i) {
            final phase = (i / barCount) * 2 * math.pi;
            final t = _waveCtrl.value;
            final height = 8.0 +
                math.sin(phase + t * 2 * math.pi) * 22 +
                math.cos(phase * 1.7 + t * 2 * math.pi * 0.8) * 10;
            final h = height.abs().clamp(6.0, 44.0);

            return Container(
              width: 4,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _stateColor.withOpacity(0.4),
                    _stateColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(color: _stateColor.withOpacity(0.5), blurRadius: 6),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildThinkingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _violet,
            boxShadow: [BoxShadow(color: _violet.withOpacity(0.7), blurRadius: 10)],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
              begin: 0.5,
              end: 1.0,
              duration: 600.ms,
              delay: (i * 120).ms,
              curve: Curves.easeInOut,
            )
            .fade(begin: 0.3, end: 1.0, duration: 600.ms, delay: (i * 120).ms);
      }),
    );
  }

  Widget _buildStatusLabel() {
    return Column(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: _stateColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            shadows: [Shadow(color: _stateColor.withOpacity(0.8), blurRadius: 12)],
          ),
          child: Text(_stateLabel),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3)),

        const SizedBox(height: 10),

        Text(
          widget.isListening
              ? 'Parlez maintenant — je vous écoute'
              : widget.isAiThinking
                  ? 'Requête SQL générée et exécutée...'
                  : widget.isSpeaking
                      ? 'Synthèse vocale en cours...'
                      : '',
          style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 0.4),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusDot(label: 'MICRO', active: widget.isListening, color: _cyan),
          _VerticalDivider(),
          _StatusDot(label: 'MODÈLE IA', active: widget.isAiThinking, color: _violet),
          _VerticalDivider(),
          _StatusDot(label: 'AUDIO', active: widget.isSpeaking, color: _pink),
        ],
      ),
    )
        .animate()
        .fade(duration: 800.ms, delay: 200.ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOut);
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;

  const _StatusDot({required this.label, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : Colors.white12,
            boxShadow: active
                ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)]
                : [],
          ),
        )
            .animate(target: active ? 1.0 : 0.0)
            .scaleXY(begin: 0.7, end: 1.0, duration: 400.ms),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: active ? color.withOpacity(0.9) : Colors.white24,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white10);
  }
}

class _HexGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      painter: _HexGridPainter(),
    );
  }
}

class _HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const r = 28.0;
    const h = r * 1.732;
    const w = r * 2;

    for (double y = -r; y < size.height + r; y += h) {
      for (double x = -r; x < size.width + r; x += w * 1.5) {
        final offset = (y ~/ h % 2 == 0) ? 0.0 : w * 0.75;
        _drawHex(canvas, paint, Offset(x + offset, y), r);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(px, py);
      else path.lineTo(px, py);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitRingPainter extends CustomPainter {
  final Color color;
  final int dotCount;
  const _OrbitRingPainter(this.color, {this.dotCount = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 4;

    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    final dotPaint = Paint()..color = color.withOpacity(0.7);
    for (int i = 0; i < dotCount; i++) {
      final angle = 2 * math.pi / dotCount * i;
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter old) => old.color != color;
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RadarPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    final ringPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(cx, cy), r * i / 3, ringPaint);
    }

    final angle = progress * 2 * math.pi - math.pi / 2;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.0), color.withOpacity(0.5)],
        startAngle: angle - 1.2,
        endAngle: angle,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, sweepPaint);

    canvas.drawCircle(
      Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
      4,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.color != color;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final math.Random rng;

  _ParticlePainter(this.progress, this.color, this.rng);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final r = math.Random(1337);
    for (int i = 0; i < 35; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      final phase = r.nextDouble();
      final t = (progress + phase) % 1.0;
      final opacity = math.sin(t * math.pi).clamp(0.0, 1.0);
      final radius = 1.0 + r.nextDouble() * 2.5;

      paint
        ..color = color.withOpacity(opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}
