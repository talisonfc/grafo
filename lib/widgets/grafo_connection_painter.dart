import 'package:flutter/material.dart';

class GrafoConnectionPainer extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool showBoundary, isHover, isSelected;

  GrafoConnectionPainer(
      {required this.start,
      required this.end,
      this.showBoundary = false,
      this.isHover = false,
      this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isHover || isSelected ? Colors.blue : Colors.red
      ..strokeWidth = isHover || isSelected ? 4 : 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    // to.forEach((element) {
    path.lineTo(end.dx, end.dy);
    // });

    if (showBoundary) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()
            ..color = Colors.grey
            ..style = PaintingStyle.stroke);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
