import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:picsart_clone/drawpad/draw_painter.dart';
import 'package:picsart_clone/drawpad/draw_point.dart';
import 'package:rxdart/rxdart.dart';

class DrawPad extends StatefulWidget {
  @override
  _DrawPadState createState() => _DrawPadState();
}

class _DrawPadState extends State<DrawPad> {
  Queue<List<DrawPoint>> points = Queue();
  final pointsStream = BehaviorSubject<Queue<List<DrawPoint>>>();
  GlobalKey key = GlobalKey();
  double strokeWidth = 1;
  Color strokeColor = Colors.blue;

  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  void updateStroke(details) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    if (points.isNotEmpty) {
      points.addLast(
        points.last
          ..add(
            DrawPoint(
              paint: Paint()
                ..color = strokeColor
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
              offset: renderBox.globalToLocal(details.globalPosition),
            ),
          ),
      );
    } else {
      points.addLast([
        DrawPoint(
          paint: Paint()
            ..color = strokeColor
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
          offset: renderBox.globalToLocal(details.globalPosition),
        ),
      ]);
    }
    pointsStream.add(points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PiscArt'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              setState(() {
                if (points.isNotEmpty) points?.removeLast();
                print(points?.length);
                pointsStream.add(points);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              points.clear();
              pointsStream.add(points);
            },
          ),
        ],
      ),
      body: GestureDetector(
        key: key,
        onPanStart: updateStroke,
        onPanUpdate: updateStroke,
        onPanEnd: (details) {
          if (points.isNotEmpty) {
            points.addLast(points.last..add(null));
          } else {
            points.addLast([]);
          }
          pointsStream.add(points);
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: StreamBuilder<Queue<List<DrawPoint>>>(
              stream: pointsStream.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: DrawPainter(snapshot?.data?.isEmpty ? [] : snapshot.data.last),
                );
              }),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.palette,
              color: strokeColor,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: strokeColor,
                        onColorChanged: (clr) {
                          setState(() {
                            strokeColor = clr;
                          });
                        },
                        colorPickerWidth: 300.0,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: true,
                        displayThumbColor: true,
                        showLabel: true,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                        ),
                      ),
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      )
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${strokeWidth.floor()}',
                  style: TextStyle(fontSize: 18),
                ),
                Container(
                  height: 2,
                  color: strokeColor,
                ),
              ],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setState2) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0.0),
                      contentPadding: const EdgeInsets.all(0.0),
                      title: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Choose Brush Size'),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 30,
                                  value: strokeWidth,
                                  onChanged: (val) {
                                    setState(() {
                                      setState2(() {
                                        strokeWidth = val;
                                      });
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text('${strokeWidth.floor()}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        )
                      ],
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
