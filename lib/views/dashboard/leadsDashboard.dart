// import 'dart:convert';
// import 'dart:math';
// import '../../../domainvariables.dart';
// // import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:intl/intl.dart';
// import '../../constants/styleConstants.dart';
// import '../../helper/SharedPrefsHelper.dart';
// import '../../helper/networkHelper.dart';
// import '../../utils/snapPeNetworks.dart';

// class LeadsDashboard extends StatefulWidget {
//   final List<Map<String, dynamic>> data;
//   final String selectedRadio;
//   const LeadsDashboard(
//       {Key? key, required this.data, required this.selectedRadio})
//       : super(key: key);
//   @override
//   State<LeadsDashboard> createState() => _LeadsDashboardState();
// }

// class _LeadsDashboardState extends State<LeadsDashboard> {
//   List<String> selectedStatusNames = [];

//   List<LineChartBarData> linesData = [];
//   Map<String, String> spotStatusMap =
//       {}; // This map will hold the mapping between FlSpot and status
//   @override
//   void initState() {
//     super.initState();
//     fetchDataMul(widget.selectedRadio).then((data) {
//       setState(() {
//         linesData = data[0];
//       });
//     });
//   }

//   Future<List<dynamic>> fetchDataMul(selectedDate) async {
//     String? userId = await SharedPrefsHelper().getMerchantUserId();
//     DateTime now = DateTime.now();
//     String startTime, endTime;
//     switch (selectedDate) {
//       case 'Today':
//         startTime = endTime = now.toIso8601String().split('T')[0];
//         break;
//       case 'Yesterday':
//         startTime =
//             now.subtract(Duration(days: 1)).toIso8601String().split('T')[0];
//         endTime = now.toIso8601String().split('T')[0];
//         break;
//       case 'Last 7 days':
//         startTime =
//             now.subtract(Duration(days: 7)).toIso8601String().split('T')[0];
//         endTime = now.toIso8601String().split('T')[0];
//         break;
//       case 'Current month':
//         startTime =
//             DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
//         endTime = now.toIso8601String().split('T')[0];
//         break;
//       case 'Last month':
//         startTime = DateTime(now.year, now.month - 1, 1)
//             .toIso8601String()
//             .split('T')[0];
//         endTime =
//             DateTime(now.year, now.month, 0).toIso8601String().split('T')[0];
//         break;
//       case 'Current year':
//         startTime = DateTime(now.year, 1, 1).toIso8601String().split('T')[0];
//         endTime = now.toIso8601String().split('T')[0];
//         break;
//       case 'Last year':
//         startTime =
//             DateTime(now.year - 1, 1, 1).toIso8601String().split('T')[0];
//         endTime =
//             DateTime(now.year - 1, 12, 31).toIso8601String().split('T')[0];
//         break;
//       default:
//         throw Exception('Invalid date range');
//     }

//     final response = await NetworkHelper().request(
//       RequestType.get,
//       Uri.parse(
//           'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/2?start_time=$startTime&end_time=$endTime'),
//     );

//     if (response != null && response.statusCode == 200) {
//       Map<String, dynamic> apiResponse = jsonDecode(response.body);
//       List<dynamic> result = apiResponse['result'];

//       // Group data by status
//       Map<String, List<FlSpot>> dataByStatus = {};
//       Map<double, String> dateLabels = {};
//       for (var item in result) {
//         String status = item['Status'];
//         double count = double.parse(item['Count'].toString());
//         // Parse the 'Period' field into a DateTime object
//         DateTime period = DateTime.parse(item['Period']);
//         // Use the day of the year as the x-coordinate
//         double dayOfYear = period.day.toDouble();
//         // Create a map to store the formatted date strings
//         // Format the DateTime object into the desired string format
//         String formattedPeriod = DateFormat('MMM dd').format(period);

//         // Store the formatted date string in the map
//         dateLabels[dayOfYear] = formattedPeriod;

