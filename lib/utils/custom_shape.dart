import 'package:flutter/material.dart';

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    // path.moveTo(-size.width * .5, -size.height);
    // path.lineTo(-size.width, size.height);
    // path.lineTo(size.width * 5 / 6, size.height);

    // path.lineTo(-size.width, size.height);
    path.lineTo(-5, size.height);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(0, size.width * .6, 0, -size.height);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
