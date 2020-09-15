import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:picsart_clone/drawpad/draw_point.dart';

class DrawPainter extends CustomPainter {
  final List<DrawPoint> _points;
  DrawPainter(this._points);

  @override
  void paint(Canvas canvas, Size size) {
    if (_points == null) return;
    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] == null) continue;
      if (_points[i].drawTool == DrawTool.brush) {
        _points[i].paint.strokeCap = StrokeCap.round;
      } else if (_points[i].drawTool == DrawTool.pencil) {
        _points[i].paint.strokeCap = StrokeCap.square;
      }
      if (_points[i].drawTool == DrawTool.brush || _points[i].drawTool == DrawTool.pencil) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i].offset, _points[i + 1].offset, _points[i].paint);
        } else if (_points[i] != null && _points[i + 1] == null) {
          canvas.drawPoints(PointMode.points, [_points[i].offset], _points[i].paint);
        }
      } else if (_points[i].drawTool == DrawTool.spray) {
        final density = 20;
        final radius = 5;
        for (int j = 0; j < density; j++) {
          canvas.drawPoints(
            PointMode.points,
            [
              Offset(
                _points[i].offset.dx + Random().nextInt(radius.floor()) * 1.0,
                _points[i].offset.dy + Random().nextInt(radius.floor()) * 1.0,
              )
            ],
            _points[i].paint
              ..strokeWidth = 0.5
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
//    TextSpan span = new TextSpan(text: 'Yrfc', style: TextStyle(color: Colors.indigo));
//    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
//    tp.layout();
//    tp.paint(canvas, new Offset(5.0, 5.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