//         if (!dataByStatus.containsKey(status)) {
//           dataByStatus[status] = [];
//         }

//         FlSpot spot = FlSpot(dayOfYear, count);
//         dataByStatus[status]?.add(spot);
//         String spotKey =
//             '${spot.x}-${spot.y}'; // Create a key based on the x and y values
//         spotStatusMap[spotKey] = status; // Add the mapping to the map
//         print('Stored: $spotKey -> $status');
//       }
//       List<Color> lineColors = [
//         Colors.blue,
//         Colors.red,
//         Colors.green,
//         Colors.yellow,
//         Colors.orange,
//         Colors.purple
//       ];
//       // Convert to LineChartBarData
//       List<LineChartBarData> chartData = [];
//       int index = 0;
//       dataByStatus.forEach((status, data) {
//         chartData.add(LineChartBarData(
//           spots: data,
//           isCurved: true,
//           curveSmoothness: 0,
//           colors: [lineColors[index % lineColors.length]],
//           barWidth: 2,
//           isStrokeCapRound: true,
//           dotData: FlDotData(show: true),
//           belowBarData: BarAreaData(show: false),
//         ));
//         index++;
//       });

//       return [chartData, dateLabels];
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 height: 120, // Specify the height of the container
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.data.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == widget.data.length) {
//                       return GestureDetector(
//                         onTap: () async {
//                           final result = await showModalBottomSheet(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return StatefulBuilder(
//                                 builder: (BuildContext context,
//                                     StateSetter setState) {
//                                   return Container(
//                                     height: 200,
//                                     child: Column(
//                                       children: [
//                                         Expanded(
//                                           child: FutureBuilder<List<String>?>(
//                                             future: dashboardFieldsList(),
//                                             builder: (BuildContext context,
//                                                 AsyncSnapshot<List<String>?>
//                                                     snapshot) {
//                                               if (snapshot.hasData) {
//                                                 return ListView.builder(
//                                                   itemCount: widget.data.length,
//                                                   itemBuilder:
//                                                       (context, index) {
//                                                     bool isSelected =
//                                                         selectedStatusNames
//                                                             .contains(widget
//                                                                     .data[index]
//                                                                 ['statusName']);
//                                                     return CheckboxListTile(
//                                                       title: Text(
//                                                           widget.data[index]
//                                                               ['statusName']),
//                                                       value: isSelected,
//                                                       onChanged: (bool? value) {
//                                                         setState(() {
//                                                           if (value != null &&
//                                                               value) {
//                                                             // Add the status name to the list
//                                                             selectedStatusNames
//                                                                 .add(widget.data[
//                                                                         index][
//                                                                     'statusName']);
//                                                           } else {
//                                                             // Remove the status name from the list
//                                                             selectedStatusNames
//                                                                 .remove(widget
//                                                                             .data[
//                                                                         index][
//                                                                     'statusName']);
//                                                           }
//                                                         });
//                                                       },
//                                                     );
//                                                   },
//                                                 );
//                                               } else {
//                                                 return Center();
//                                               }
//                                             },
//                                           ),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () async {
//                                             print(selectedStatusNames);
//                                             await updateDashboardSummaryFields(
//                                                 selectedStatusNames);
//                                             setState(() {});
//                                             Navigator.pop(context, 'refresh');
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );

