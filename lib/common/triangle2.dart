import 'package:flutter/material.dart';

class Triangle2 extends CustomPainter {
  final Color color;
  Triangle2(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;

    var path = Path();
    path.lineTo(0, 10);
    path.lineTo(0, -20);
    path.lineTo(30, 10);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
