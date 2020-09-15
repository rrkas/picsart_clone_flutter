import 'package:flutter/material.dart';
import 'package:picsart_clone/drawpad/drawpad.dart';
import 'package:picsart_clone/drawpad/image_editor.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(elevation: 0.0),
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: DrawPad.routeName,
      routes: {
        DrawPad.routeName: (_) => DrawPad(),
        ImageEditor.routeName: (_) => ImageEditor(),
      },
    );
  }
}