//                           if (result == 'refresh') {
//                             fetchDataMul(widget.selectedRadio).then((data) {
//                               setState(() {
//                                 linesData = data[0];
//                               });
//                             });
//                           }
//                         },
//                         child: Card(
//                           color: Colors.grey[300],
//                           child: Center(
//                             child: Icon(Icons.add),
//                           ),
//                         ),
//                       );
//                     } else {
//                       List<Color> colors = [
//                         Colors.red,
//                         Colors.green,
//                         Colors.blue,
//                         const Color.fromARGB(255, 196, 176, 0)
//                       ];
//                       Color itemColor = colors[index % colors.length];
//                       return FutureBuilder(
//                         future: dashboardFieldsList(),
//                         builder: (BuildContext context,
//                             AsyncSnapshot<List<String>?> snapshot) {
//                           if (snapshot.hasData) {
//                             bool isSelected = snapshot.data!
//                                 .contains(widget.data[index]['statusName']);
//                             if (isSelected) {
//                               return Container(
//                                 width: 120,
//                                 child: Card(
//                                   borderOnForeground: true,
//                                   color: Colors.white,
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           widget.data[index]['value']
//                                               .toString(),
//                                           style: TextStyle(
//                                               fontSize: 30, color: itemColor),
//                                         ),
//                                         SizedBox(
//                                           height: 3,
//                                         ),
//                                         Text(
//                                           widget.data[index]['statusName'],
//                                           style: TextStyle(
//                                               fontSize: kSmallFontSize,
//                                               fontWeight: FontWeight.bold,
//                                               color: itemColor),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               return SizedBox.shrink();
//                             }
//                           } else {
//                             return Center();
//                           }
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 234, 234, 234),
//                     borderRadius: BorderRadius.all(Radius.circular(20))),
//                 height: 300,
//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: FutureBuilder<List<_ChartData>>(
//                     future: fetchBarChartData(widget.selectedRadio),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else {
//                         List<charts.Series<dynamic, String>>
//                             barChartSeriesList =
//                             _createBarChartData(snapshot.data!);
//                         return charts.BarChart(
//                           barChartSeriesList,
//                           animate: true,
//                           vertical: false,
//                           primaryMeasureAxis: charts.NumericAxisSpec(
//                             renderSpec: charts.GridlineRendererSpec(),
//                           ),
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(),
//                           ),
//                           selectionModels: [
//                             charts.SelectionModelConfig(
//                               changedListener: (charts.SelectionModel model) {
//                                 if (model.hasDatumSelection) {
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         content: Text(model.selectedSeries[0]
//                                             .measureFn(
//                                                 model.selectedDatum[0].index)
//                                             .toString()),
//                                       );
//                                     },
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 234, 234, 234),
//                     borderRadius: BorderRadius.all(Radius.circular(20))),
//                 height: 300,
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: FutureBuilder<List<dynamic>>(
//                     future: fetchDataMul(widget.selectedRadio),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else {
//                         Map<double, String> dateLabels = snapshot.data?[1];
//                         return LineChart(
//                           LineChartData(
//                             titlesData: FlTitlesData(
//                               bottomTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: 22,
//                                 getTextStyles: (context, value) =>
//                                     const TextStyle(
//                                   color: Color(0xff72719b),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 10,
//                                 ),
//                                 rotateAngle: -90,
//                                 getTitles: (value) {
//                                   // Calculate the total range of your data
//                                   double range = dateLabels.keys.reduce(max) -
//                                       dateLabels.keys.reduce(min);

//                                   // Calculate an interval to divide the range into approximately 10 parts
//                                   double interval = range / 10;

//                                   // Only display the label if the value is a multiple of the interval
//                                   if ((value.toInt() % interval.round()) == 0) {
//                                     return dateLabels[value]!;
//                                   }

//                                   return '';
//                                 },
//                               ),

//                               leftTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: 30,
//                                 interval:
//                                     calculateInterval(), // Calculate the interval based on your data
//                                 getTextStyles: (context, value) =>
//                                     const TextStyle(
//                                   color: Color(0xff72719b),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 10,
//                                 ),

//                                 getTitles: (value) {
//                                   return NumberFormat.decimalPattern()
//                                       .format(value.toInt());
//                                 },
//                               ),
//                               // ... Other properties ...
//                             ),
//                             lineTouchData: LineTouchData(
//                               touchTooltipData: LineTouchTooltipData(
//                                 tooltipBgColor: Colors.black.withOpacity(0.5),
//                                 getTooltipItems:
//                                     (List<LineBarSpot> touchedBarSpots) {
//                                   return touchedBarSpots.map((barSpot) {
//                                     final flSpot = barSpot;
//                                     String spotKey =
//                                         '${flSpot.x}-${flSpot.y}'; // Create a key based on the x and y values
//                                     String? status = spotStatusMap[
//                                         spotKey]; // Fetch the status corresponding to the key

//                                     return LineTooltipItem(
//                                       '$status : ${flSpot.y}',
//                                       const TextStyle(color: Colors.white),
//                                     );
//                                   }).toList();
//                                 },
//                               ),
//                             ),
//                             lineBarsData: snapshot.data?[0],
//                             // ... Other properties ...
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   /// Create series list with multiple series for the bar chart
//   List<charts.Series<dynamic, String>> _createBarChartData(
//       List<_ChartData> data) {
//     return [
//       new charts.Series<_ChartData, String>(
//         id: 'Data',
//         domainFn: (_ChartData sales, _) => sales.category,
//         measureFn: (_ChartData sales, _) => sales.value,
//         data: data,
//       )
//     ];
//   }

//   double calculateInterval() {
//     double maxCount = linesData
//         .map((line) => line.spots.map((spot) => spot.y as double).reduce(max))
//         .toList()
//         .cast<double>()
//         .reduce(max);
//     return maxCount / 5; // Adjust this value to change the number of intervals
//   }

//   int calculateTotalDays() {
//     DateTime now = DateTime.now();
//     DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);
//     return now.difference(oneYearAgo).inDays;
//   }

//   Future<List<String>?> dashboardFieldsList() async {
//     var k;
//     String? propertyValue = k;//await SnapPeNetworks().dashboardFields();
//     if (propertyValue == null) {
//       return null;
//     }
//     List<String> fields = propertyValue.split(',');
//     return fields;
//   }

//   Future<void> updateDashboardSummaryFields(
//       List<String> selectedStatusNames) async {
//     String clientGroupName =
//         await SharedPrefsHelper().getClientGroupName() ?? "";
//     List<Map<String, dynamic>> fieldsData = [
//       {
//         "status": "OK",
//         "messages": [],
//         "propertyName": "dashboard_summary_fields",
//         "propertyType": "client_user_attributes",
//         "name": "Fields to show dashboard summary",
//         "id": 1,
//         "propertyValue": selectedStatusNames.join(','),
//         "propertyAllowedValues": null,
//         "propertyDefaultValues": null,
//         "isEditable": true,
//         "remarks": null,
//         "category": "Others",
//         "isVisibleToClient": false,
//         "interfaceType": "drop_down",
//         "pricelistCode": null
//       }
//     ];

//     // Create the request data
//     // Map<String, dynamic> requestData = fieldsData;
//     final response = await NetworkHelper().request(
//       RequestType.put,
//       Uri.parse(
//           'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/user/156/properties'),
//       requestBody: jsonEncode(fieldsData),
//     );

//     if (response != null && response.statusCode == 200) {
//       print('API call successful');
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }

