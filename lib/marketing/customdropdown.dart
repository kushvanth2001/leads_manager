import 'package:flutter/material.dart';
import 'addpromotions.dart';

class CustomDropDown extends StatefulWidget {
  final List<Application> allapplicationlist;
  final List<Application> initiallySelectedItems; // Add this line
  final void Function(List<Application>) onSelectionChanged;

  CustomDropDown({
    Key? key,
    required this.allapplicationlist,
    required this.onSelectionChanged,
    required this.initiallySelectedItems, // Add this line
  }) : super(key: key);

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  List<bool> selectedBoolValue = [];
  String _initialapplicationvalue = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedBoolValue = List.generate(widget.allapplicationlist.length, (index) {
        // Set initially selected items to true
        return widget.initiallySelectedItems.contains(widget.allapplicationlist[index]);
      });
    });
    updateInitialValue(widget.initiallySelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.5,
      child: ListView.builder(
        itemCount: widget.allapplicationlist.length,
        itemBuilder: (context, index) {
          return _initialapplicationvalue == "" ||
                  _initialapplicationvalue == widget.allapplicationlist[index].type
              ? Card(
                  child: CheckboxListTile(
                    value: selectedBoolValue[index],
                    onChanged: (value) {
                      setState(() {
                        selectedBoolValue[index] = value!;
                        widget.onSelectionChanged(getSelectedItems());
                      });
                    },
                    title: Text(widget.allapplicationlist[index].applicationName),
                  ),
                )
              : Container();
        },
      ),
    );
  }

  List<Application> getSelectedItems() {
    List<Application> selectedItems = [];
    for (int i = 0; i < selectedBoolValue.length; i++) {
      if (selectedBoolValue[i]) {
        selectedItems.add(widget.allapplicationlist[i]);
      }
    }
    updateInitialValue(selectedItems);
    return selectedItems;
  }

  void updateInitialValue(List<Application> selectedItems) {
    setState(() {
      _initialapplicationvalue = selectedItems.isNotEmpty ? selectedItems.first.type : "";
    });
  }
}
