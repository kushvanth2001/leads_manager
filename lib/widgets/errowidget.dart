import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorShowingWidget extends StatefulWidget {
  @override
  _ErrorShowingWidgetState createState() => _ErrorShowingWidgetState();
}

class _ErrorShowingWidgetState extends State<ErrorShowingWidget> {
  String errorMessage = '';

  Future<void> getError() async {
    try {
      final String result =
          await MethodChannel('com.example.myapp/error_Log').invokeMethod('geterror');
      setState(() {
        errorMessage = result ?? 'No error message received';
      });
        _showErrorDialog(errorMessage);
    } on PlatformException catch (e) {
      print(e);
    }
  }
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
              onPressed: () {
                getError();
                print(errorMessage);
              },
              child: Text('Get Error Message'),
            );
  }
}