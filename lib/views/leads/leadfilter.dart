import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/models/model_LeadStatus.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:leads_manager/models/model_tags.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  LeadController leadController = Get.find<LeadController>();
  TextEditingController textcontroller = TextEditingController();

  int _selectedIndex = 0;
static const List<String> sortfields = [
  "customerName",
  "id",
  
  
  "mobileNumber",
    "city",
  "state",
  "country",
  "pincode",
  "statusId.statusName",
  "sourceId.sourceName",


  
 
  "potentialDealValue",
  "actualDealValue",
  "createdOn",
  "lastModifiedTime",
  "followUpDate",
  "score"
];
  final List<String> _filters = [
    'Assigned To',
    'Assigned By',
    'Tags',
    "Status",
    "Source",
    "Date",
    "Period",
    "Last Activity",
    "Sort BY"
  ];
  List<Widget> images = [
    Image.asset(
      "assets/icon/assignedTo.jpg",
      width: 20,
      height: 20,
    ),
    Image.asset(
      "assets/icon/assignedby.png",
      width: 20,
      height: 20,
    ),
    Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius:
            BorderRadius.circular(15), // This makes the container round
      ),
    ),
    Container(
      width: 1,
      height: 1,
    ),
    Container(
      width: 1,
      height: 1,
    ),
    Icon(
      Icons.calendar_month,
      size: 20,
    ),
    Container(
      width: 1,
      height: 1,
    ),
    Image.asset(
      "assets/icon/activity.png",
      width: 20,
      height: 20,
    ),

    Image.asset('assets/icon/sort.png',width:20,height:20)
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      textcontroller.text = formatDates(
          leadController.selectedLastmodifedFrom.value,
          leadController.selectedLastmodifedTo.value);
    });
  }

  Widget _buildFilterContent(int index) {
    switch (index) {
      case 0: // Assigned To
        return Obx(() => CustomCheckboxList(
              initialValue: leadController.selectedAssignedTo.value
                  .map((value) => CustomCheckBox(value.firstName ?? "", value))
                  .toList(),
              items: leadController.assignedTo.value
                  .map((value) => CustomCheckBox(value.firstName ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  leadController.selectedAssignedTo.value =
                      (value as List<CustomCheckBox>).map((dropdwnmodel) {
                    return User.fromJson(dropdwnmodel.value.toJson());
                  }).toList();
                  print(leadController.selectedAssignedTo.value);
                  leadController.selectedAssignedTo.refresh();
                } else {
                  leadController.selectedAssignedTo.clear();
                  leadController.selectedAssignedTo.refresh();
                }
              },
            ));

      case 1: // Assigned By
        return Obx(() => CustomCheckboxList(
              initialValue: leadController.selectedAssignedBy.value
                  .map((value) => CustomCheckBox(value.firstName ?? "", value))
                  .toList(),
              items: leadController.assignedBy.value
                  .map((value) => CustomCheckBox(value.firstName ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  leadController.selectedAssignedBy.value =
                      (value as List<CustomCheckBox>).map((dropdwnmodel) {
                    return User.fromJson(dropdwnmodel.value.toJson());
                  }).toList();
                  print(leadController.selectedAssignedBy.value);
                  leadController.selectedAssignedBy.refresh();
                } else {
                  leadController.selectedAssignedBy.clear();
                  leadController.selectedAssignedBy.refresh();
                }
              },
            ));

      case 2: // Tags
        return Obx(() => CustomCheckboxList(
              initialValue: leadController.selectedAssignTags.value
                  .map((value) => CustomCheckBox(value.name ?? "", value))
                  .toList(),
              items: leadController.tags.value
                  .map((value) => CustomCheckBox(value.name ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  leadController.selectedAssignTags.value =
                      (value as List<CustomCheckBox>).map((dropdwnmodel) {
                    return Tag.fromJson(dropdwnmodel.value.toJson());
                  }).toList();
                  print("${leadController.selectedAssignTags.value}");
                  print(leadController.selectedAssignTags.value);
                  leadController.selectedAssignTags.refresh();
                } else {
                  leadController.selectedAssignTags.clear();
                  leadController.selectedAssignTags.refresh();
                }
              },
            ));

      case 3: // Status
        return Obx(() => CustomCheckboxList(
              initialValue: leadController.selectedLeadStatus.value
                  .map((value) => CustomCheckBox(value.statusName ?? "", value))
                  .toList(),
              items: leadController.leadStatus.value
                  .map((value) => CustomCheckBox(value.statusName ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  leadController.selectedLeadStatus.value =
                      (value as List<CustomCheckBox>).map((dropdwnmodel) {
                    return AllLeadsStatus.fromJson(dropdwnmodel.value.toJson());
                  }).toList();
                  print(leadController.selectedLeadStatus.value);
                  leadController.selectedLeadStatus.refresh();
                } else {
                  leadController.selectedLeadStatus.clear();
                  leadController.selectedLeadStatus.refresh();
                }
              },
            ));

      case 4: // Source
        return Obx(() => CustomCheckboxList(
              initialValue: leadController.selectedSources.value
                  .map((value) => CustomCheckBox(value ?? "", value))
                  .toList(),
              items: leadController.scources.value
                  .map((value) => CustomCheckBox(value ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  leadController.selectedSources.value =
                      (value as List<CustomCheckBox>).map((dropdwnmodel) {
                    return dropdwnmodel.value as String;
                  }).toList();
                  print(leadController.selectedSources.value);
                  leadController.selectedAssignedBy.refresh();
                } else {
                  leadController.selectedSources.clear();
                  leadController.selectedSources.refresh();
                }
              },
            ));

      case 5: // Date
        return Row(
          children: [
            ElevatedButton(
              child: Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime(DateTime.now().year + 5),
                );

                if (picked != null) {
          setState(() {
            leadController.selectedPeriod.value='all';
  leadController.selectedDates.clear();
   leadController.selectedDates.add(
      picked.start.millisecondsSinceEpoch
          .toString()
          .substring(0, 10)
    );
  // Check if the start and end dates are the same
  if (picked.start.millisecondsSinceEpoch == picked.end.millisecondsSinceEpoch) {
        leadController.selectedPeriod.value='all';
    print( "If they are the same, set the start date to the beginning of the day");
    DateTime startOfDay = DateTime(picked.start.year, picked.start.month, picked.start.day,);
    leadController.selectedDates.add(
      startOfDay.add(Duration(hours: 23,minutes: 58)).millisecondsSinceEpoch
          .toString()
          .substring(0, 10)
    );
  } else {
      leadController.selectedPeriod.value='all';
    // If they are different, add the start date
 leadController.selectedDates.add(
    picked.end.millisecondsSinceEpoch
        .toString()
        .substring(0, 10)

  );
  }
  
   
 
});

                }
              },
            ),
            if (leadController.selectedDates.isNotEmpty)
              Text(
                '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[0]) * 1000))} \n'
                '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[1]) * 1000))}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            if (leadController.selectedDates.isEmpty) Text("Select \n dates")
          ],
        );

      case 6: // Period
   return  Container(
      height: 600,
      width: 300,
      child: ListView.builder(
            shrinkWrap: true,
            itemCount: leadController.periodFilters.length,
            itemBuilder: (context, index) {
              String key = leadController.periodFilters.keys.elementAt(index);
              return Obx(()=> RadioListTile<String>(
                title: Text(key),
                value: leadController.periodFilters.values.elementAt(index)!,
                groupValue: leadController.selectedPeriod.value,
                onChanged: (value) {
                            leadController.selectedDates.value = [];
                  print(value);
                  leadController.selectedPeriod.value = value!;

                },
              ));
            },
          )
    );

      case 7: // Last Activity
        return Container(
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: TextFormField(
            controller: textcontroller,
            readOnly: true,
            decoration: InputDecoration(
                hintText: "Select Date",
                label: Text("Select Range"),
                suffixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder()),
            onTap: () async {
              List<DateTime?>? pickedDates =
                  await showCalendarDatePicker2Dialog(
                dialogSize: Size(300, 400),
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.range,
                ),
              );
              if (pickedDates != null) {
                List<DateTime> nonNullDates =
                    pickedDates.whereType<DateTime>().toList();
                if (nonNullDates.isEmpty || nonNullDates == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'No dates selected. Please select at least one date.')),
                  );
                } else if (nonNullDates.length == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Only one date selected: ${DateFormat('dd-MM-yyyy').format(nonNullDates.first)}')),
                  );
                  leadController.selectedLastmodifedFrom.value =
                      (nonNullDates![0]!.millisecondsSinceEpoch ~/ 1000)
                          .toString();
                  leadController.selectedLastmodifedFrom.value = null;
                  textcontroller.text = formatDates(
                      leadController.selectedLastmodifedFrom.value,
                      leadController.selectedLastmodifedTo.value);
                } else {
                   DateTime startOfDay = DateTime(nonNullDates![0].year, nonNullDates![0].month, nonNullDates![0].day,);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Multiple dates selected: ${nonNullDates.map((date) => DateFormat('dd-MM-yyyy').format(date)).join(', ')}')),
                  );
                  leadController.selectedLastmodifedFrom.value =
                      (nonNullDates![0]!.millisecondsSinceEpoch ~/ 1000)
                          .toString();
                          if(pickedDates[0]==pickedDates[1]){
                  leadController.selectedLastmodifedTo.value =
                      (startOfDay.add(Duration(hours: 23,minutes: 59)).millisecondsSinceEpoch ~/ 1000)
                          .toString();}else{

                                leadController.selectedLastmodifedTo.value =
                      (nonNullDates![1]!.millisecondsSinceEpoch ~/ 1000).toString();
                          }
                  textcontroller.text = formatDates(
                      leadController.selectedLastmodifedFrom.value,
                      leadController.selectedLastmodifedTo.value);
                }
              }
            },
          ),
        );
