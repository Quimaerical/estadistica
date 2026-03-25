import 'dart:math';
import 'package:flutter/material.dart';

/// Un widget reutilizable que muestra ambas campanas de Gauss (H0 y H1),
/// traza el valor crítico y sombrea las áreas de Error Tipo I (Alpha) y Tipo II (Beta).
class HypothesisGraph extends StatelessWidget {
  final double meanH0;
  final double meanH1;
  final double stdDev;
  final double criticalValue;
  final bool isRightTailed;

  const HypothesisGraph({
    Key? key,
    required this.meanH0,
    required this.meanH1,
    required this.stdDev,
    required this.criticalValue,
    required this.isRightTailed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5, // Proporción ancha para ver ambas colas claramente
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          size: Size.infinite,
          painter: _HypothesisGraphPainter(
            meanH0: meanH0,
            meanH1: meanH1,
            stdDev: stdDev,
            criticalValueX: criticalValue,
            isRightTailed: isRightTailed,
          ),
        ),
      ),
    );
  }
}

class _HypothesisGraphPainter extends CustomPainter {
  final double meanH0;
  final double meanH1;
  final double stdDev;
  final double criticalValueX;
  final bool isRightTailed;

  _HypothesisGraphPainter({
    required this.meanH0,
    required this.meanH1,
    required this.stdDev,
    required this.criticalValueX,
    required this.isRightTailed,
  });

  double _normalPdf(double x, double mean, double sd) {
    final variance = sd * sd;
    final exponent = -pow(x - mean, 2) / (2 * variance);
    return (1.0 / (sd * sqrt(2 * pi))) * exp(exponent);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Coordenadas lógicas: abarcar ambas curvas (mean +- 4*sigma)
    final double minX = min(meanH0, meanH1) - 4 * stdDev;
    final double maxX = max(meanH0, meanH1) + 4 * stdDev;
    final double rangeX = maxX - minX;

    final double maxY = max(
      _normalPdf(meanH0, meanH0, stdDev), 
      _normalPdf(meanH1, meanH1, stdDev)
    ) * 1.15; // 15% de padding superior

    Offset toCanvas(double x, double y) {
      final cx = (x - minX) / rangeX * size.width;
      final cy = size.height - (y / maxY * size.height);
      return Offset(cx, cy);
    }

    final Path pathH0 = Path();
    final Path pathH1 = Path();
    final Path alphaPath = Path();
    final Path betaPath = Path();

    bool alphaStarted = false;
    bool betaStarted = false;

    final int points = 300; // Alta resolución para la curva suave
    final double step = rangeX / points;

    for (int i = 0; i <= points; i++) {
      final double x = minX + i * step;
      final double yH0 = _normalPdf(x, meanH0, stdDev);
      final double yH1 = _normalPdf(x, meanH1, stdDev);

      if (i == 0) {
        pathH0.moveTo(toCanvas(x, yH0).dx, toCanvas(x, yH0).dy);
        pathH1.moveTo(toCanvas(x, yH1).dx, toCanvas(x, yH1).dy);
      } else {
        pathH0.lineTo(toCanvas(x, yH0).dx, toCanvas(x, yH0).dy);
        pathH1.lineTo(toCanvas(x, yH1).dx, toCanvas(x, yH1).dy);
      }

      // Sombras de Alpha (Error Tipo I, debajo de H0, a la derecha del valor crítico si es right-tailed)
      bool inAlphaRegion = isRightTailed ? (x >= criticalValueX) : (x <= criticalValueX);
      if (inAlphaRegion) {
        if (!alphaStarted) {
          alphaPath.moveTo(toCanvas(x, 0).dx, toCanvas(x, 0).dy);
          alphaPath.lineTo(toCanvas(x, yH0).dx, toCanvas(x, yH0).dy);
          alphaStarted = true;
        } else {
          alphaPath.lineTo(toCanvas(x, yH0).dx, toCanvas(x, yH0).dy);
        }
      } else if (alphaStarted) {
        alphaPath.lineTo(toCanvas(x - step, 0).dx, toCanvas(x - step, 0).dy);
        alphaStarted = false;
      }

      // Sombras de Beta (Error Tipo II, debajo de H1, región de NO rechazo según H0)
      bool inBetaRegion = isRightTailed ? (x <= criticalValueX) : (x >= criticalValueX);
      if (inBetaRegion) {
        if (!betaStarted) {
          betaPath.moveTo(toCanvas(x, 0).dx, toCanvas(x, 0).dy);
          betaPath.lineTo(toCanvas(x, yH1).dx, toCanvas(x, yH1).dy);
          betaStarted = true;
        } else {
          betaPath.lineTo(toCanvas(x, yH1).dx, toCanvas(x, yH1).dy);
        }
      } else if (betaStarted) {
        betaPath.lineTo(toCanvas(x - step, 0).dx, toCanvas(x - step, 0).dy);
        betaStarted = false;
      }
    }

    if (alphaStarted) alphaPath.lineTo(toCanvas(maxX, 0).dx, toCanvas(maxX, 0).dy);
    if (betaStarted) betaPath.lineTo(toCanvas(maxX, 0).dx, toCanvas(maxX, 0).dy);

    // Pintar áreas bajo las curvas
    final Paint alphaPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final Paint betaPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawPath(alphaPath, alphaPaint);
    canvas.drawPath(betaPath, betaPaint);

    // Pintar contornos
    final Paint paintH0 = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint paintH1 = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(pathH0, paintH0);
    canvas.drawPath(pathH1, paintH1);

    // Línea de valor crítico (Punteada)
    final double cvCanvasX = toCanvas(criticalValueX, 0).dx;
    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(cvCanvasX, 0), Offset(cvCanvasX, size.height), linePaint);

    // Línea base (Eje X)
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()..color = Colors.black45..strokeWidth = 1.5,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 5;
    const int dashSpace = 5;
    double startY = p1.dy;
    while (startY < p2.dy) {
      canvas.drawLine(Offset(p1.dx, startY), Offset(p1.dx, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _HypothesisGraphPainter oldDelegate) {
    return oldDelegate.meanH0 != meanH0 || 
           oldDelegate.meanH1 != meanH1 || 
           oldDelegate.stdDev != stdDev ||
           oldDelegate.criticalValueX != criticalValueX ||
           oldDelegate.isRightTailed != isRightTailed;
  }
}
