import 'package:flutter/material.dart';

class Triangle3 extends CustomPainter {
  final Color color;
  Triangle3(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;

    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(10, -10);
    path.lineTo(-10, -10);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
