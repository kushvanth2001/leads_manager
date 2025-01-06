import 'package:flutter/material.dart';

class EasyLoadingWidget extends StatefulWidget {
  final Widget child;

  EasyLoadingWidget({required this.child});

  @override
  _EasyLoadingWidgetState createState() => _EasyLoadingWidgetState();
}

class _EasyLoadingWidgetState extends State<EasyLoadingWidget> {
  @override
  void initState() {
    super.initState();
    // Start EasyLoading when the widget is built
   // EasyLoading.show(status: 'Loading...');
    
  }

  @override
  void dispose() {
    // Stop EasyLoading when the widget is disposed of
  //  EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}