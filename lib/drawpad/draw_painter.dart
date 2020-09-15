import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:picsart_clone/drawpad/draw_point.dart';

class DrawPainter extends CustomPainter {
  final List<DrawPoint> _points;
  DrawPainter(this._points);

  @override
  void paint(Canvas canvas, Size size) {
    if (_points == null) return;
    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i].offset, _points[i + 1].offset, _points[i].paint);
      } else if (_points[i] != null && _points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [_points[i].offset], _points[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
