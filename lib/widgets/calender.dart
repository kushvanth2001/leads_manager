import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final Function(DateTime,DateTime)? onDateSelected;

  const CalendarPage({Key? key, this.onDateSelected}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;

  @override
  void initState() {
    super.initState();

   
  }

  @override
  Widget build(BuildContext context) {
    return 
    
    
    
    AlertDialog(
           title: Text('Pick Start and End Date'),
      content: Column(
          children: [
          TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2018, 1, 1),
      lastDay: DateTime.now(),
      selectedDayPredicate: (DateTime date) {
      return isDateSelected(date);
      },
      onDaySelected: (date, e) {
      _handleDaySelected(date);
      },
      availableCalendarFormats: const {
      CalendarFormat.month: 'Month',
      },
      calendarStyle: CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Colors.blue,
      ),
      
      markersMaxCount: 1,
      ),
    ),
    
            SizedBox(height: 20),
            Text(
              'Selected Dates: ${_formatDate(_selectedDate1)} - ${_formatDate(_selectedDate2)}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
    
     actions: [
        // Add your dialog actions/buttons here
        ElevatedButton(
          onPressed: () {
            if(_selectedDate1!=null&&_selectedDate2!=null){
          widget.onDateSelected?.call(_selectedDate1!,_selectedDate2!);
            Navigator.of(context).pop(); // Close the dialog
          }else{
            Fluttertoast.showToast(msg: "Please Select a Valid Date");
          }},
          child: Text('Done'),
        ),
         
      ],
    );
    
  }
String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else {
      return 'N/A';
    }
  }
  void _handleDaySelected(DateTime selectedDate) {
    setState(() {
      if (_selectedDate1 == null || _selectedDate2 != null) {
        // First date selected or both dates already selected
        _selectedDate1 = selectedDate;
        _selectedDate2 = null;
      } else if (selectedDate.isBefore(_selectedDate1!)) {
        // Swap dates if selected date is before the first selected date
        _selectedDate2 = _selectedDate1;
        _selectedDate1 = selectedDate;
      } else {
        // Second date selected
        _selectedDate2 = selectedDate;
      }
    });
  }

  bool isDateSelected(DateTime date) {
    if (_selectedDate1 != null &&(date.isAtSameMomentAs(_selectedDate1!) ||(_selectedDate2 != null && date.isAfter(_selectedDate1!) && date.isBefore(_selectedDate2!.add(Duration(days: 1)))))) {
      return true;
    }
    return false;
  }
}