import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:picsart_clone/drawpad/draw_painter.dart';
import 'package:picsart_clone/drawpad/draw_point.dart';
import 'package:rxdart/rxdart.dart';

class DrawPad extends StatefulWidget {
  @override
  _DrawPadState createState() => _DrawPadState();
}

class _DrawPadState extends State<DrawPad> {
  Queue<List<DrawPoint>> allPoints = Queue();
  Queue<List<DrawPoint>> layers = Queue();
  final pointsStream = BehaviorSubject<Queue<List<DrawPoint>>>();
  GlobalKey key = GlobalKey();
  double strokeWidth = 5;
  Color strokeColor = Colors.blue;
  IconData drawType = Icons.brush;

  final List<IconData> drawTypes = [
    Icons.brush, //solid, rounded edges
    Icons.edit, //solid, no rounded edges
    MaterialCommunityIcons.spray, //blur lines, dotted lines
  ];

  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Pad'),
        actions: [
//          IconButton(icon: Icon(Icons.undo), onPressed: undo),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              allPoints.clear();
              layers.clear();
              pointsStream.add(allPoints);
            },
          ),
        ],
      ),
      body: GestureDetector(
        key: key,
        onPanStart: updateStroke,
        onPanUpdate: updateStroke,
        onPanEnd: (details) {
          print('end');
          if (allPoints.isNotEmpty) {
            allPoints.addLast(allPoints.last..add(null));
          }
          layers.addLast(allPoints.last.where((element) => layers.isEmpty || !layers.last.contains(element)).toList());
//          if (layers.isNotEmpty && layers.last.isNotEmpty && layers.last.last != null) layers.last.add(null);
//          allPoints = Queue.from(layers);
//          pointsStream.add(allPoints);
          print(allPoints.length);
          print(layers.length);
          print(allPoints.last.length);
          print(layers.last.length);
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: StreamBuilder<Queue<List<DrawPoint>>>(
              stream: pointsStream.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: DrawPainter(snapshot?.data?.isEmpty ?? true ? [] : snapshot.data.last),
                );
              }),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.palette,
                  color: strokeColor,
                ),
                onPressed: changeStrokeColor,
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
                onPressed: changeStrokeWidth,
              ),
              IconButton(
                icon: Icon(
                  drawType,
                  color: strokeColor,
                ),
                onPressed: changeDrawTool,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeStrokeWidth() {
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50 - (strokeWidth / 2)),
                  child: Transform.rotate(
                    angle: -15 * (pi / 180),
                    alignment: FractionalOffset.center,
                    child: Container(
                      alignment: FractionalOffset.center,
                      width: 130,
                      height: strokeWidth,
                      decoration: BoxDecoration(
                        color: strokeColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
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
  }

  void changeStrokeColor() {
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
  }

  void undo() {
    setState(() {
      if (layers.isNotEmpty && layers.length > 1) {
        print(allPoints.last.length);
        print(layers.last.length);
        layers.removeLast();
        allPoints = Queue();
        layers.toList().reversed.forEach((element) {
          print(element.length);
          allPoints.addLast(element);
        });
      } else {
        allPoints.clear();
        layers.clear();
      }
      pointsStream.add(allPoints);
      if (allPoints.isNotEmpty) {
        print(allPoints.last.length);
        print(layers.last.length);
      }
    });
  }

  void updateStroke(details) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    if (allPoints.isNotEmpty) {
      allPoints.addLast([
        ...allPoints.last
          ..add(
            DrawPoint(
              paint: Paint()
                ..color = strokeColor
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
              offset: renderBox.globalToLocal(details.globalPosition),
            ),
          )
      ]);
    } else {
      allPoints.addLast([
        DrawPoint(
          paint: Paint()
            ..color = strokeColor
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
          offset: renderBox.globalToLocal(details.globalPosition),
        ),
      ]);
    }
    pointsStream.add(allPoints);
  }

  void changeDrawTool() {}
}
