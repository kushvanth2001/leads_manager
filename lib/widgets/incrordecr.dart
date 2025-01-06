import 'package:flutter/material.dart';

class IncrementDecrementBar extends StatefulWidget {
  final String title;
  final int? initialValue;
  final ValueChanged<int> onChanged;

  IncrementDecrementBar({
    required this.title,
    this.initialValue,
    required this.onChanged,
  });

  @override
  _IncrementDecrementBarState createState() => _IncrementDecrementBarState();
}

class _IncrementDecrementBarState extends State<IncrementDecrementBar> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue ?? 0; // Set initial value to zero if null
  }

  void _increment() {
    setState(() {
      _counter++;
      widget.onChanged(_counter);
    });
  }

  void _decrement() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        widget.onChanged(_counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _decrement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade200, // Background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(Icons.remove),
            ),
            SizedBox(width: 20),
            Text(
              '$_counter',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: _increment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400, // Background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}