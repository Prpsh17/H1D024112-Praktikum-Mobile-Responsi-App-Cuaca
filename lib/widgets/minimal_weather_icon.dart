import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/weather_code_mapper.dart';

/// Ikon cuaca bergaya line-art minimalis (ketebalan garis seragam)
/// yang dibuat dengan CustomPainter agar identik dengan estetika template UI.
class MinimalWeatherIcon extends StatelessWidget {
  final int weatherCode;
  final double size;
  final Color color;

  const MinimalWeatherIcon({
    super.key,
    required this.weatherCode,
    this.size = 48,
    this.color = AppTheme.inkPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MinimalWeatherPainter(
          type: WeatherCodeMapper.iconType(weatherCode),
          color: color,
        ),
      ),
    );
  }
}

class _MinimalWeatherPainter extends CustomPainter {
  final WeatherIconType type;
  final Color color;

  const _MinimalWeatherPainter({
    required this.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = (size.width * 0.042).clamp(1.4, 2.2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case WeatherIconType.sunny:
        _drawSun(
          canvas,
          Offset(size.width * 0.5, size.height * 0.5),
          size.width * 0.19,
          size.width * 0.30,
          size.width * 0.40,
          paint,
        );
        break;
      case WeatherIconType.cloudy:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.10,
            size.height * 0.28,
            size.width * 0.80,
            size.height * 0.48,
          ),
          paint,
        );
        break;
      case WeatherIconType.partlyCloudy:
        _drawPartialSun(
          canvas,
          Offset(size.width * 0.34, size.height * 0.38),
          size.width * 0.13,
          size.width * 0.21,
          size.width * 0.28,
          paint,
        );
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.18,
            size.height * 0.34,
            size.width * 0.74,
            size.height * 0.44,
          ),
          paint,
          fillMask: true,
        );
        break;
      case WeatherIconType.fog:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.14,
            size.height * 0.18,
            size.width * 0.72,
            size.height * 0.42,
          ),
          paint,
        );
        _drawFogLines(canvas, size, paint);
        break;
      case WeatherIconType.drizzle:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.14,
            size.height * 0.16,
            size.width * 0.72,
            size.height * 0.42,
          ),
          paint,
        );
        _drawRainDrops(canvas, size, paint, heavy: false);
        break;
      case WeatherIconType.rain:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.14,
            size.height * 0.16,
            size.width * 0.72,
            size.height * 0.42,
          ),
          paint,
        );
        _drawRainDrops(canvas, size, paint, heavy: true);
        break;
      case WeatherIconType.snow:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.14,
            size.height * 0.16,
            size.width * 0.72,
            size.height * 0.42,
          ),
          paint,
        );
        _drawSnowDots(canvas, size, paint);
        break;
      case WeatherIconType.thunderstorm:
        _drawCloud(
          canvas,
          Rect.fromLTWH(
            size.width * 0.14,
            size.height * 0.15,
            size.width * 0.72,
            size.height * 0.42,
          ),
          paint,
        );
        _drawLightning(canvas, size, paint);
        break;
    }
  }

  void _drawSun(
    Canvas canvas,
    Offset center,
    double radius,
    double rayInner,
    double rayOuter,
    Paint paint,
  ) {
    canvas.drawCircle(center, radius, paint);
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final start = Offset(
        center.dx + rayInner * math.cos(angle),
        center.dy + rayInner * math.sin(angle),
      );
      final end = Offset(
        center.dx + rayOuter * math.cos(angle),
        center.dy + rayOuter * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawPartialSun(
    Canvas canvas,
    Offset center,
    double radius,
    double rayInner,
    double rayOuter,
    Paint paint,
  ) {
    canvas.drawCircle(center, radius, paint);
    // Sinar matahari di sisi atas dan kiri (tidak tertutup awan)
    const angles = [
      math.pi * 0.85,
      math.pi * 1.10,
      math.pi * 1.35,
      math.pi * 1.60,
      math.pi * 1.85,
    ];
    for (final angle in angles) {
      final start = Offset(
        center.dx + rayInner * math.cos(angle),
        center.dy + rayInner * math.sin(angle),
      );
      final end = Offset(
        center.dx + rayOuter * math.cos(angle),
        center.dy + rayOuter * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawCloud(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    bool fillMask = false,
  }) {
    final path = Path();
    final left = rect.left;
    final top = rect.top;
    final w = rect.width;
    final h = rect.height;
    final bottom = top + h;

    // Bentuk awan membulat minimalis seperti pada referensi UI
    path.moveTo(left + w * 0.22, bottom);
    path.lineTo(left + w * 0.78, bottom);
    path.cubicTo(
      left + w * 0.96,
      bottom,
      left + w * 1.00,
      top + h * 0.52,
      left + w * 0.82,
      top + h * 0.46,
    );
    path.cubicTo(
      left + w * 0.82,
      top + h * 0.08,
      left + w * 0.44,
      top - h * 0.02,
      left + w * 0.34,
      top + h * 0.30,
    );
    path.cubicTo(
      left + w * 0.14,
      top + h * 0.24,
      left + w * 0.00,
      top + h * 0.56,
      left + w * 0.08,
      top + h * 0.82,
    );
    path.cubicTo(
      left + w * 0.11,
      bottom * 0.99,
      left + w * 0.16,
      bottom,
      left + w * 0.22,
      bottom,
    );
    path.close();

    if (fillMask) {
      final maskPaint = Paint()
        ..color = AppTheme.bgBottom
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, maskPaint);
    }
    canvas.drawPath(path, paint);
  }

  void _drawFogLines(Canvas canvas, Size size, Paint paint) {
    final y1 = size.height * 0.71;
    final y2 = size.height * 0.82;
    canvas.drawLine(
      Offset(size.width * 0.20, y1),
      Offset(size.width * 0.80, y1),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.30, y2),
      Offset(size.width * 0.70, y2),
      paint,
    );
  }

  void _drawRainDrops(
    Canvas canvas,
    Size size,
    Paint paint, {
    required bool heavy,
  }) {
    final xs = heavy ? [0.28, 0.46, 0.64, 0.78] : [0.34, 0.54, 0.72];
    final yStart = size.height * 0.68;
    final length = heavy ? size.height * 0.16 : size.height * 0.10;
    for (final xFactor in xs) {
      final x = size.width * xFactor;
      canvas.drawLine(
        Offset(x, yStart),
        Offset(x - size.width * 0.05, yStart + length),
        paint,
      );
    }
  }

  void _drawSnowDots(Canvas canvas, Size size, Paint paint) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final r = (size.width * 0.032).clamp(1.4, 2.2);
    final offsets = [
      Offset(size.width * 0.32, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.78),
      Offset(size.width * 0.68, size.height * 0.72),
    ];
    for (final offset in offsets) {
      canvas.drawCircle(offset, r, dotPaint);
    }
  }

  void _drawLightning(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width * 0.54, size.height * 0.62)
      ..lineTo(size.width * 0.44, size.height * 0.76)
      ..lineTo(size.width * 0.54, size.height * 0.76)
      ..lineTo(size.width * 0.46, size.height * 0.90);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MinimalWeatherPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
