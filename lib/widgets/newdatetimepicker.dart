import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/views/leads/taskDetails.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart'; // Assuming you're using this package

class NewDateTimePicker extends StatelessWidget {
  final DateTime initialValue;
  final ValueChanged<DateTime?> onDateTimeChanged;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  NewDateTimePicker({
    Key? key,
    required this.initialValue,
    required this.onDateTimeChanged,
    this.hintText = 'Select Date and Time',
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: TextFormField(
        initialValue: DateFormat('dd-MM-yyyy, h:mm a').format(initialValue),
        readOnly: true,
        decoration: overallborderstyle(
          hintText,
          prefixIcon,
          suffixIcon,
        ),
        onTap: () async {
          DateTime? pickedDateTime = await showOmniDateTimePicker(
            context: context,
            initialDate: initialValue,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDateTime != null) {
            onDateTimeChanged(pickedDateTime);
          }
        },
      ),
    );
  }
}



class NewDateRangePicker extends StatelessWidget {
  
  final ValueChanged<List<DateTime>> onDateTimeChanged;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  NewDateRangePicker({
    Key? key,
  
    required this.onDateTimeChanged,
    this.hintText = 'Select Dates',
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: TextFormField(
        initialValue: "Select date",
     
        readOnly: true,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
            dialogSize: Size(300, 400),
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.multi,
            ),
      
          );
          if (pickedDates != null) {
            List<DateTime> nonNullDates = pickedDates.whereType<DateTime>().toList();
            onDateTimeChanged(nonNullDates);
          }
        },
      ),
    );
  }
}
