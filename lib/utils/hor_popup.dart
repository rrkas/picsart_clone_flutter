import 'package:flutter/material.dart';

class HorizontalPopupMenuWidget<T> extends PopupMenuEntry<T> {
  const HorizontalPopupMenuWidget({Key key, this.height, this.child}) : super(key: key);

  @override
  final Widget child;

  @override
  final double height;

  @override
  bool get enabled => false;

  @override
  _PopupMenuWidgetState createState() => new _PopupMenuWidgetState();

  @override
  bool represents(T value) => true;
}

class _PopupMenuWidgetState extends State<HorizontalPopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}
