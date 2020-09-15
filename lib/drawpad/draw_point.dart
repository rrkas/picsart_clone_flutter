import 'package:flutter/material.dart';

class DrawPoint {
  final Paint paint;
  final TextSpan textSpan;
  final Offset offset;
  final DrawTool drawTool;

  DrawPoint({@required this.paint, @required this.textSpan, @required this.offset, @required this.drawTool});
}

enum DrawTool { brush, pencil, spray, shapes, text }