// class MultilineChartData {
//   dynamic date;
//   final int count;
//   final String status;

//   MultilineChartData(this.date, this.count, this.status);
// }

// class _ChartData {
//   final String category;
//   final int value;

//   _ChartData(this.category, this.value);
// }

// Future<List<_ChartData>> fetchBarChartData(String selectedDate) async {
//   String? userId = await SharedPrefsHelper().getMerchantUserId();
//   DateTime now = DateTime.now();
//   String startTime, endTime;

//   switch (selectedDate) {
//     case 'Today':
//       startTime = endTime = now.toIso8601String().split('T')[0];
//       break;
//     case 'Yesterday':
//       startTime = endTime =
//           now.subtract(Duration(days: 1)).toIso8601String().split('T')[0];
//       break;
//     case 'Last 7 days':
//       startTime =
//           now.subtract(Duration(days: 7)).toIso8601String().split('T')[0];
//       endTime = now.toIso8601String().split('T')[0];
//       break;
//     case 'Current month':
//       startTime =
//           DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
//       endTime = now.toIso8601String().split('T')[0];
//       break;
//     case 'Last month':
//       startTime =
//           DateTime(now.year, now.month - 1, 1).toIso8601String().split('T')[0];
//       endTime =
//           DateTime(now.year, now.month, 0).toIso8601String().split('T')[0];
//       break;
//     case 'Current year':
//       startTime = DateTime(now.year, 1, 1).toIso8601String().split('T')[0];
//       endTime = now.toIso8601String().split('T')[0];
//       break;
//     case 'Last year':
//       startTime = DateTime(now.year - 1, 1, 1).toIso8601String().split('T')[0];
//       endTime = DateTime(now.year - 1, 12, 31).toIso8601String().split('T')[0];
//       break;
//     default:
//       throw Exception('Invalid date range');
//   }

