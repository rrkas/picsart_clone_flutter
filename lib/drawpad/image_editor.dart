import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageEditor extends StatefulWidget {
  static const routeName = 'image-editor';

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () async {
              _image = File((await ImagePicker().getImage(source: ImageSource.gallery)).path);
            },
          ),
        ],
      ),
      body: Center(
        child: _image == null ? Text('Image editor') : Image.file(_image),
      ),
    );
  }
}
