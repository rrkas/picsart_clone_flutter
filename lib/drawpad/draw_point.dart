import 'package:flutter/material.dart';

class DrawPoint {
  final Paint paint;
  final Offset offset;
  final DrawTool drawTool;

  DrawPoint({@required this.paint, @required this.offset, @required this.drawTool});
}

enum DrawTool { brush, pencil, spray }