//   try {
//     final response = await NetworkHelper().request(
//       RequestType.get,
//       Uri.parse(
//         'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/1?start_time=$startTime&end_time=$endTime',
//       ),
//       requestBody: "",
//     );

//     if (response != null && response.statusCode == 200) {
//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//       final parsed = json.decode(response.body);
//       final List<dynamic> dataList = parsed['result'];
//       final List<_ChartData> data = dataList
//           .map((json) => _ChartData(json['status'], json['count']))
//           .toList();
//       return data;
//     } else {
//       print('Failed to load data');
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     print('Exception occurred: $e');
//     throw e;
//   }
// }




























































































































































































































































// /**
// class Dashboard extends StatelessWidget {
//   final lineChartData1 = [
//     new _ChartData('Jan', 5),
//     new _ChartData('Feb', 25),
//     new _ChartData('Mar', 100),
//     new _ChartData('Apr', 75),
//   ];

//   final lineChartData2 = [
//     new _ChartData('Jan', 10),
//     new _ChartData('Feb', 50),
//     new _ChartData('Mar', 200),
//     new _ChartData('Apr', 150),
//   ];

//   final lineChartData3 = [
//     new _ChartData('Jan', 20),
//     new _ChartData('Feb', 100),
//     new _ChartData('Mar', 300),
//     new _ChartData('Apr', 225),
//   ];
//   Future<List<_ChartData>> fetchBarChartData() async {
//     String? userId = await SharedPrefsHelper().getMerchantUserId();
//     try {
//       final response = await NetworkHelper().request(
//         RequestType.get,
//         Uri.parse(
//             'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/1?start_time=2023-11-29&end_time=2023-12-06'),
//         requestBody: "",
//       );

