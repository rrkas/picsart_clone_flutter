import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:picsart_clone/drawpad/draw_painter.dart';
import 'package:picsart_clone/drawpad/draw_point.dart';
import 'package:picsart_clone/drawpad/image_editor.dart';
import 'package:picsart_clone/utils/hor_popup.dart';
import 'package:rxdart/rxdart.dart';

class DrawPad extends StatefulWidget {
  static const routeName = '/drawpad';

  @override
  _DrawPadState createState() => _DrawPadState();
}

class _DrawPadState extends State<DrawPad> {
  List<DrawPoint> _allPoints = [];
  Queue<List<DrawPoint>> _layers = Queue();
  final _pointsStream = BehaviorSubject<List<DrawPoint>>();
  GlobalKey _key = GlobalKey();
  double _strokeWidth = 5;
  Color _strokeColor = Colors.blue;
  IconData _drawTypeIcon = Icons.brush;
  DrawTool _drawTool = DrawTool.brush;
  TextSpan _textSpan;
  File _image;

  final List<IconData> drawTypes = [
    Icons.brush, //solid, rounded edges
    Icons.edit, //solid, no rounded edges
    MaterialCommunityIcons.spray, //blur lines, dotted lines
    FlutterIcons.rectangle_outline_mco, //draw shapes
  ];

  @override
  void dispose() {
    _pointsStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Pad'),
        actions: [
          if (_layers.length > 0) IconButton(icon: Icon(Icons.undo), onPressed: undo),
          if (_allPoints.length > 0)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearCanvas,
            ),
        ],
      ),
      body: GestureDetector(
        key: _key,
        onPanStart: updateStroke,
        onPanUpdate: updateStroke,
        onPanEnd: endStroke,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: StreamBuilder<List<DrawPoint>>(
              stream: _pointsStream.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: DrawPainter(snapshot?.data),
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
                  color: _strokeColor,
                ),
                onPressed: changeStrokeColor,
              ),
              IconButton(
                icon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_strokeWidth.floor()}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      height: 2,
                      color: _strokeColor,
                    ),
                  ],
                ),
                onPressed: changeStrokeWidth,
              ),
              IconButton(
                icon: Icon(
                  FlutterIcons.image_plus_mco,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: addImage,
              ),
              PopupMenuButton(
                captureInheritedThemes: true,
                offset: Offset(-(drawTypes.length / 2) * 24 - 10, -70),
                icon: Icon(
                  _drawTypeIcon,
                  color: Theme.of(context).primaryColor,
                ),
                itemBuilder: (ctx) => [
                  HorizontalPopupMenuWidget(
                    child: Row(
                      children: drawTypes
                          .map(
                            (element) => PopupMenuItem(
                              child: Icon(
                                element,
                                color: Theme.of(context).primaryColor,
                              ),
                              value: drawTypes.indexOf(element),
                            ),
                          )
                          .toList(),
                    ),
                  )
                ],
                onSelected: (idx) {
                  setState(() {
                    _drawTypeIcon = drawTypes[idx];
                    _drawTool = DrawTool.values[idx];
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeStrokeWidth() {
    showAnimatedDialog(
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
                  padding: EdgeInsets.symmetric(vertical: 50 - (_strokeWidth / 2)),
                  child: Transform.rotate(
                    angle: -15 * (pi / 180),
                    alignment: FractionalOffset.center,
                    child: Container(
                      alignment: FractionalOffset.center,
                      width: 130,
                      height: _strokeWidth,
                      decoration: BoxDecoration(
                        color: _strokeColor,
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
                        value: _strokeWidth,
                        onChanged: (val) {
                          setState(() {
                            setState2(() {
                              _strokeWidth = val;
                            });
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text('${_strokeWidth.floor()}'),
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
    showAnimatedDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _strokeColor,
              onColorChanged: (clr) {
                setState(() {
                  _strokeColor = clr;
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
      if (_layers.isNotEmpty) {
        _layers.removeLast();
        if (_layers.isNotEmpty)
          _allPoints = [..._layers.last];
        else
          _allPoints.clear();
      }
    });
    _pointsStream.add(_allPoints);
  }

  void updateStroke(details) {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    print(_drawTool?.toString());
    print((renderBox.globalToLocal(details.globalPosition))?.toString());
    _allPoints.add(
      DrawPoint(
        paint: Paint()
          ..color = _strokeColor
          ..strokeWidth = _strokeWidth,
        offset: renderBox.globalToLocal(details.globalPosition),
        drawTool: _drawTool,
        textSpan: null,
      ),
    );
    _pointsStream.add(_allPoints);
  }

  void endStroke(details) {
    setState(() {
      _allPoints.add(null);
      _layers.addLast([..._allPoints]); //layers.addLast(allPoints); //references the same object, drastic error
    });
    _pointsStream.add(_allPoints);
  }

  void addText() {
    showAnimatedDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog();
      },
    );
  }

  void clearCanvas() {
    setState(() {
      _allPoints.clear();
      _layers.clear();
    });
    _pointsStream.add(_allPoints);
  }

  void addImage() {
    Navigator.of(context).pushNamed(ImageEditor.routeName).then((value) {
      print(value.toString());
    });
  }
}