case 8:
return  ListView.builder(
  itemCount: sortfields.length,
  itemBuilder: (context, index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(10),
        child:Obx(()=> Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                 
                  if( (leadController.selectedSortFilter.value.split('&').first.toLowerCase() == sortfields[index].toLowerCase())){
     (leadController.selectedSortFilter.value.split('&').last == "sortOrder=DESC")?   
                      leadController.selectedSortFilter.value = "${sortfields[index]}&sortOrder=ASC"
                    
              
                : 
                      leadController.selectedSortFilter.value = "${sortfields[index]}&sortOrder=DESC";
                
                  }else{
 leadController.selectedSortFilter.value = "${sortfields[index]}&sortOrder=DESC";
                  }
                },
                child: Text(
               "statusId.statusName"==   sortfields[index]?'Status':"sourceId.sourceName"== sortfields[index]?'Source':capitalizeFirstLetter(sortfields[index]),
                  style: TextStyle(
                   color: (leadController.selectedSortFilter.value.split('&').first.toLowerCase() == sortfields[index].toLowerCase()) ? Colors.blue : Colors.black,
                     fontWeight: (leadController.selectedSortFilter.value.split('&').first.toLowerCase() == sortfields[index].toLowerCase())? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            (leadController.selectedSortFilter.value.split('&').first.toLowerCase() == sortfields[index].toLowerCase())
                ?       (leadController.selectedSortFilter.value.split('&').last == "sortOrder=DESC")?   InkWell(
                    child: Image.asset('assets/icon/sort-down.png', width: 50, height: 50, fit: BoxFit.cover),
                    onTap: () async {
                     // leadController.selectedSortFilter.value = "${sortfields[index]}&sortOrder=ASC";
                    },
                  )
                : InkWell(
                    child: Image.asset('assets/icon/sort-up.png', height: 50, width: 50, fit: BoxFit.cover),
                    onTap: () async {
                    //  leadController.selectedSortFilter.value = "${sortfields[index]}&sortOrder=DESC";
                    },
                  ):Container(),
          ],
        )),
      ),
    );
  },
);

      default:
        return Center(child: Text('Invalid filter selection'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              icon: Icon(
                Icons.clear,
                color: Colors.red,
              ),
              label: Text(
                "Clear Filters",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  leadController.leadModel.value = LeadModel();
                  leadController.currentPage = 0;
                  print("key ${leadController.selectedFeatureKey.value}");
                  
                  leadController.clearFilter();
                  leadController.getFilteredLeads();
                  leadController.refreshController();
                });

                Get.back();
              },
            ),
            SizedBox(
              width: 9,
            ),
            TextButton.icon(
              icon: Icon(
                Icons.filter_list,
                color: Colors.blue,
              ),
              label: Text(
                "Apply Filters",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                setState(() {
                  leadController.leadModel.value = LeadModel();
                  leadController.currentPage = 0;
                  leadController.getFilteredLeads();
                });

                Get.back();
              },
            ),
          ]),
      body: Row(
        children: [
          // Left side: Filter names
          Container(
            width: 150,
            child: ListView.builder(
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: _selectedIndex == index?Colors.blue.shade200:Colors.white,
                  leading: images[index],
                  title: Text(
                    _filters[index],
                  ),
                  
                  onTap: () async {
                    setState(() {
                      print(index);
                      _selectedIndex = 23;
                      print(_selectedIndex);
                    });
                    await Future.delayed(Duration(milliseconds: 100));
                    setState(() {
                      _selectedIndex = index;
                      print(_selectedIndex);
                    });
                  },
                );
              },
            ),
          ),
          // Divider
          VerticalDivider(width: 1),
          // Right side: Filter content
          Expanded(
            child: _selectedIndex == 23
                ? Text("Loading...")
                : _buildFilterContent(_selectedIndex),
          ),
        ],
      ),
    );
  }
}