//       if (response != null && response.statusCode == 200) {
//         print('Response Status: ${response.statusCode}');
//         print('Response Body: ${response.body}');
//         final parsed = json.decode(response.body);
//         final List<dynamic> dataList = parsed['result'];
//         final List<_ChartData> data = dataList
//             .map((json) => _ChartData(json['status'], json['count']))
//             .toList();
//         return data;
//       } else {
//         print('Failed to load data');
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//       throw e;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<charts.Series<dynamic, String>> lineChartSeriesList =
//         _createLineChartData();
//     // Define your titles and subtitles
//     List<String> titles = ['Follow Up', 'Converted', 'Demo', 'New'];
//     List<String> subtitles = ['0', '1', '2', '3'];
//     return Scaffold(
//       appBar: AppBar(title: Text("Dashboard")),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 100, // Specify the height of the container
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: titles.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 100, // Specify the width of each square container
//                     child: Card(
//                       color: Colors.blue, // Change this to your preferred color
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(titles[index],
//                                 style: TextStyle(
//                                     fontSize: kSmallFontSize,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors
//                                         .white)), // Use the index to get the title
//                             Text(subtitles[index],
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors
//                                         .white)), // Use the index to get the subtitle
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             FutureBuilder<List<_ChartData>>(
//               future: fetchBarChartData(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   List<charts.Series<dynamic, String>> barChartSeriesList =
//                       _createBarChartData(snapshot.data!);
//                   return Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Color.fromARGB(255, 234, 234, 234),
//                           borderRadius: BorderRadius.all(Radius.circular(20))),
//                       height: 300, // Specify the height of the chart
//                       child: Container(
//                         padding: EdgeInsets.all(12),
//                         child: charts.BarChart(
//                           barChartSeriesList,
//                           animate: true,
//                           vertical:
//                               false, // Set this to false for horizontal bar chart
//                           primaryMeasureAxis: charts.NumericAxisSpec(
//                             renderSpec: charts.GridlineRendererSpec(),
//                           ),
//                           domainAxis: charts.OrdinalAxisSpec(
//                             renderSpec: charts.SmallTickRendererSpec(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text("${snapshot.error}");
//                 }

//                 // By default, show a loading spinner.
//                 return CircularProgressIndicator();
//               },
//             ),
//             // Add another graph here
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 234, 234, 234),
//                     borderRadius: BorderRadius.all(Radius.circular(20))),
//                 height: 300, // Specify the height of the second chart
//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: charts.OrdinalComboChart(
//                     lineChartSeriesList,
//                     animate: true,
//                     defaultRenderer: charts.LineRendererConfig(),
//                     customSeriesRenderers: [
//                       charts.BarRendererConfig(
//                         customRendererId: 'customBar',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Create series list with multiple series for the bar chart
//   List<charts.Series<dynamic, String>> _createBarChartData(
//       List<_ChartData> data) {
//     return [
//       new charts.Series<_ChartData, String>(
//         id: 'Data',
//         domainFn: (_ChartData sales, _) => sales.category,
//         measureFn: (_ChartData sales, _) => sales.value,
//         data: data,
//       )
//     ];
//   }

//   /// Create series list with multiple series for the line chart
//   List<charts.Series<dynamic, String>> _createLineChartData() {
//     return [
//       new charts.Series<_ChartData, String>(
//         id: 'Data1',
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//         domainFn: (_ChartData sales, _) => sales.category,
//         measureFn: (_ChartData sales, _) => sales.value,
//         data: lineChartData1,
//       ),
//       new charts.Series<_ChartData, String>(
//         id: 'Data2',
//         colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//         domainFn: (_ChartData sales, _) => sales.category,
//         measureFn: (_ChartData sales, _) => sales.value,
//         data: lineChartData2,
//       ),
//       new charts.Series<_ChartData, String>(
//         id: 'Data3',
//         colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
//         domainFn: (_ChartData sales, _) => sales.category,
//         measureFn: (_ChartData sales, _) => sales.value,
//         data: lineChartData3,
//       ),
//     ];
//   }
// }

// /// Sample ordinal data type.
// class _ChartData {
//   final String category;
//   final int value;

//   _ChartData(this.category, this.value);
// }


//  */

// // class Dashboard extends StatefulWidget {
// //   const Dashboard({Key? key}) : super(key: key);

// //   @override
// //   _DashboardState createState() => _DashboardState();
// // }

// // class _DashboardState extends State<Dashboard> {
// //   late int showingTooltip;
// //   final data = {
// //     "ASSIGNED": 2,
// //     "COLD": 2,
// //     "CONTACTED": 49,
// //     "CONVERTED": 1,
// //     "DEAD": 9,
// //     "HOT": 1,
// //     "NEW": 3541,
// //     "NO RESPONSE": 30,
// //     "PROSPECT": 8,
// //   };

// //   @override
// //   void initState() {
// //     showingTooltip = -1;
// //     super.initState();
// //   }

// //   BarChartGroupData generateGroupData(int x, int y) {
// //     return BarChartGroupData(
// //       x: x,
// //       showingTooltipIndicators: showingTooltip == x ? [0] : [],
// //       barRods: [
// //         BarChartRodData(y: y.toDouble()),
// //       ],
// //     );
// //   }

// //   List<BarChartGroupData> generateAllGroups() {
// //     List<BarChartGroupData> barGroups = [];
// //     int x = 0;
// //     data.forEach((key, value) {
// //       barGroups.add(generateGroupData(x, value));
// //       x++;
// //     });
// //     return barGroups;
// //   }

// //   BarChartData generateChartData() {
// //     return BarChartData(
// //       maxY: 7000,
// //       minY: 0,
// //       barGroups: generateAllGroups(),
// //       titlesData: FlTitlesData(
// //         leftTitles: SideTitles(
// //           showTitles: true,
// //           getTitles: (value) {
// //             if (value % 1000 == 0) return value.toInt().toString();
// //             return '';
// //           },
// //         ),
// //         bottomTitles: SideTitles(
// //           showTitles: true,
// //           getTitles: (double value) {
// //             int index = value.toInt();
// //             return data.keys.elementAt(index);
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Dashboard")),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24),
// //           child: AspectRatio(
// //             aspectRatio: 2,
// //             child: BarChart(generateChartData()),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';

// // class Dashboard extends StatefulWidget {
// //   const Dashboard({Key? key}) : super(key: key);

// //   @override
// //   _DashboardState createState() => _DashboardState();
// // }

// // class _DashboardState extends State<Dashboard> {
// //   late int showingTooltip;

// //   @override
// //   void initState() {
// //     showingTooltip = -1;
// //     super.initState();
// //   }

// //   BarChartGroupData generateGroupData(int x, double y) {
// //     return BarChartGroupData(
// //       x: x,
// //       showingTooltipIndicators: showingTooltip == x ? [0] : [],
// //       barRods: [
// //         BarChartRodData(
// //           y: y,
// //           width: 15,
// //           colors: [Colors.blue],
// //         )
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Your data
// //     final data = {
// //       "ASSIGNED": 2,
// //       "COLD": 2,
// //       "CONTACTED": 49,
// //       "CONVERTED": 1,
// //       "DEAD": 9,
// //       "HOT": 1,
// //       "NEW": 3541,
// //       "NO RESPONSE": 30,
// //       "PROSPECT": 8,
// //     };

// //     final List<BarChartGroupData> barGroups = data.entries.map((entry) {
// //       final index = data.keys.toList().indexOf(entry.key);
// //       return generateGroupData(index, entry.value.toDouble());
// //     }).toList();

// //     return Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Dashboard'),
// //         ),
// //         body: Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: BarChart(BarChartData(
// //                 barGroups: barGroups,
// //                 titlesData: FlTitlesData(
// //                     leftTitles: SideTitles(
// //                       showTitles: true,
// //                       getTitles: (double value) {
// //                         return data.values.elementAt(value.toInt()).toString();
// //                       },
// //                     ),
// //                     bottomTitles: SideTitles(
// //                       showTitles: true,
// //                       getTitles: (double value) {
// //                         return data.keys.elementAt(value.toInt());
// //                       },
// //                     )),
// //                 barTouchData: BarTouchData(
// //                   enabled: true,
// //                   handleBuiltInTouches: false,
// // //                   touchCallback: (BarTouchResponse response) {
// // //   if (response.spot != null &&
// // //       response.touchInput is FlTapUpEvent) {
// // //     setState(() {
// // //       final x = response.spot!.touchedBarGroup.x;
// // //       final isShowing = showingTooltip == x;
// // //       if (isShowing) {
// // //         showingTooltip = -1;
// // //       } else {
// // //         showingTooltip = x;
// // //       }
// // //     });
// // //   }
// // // },

// //                   // mouseCursorResolver: (event, response) {
// //                   //   return response == null || response.spot == null
// //                   //       ? MouseCursor.defer
// //                   //       : SystemMouseCursors.click;
// //                   // },
// //                 )))));
// //   }
// // }
