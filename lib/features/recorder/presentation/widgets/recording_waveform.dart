import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecordingWaveform extends StatefulWidget {
  const RecordingWaveform({
    super.key,
    required this.isRecording,
    required this.hasRecording,
  });

  final bool isRecording;
  final bool hasRecording;

  @override
  State<RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<RecordingWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didUpdateWidget(covariant RecordingWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isRecording) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveformPainter(
              progress: _controller.value,
              isRecording: widget.isRecording,
              hasRecording: widget.hasRecording,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.progress,
    required this.isRecording,
    required this.hasRecording,
  });

  final double progress;
  final bool isRecording;
  final bool hasRecording;

  static const _bars = [
    .22,
    .40,
    .30,
    .58,
    .44,
    .72,
    .50,
    .84,
    .48,
    .68,
    .36,
    .56,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = BorderRadius.circular(28).toRRect(rect);
    final active = isRecording || hasRecording;

    canvas.drawRRect(radius, Paint()..color = const Color(0xFFF5F5F7));
    _drawBars(canvas, size, active);
    _drawPlayhead(canvas, size, active);
  }

  void _drawBars(Canvas canvas, Size size, bool active) {
    final color = active ? const Color(0xFF252D46) : const Color(0xFFB8B8BE);
    final paint = Paint()
      ..color = color.withAlpha(((active ? .76 : .42) * 255).round())
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    final centerY = size.height / 2;
    final gap = size.width / (_bars.length + 1);
    for (var i = 0; i < _bars.length; i++) {
      final pulse = isRecording ? math.sin((progress * math.pi * 2) + i) : 0;
      final height = size.height * (_bars[i] + (pulse * .06)) * .46;
      final x = gap * (i + 1);
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  void _drawPlayhead(Canvas canvas, Size size, bool active) {
    final x = size.width / 2;
    final color = active ? const Color(0xFF252D46) : const Color(0xFF8E8E93);
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, 24), Offset(x, size.height - 24), linePaint);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(x, 18), 4, dotPaint);
    canvas.drawCircle(Offset(x, size.height - 18), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.hasRecording != hasRecording;
  }
}
