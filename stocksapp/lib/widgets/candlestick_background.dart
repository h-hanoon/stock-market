import 'dart:math';
import 'package:flutter/material.dart';

class CandlestickBackground extends StatelessWidget {
  const CandlestickBackground({super.key, this.opacity = 0.16});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _CandlestickPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  static final Random _rng = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    const bullColor = Color(0xFF2ECC71);
    const bearColor = Color(0xFFE74C3C);

    final candleWidth = size.width / 26;
    double lastClose = size.height * 0.55;

    for (int i = 0; i < 26; i++) {
      final x = candleWidth * i + candleWidth / 2;
      final isBull = _rng.nextBool();
      final bodyHeight = size.height * (0.04 + _rng.nextDouble() * 0.12);
      final wickHeight = bodyHeight * (1.4 + _rng.nextDouble());

      final open = lastClose;
      final close = isBull ? open - bodyHeight : open + bodyHeight;
      lastClose = close;

      final top = min(open, close);
      final bottom = max(open, close);
      final mid = (top + bottom) / 2;

      final paint = Paint()
        ..color = isBull ? bullColor : bearColor
        ..strokeWidth = 1.4;

      canvas.drawLine(
        Offset(x, mid - wickHeight / 2),
        Offset(x, mid + wickHeight / 2),
        paint,
      );

      canvas.drawRect(
        Rect.fromLTWH(x - candleWidth * 0.28, top, candleWidth * 0.56, max(bottom - top, 2)),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) => false;
}