class CustomCheckboxList extends StatefulWidget {
  final List<CustomCheckBox> initialValue;
  final List<CustomCheckBox> items;
  bool cansearch;
  final Function(List<CustomCheckBox>) onChanged;

  CustomCheckboxList(
      {required this.initialValue,
      required this.items,
      required this.onChanged,
      this.cansearch = false});

  @override
  _CustomCheckboxListState createState() => _CustomCheckboxListState();
}

class _CustomCheckboxListState extends State<CustomCheckboxList> {
  late List<CustomCheckBox> _selectedItems;
  List<CustomCheckBox> filtereditems = [];
  @override
  void initState() {
    super.initState();
    _selectedItems = widget.items
        .where((item) => widget.initialValue.any((e) => e.name == item.name))
        .toList();
    filtereditems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(6),
          child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Search",
            ),
            onChanged: (value) {
              if (value != "") {
                setState(() {
                  filtereditems = widget.items
                      .where((item) =>
                          item.name.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              } else {
                setState(() {
                   filtereditems = widget.items;
                });
               
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtereditems.length,
            itemBuilder: (context, index) {
              final item = filtereditems[index];

              final isChecked = _selectedItems.any((e) => e.name == item.name);

              return CheckboxListTile(
                title: Text(item.name),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      setState(() {
                       _selectedItems.add(item); 
                      });
                      
                    } else {
                      setState(() {
                            _selectedItems.remove(item);
                      });
                  
                    }
                    widget.onChanged(_selectedItems);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CustomCheckBox {
  String name;
  dynamic value;

  CustomCheckBox(this.name, this.value);
}

String formatDates(String? fromMillisStr, String? toMillisStr) {
  if (fromMillisStr == null && toMillisStr == null) {
    return 'Select date';
  }

  int? fromMillis = fromMillisStr != null ? int.tryParse(fromMillisStr) : null;
  int? toMillis = toMillisStr != null ? int.tryParse(toMillisStr) : null;

  DateFormat dateFormat = DateFormat('dd/MMM/yyyy');

  String fromDate = fromMillis != null
      ? dateFormat
          .format(DateTime.fromMillisecondsSinceEpoch(fromMillis * 1000))
      : '';
  String toDate = toMillis != null
      ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(toMillis * 1000))
      : '';

  if (fromDate.isNotEmpty && toDate.isNotEmpty) {
    return '$fromDate - $toDate';
  } else if (fromDate.isNotEmpty) {
    return fromDate;
  } else {
    return toDate;
  }
}
void updateSelectedDatesByFilter(String period) {
  LeadController leadController=Get.find<LeadController>();
  
  DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);


  if (period == "today") {
      leadController.selectedDates.clear();
    leadController.selectedDates.add(now .millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(now .add(Duration(hours: 23, minutes: 59)).millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "yesterday") {
      leadController.selectedDates.clear();
    DateTime yesterday = now.subtract(Duration(days: 1));
    leadController.selectedDates.add(yesterday.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(yesterday.add(Duration(hours: 23, minutes: 59)).millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "lastWeek") {
      leadController.selectedDates.clear();
    DateTime lastWeek = now.subtract(Duration(days: 7));
    leadController.selectedDates.add(lastWeek.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(now.millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "last30Days") {
      leadController.selectedDates.clear();
    DateTime last30Days = now.subtract(Duration(days: 30));
    leadController.selectedDates.add(last30Days.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(now.millisecondsSinceEpoch.toString().substring(0, 11));
  } else if (period == "currentMonth") {
      leadController.selectedDates.clear();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    leadController.selectedDates.add(firstDayOfMonth.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(now.millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "lastMonth") {
      leadController.selectedDates.clear();
    DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    leadController.selectedDates.add(firstDayOfLastMonth.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(lastDayOfLastMonth.millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "currentYear") {
      leadController.selectedDates.clear();
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    leadController.selectedDates.add(firstDayOfYear.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(now.millisecondsSinceEpoch.toString().substring(0, 10));
  } else if (period == "lastYear") {
      leadController.selectedDates.clear();
    DateTime firstDayOfLastYear = DateTime(now.year - 1, 1, 1);
    DateTime lastDayOfLastYear = DateTime(now.year - 1, 12, 31);
    leadController.selectedDates.add(firstDayOfLastYear.millisecondsSinceEpoch.toString().substring(0, 10));
    leadController.selectedDates.add(lastDayOfLastYear.millisecondsSinceEpoch.toString().substring(0, 10));
  } else {
  leadController.selectedDates.clear();
  
  }
 print( leadController.selectedDates);
}
String capitalizeFirstLetter(String sentence) {
  if (sentence.isEmpty) return sentence;

  return sentence.split(' ').map((word) {
    if (word.isEmpty) return word[0].toUpperCase() + word.substring(1).toLowerCase();
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}