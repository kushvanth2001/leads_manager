// import 'dart:convert';
// import 'dart:math';
// import '../../../domainvariables.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:intl/intl.dart';
// import '../../constants/styleConstants.dart';
// import '../../helper/SharedPrefsHelper.dart';
// import '../../helper/networkHelper.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// import '../../models/model_application.dart';

// class MarketingDashboard extends StatefulWidget {
//   final String selectedRadio;
//   const MarketingDashboard({Key? key, required this.selectedRadio})
//       : super(key: key);
//   @override
//   State<MarketingDashboard> createState() => _MarketingDashboardState();
// }

// class _MarketingDashboardState extends State<MarketingDashboard> {
//   List<LineChartBarData> linesData = [];
//   List<Application> applications = [];
//   Map<String, String> spotStatusMap =
//       {}; // This map will hold the mapping between FlSpot and status
//   @override
//   void initState() {
//     super.initState();
//     fetchAndStoreApplications();
//     fetchDataMul(widget.selectedRadio).then((data) {
//       setState(() {
//         linesData = data[0];
//       });
//     });
//   }

//   Future<void> fetchAndStoreApplications() async {
//     // Assuming OtherClass is the class that has fetchApplicationsforLinkedNumber method
//     applications = await fetchApplicationsforLinkedNumber();
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
//                 height: 150, // Specify the height of the container
//                 child: FutureBuilder<List<Application>>(
//                   future: fetchApplicationsforLinkedNumber(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<List<Application>> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(
//                           child:
//                               CircularProgressIndicator()); // Show loading spinner while waiting for the data
//                     } else if (snapshot.hasError) {
//                       return Text(
//                           'Error: ${snapshot.error}'); // Show error message if there's an error
//                     } else {
//                       applications = snapshot
//                           .data!; // Assign the data to applications when it's available
//                       return ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: applications.length,
//                         itemBuilder: (context, index) {
//                           // Define a list of colors
//                           List<Color> colors = [
//                             Colors.red,
//                             Colors.green,
//                             Colors.blue,
//                             const Color.fromARGB(255, 196, 176, 0)
//                           ];
//                           // Use the index modulo the length of the color list to get a color
//                           Color itemColor = colors[index % colors.length];
//                           return Container(
//                             width:
//                                 150, // Specify the width of each square container
//                             child: Card(
//                               borderOnForeground: true,
//                               color: Colors
//                                   .white, // Change this to your preferred color
//                               child: Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Text(
//                                           applications[index].applicationName ??
//                                               "Not available",
//                                           style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                               color: itemColor)),
//                                     ), // Use the index to get the title
//                                     Text(
//                                         applications[index].phoneNo ??
//                                             "Not available",
//                                         style: TextStyle(
//                                             fontSize: kSmallFontSize,
//                                             color:
//                                                 itemColor)), // Use the index to get the subtitle
//                                     Text(
//                                         applications[index].type ??
//                                             "Not available",
//                                         style: TextStyle(
//                                             fontSize: kSmallFontSize,
//                                             color:
//                                                 itemColor)), // Use the index to get the subtitle

//                                                 //applicationstA
//                                     Text(
//                                         applications[index].status ??
//                                             "Not available",
//                                         style: TextStyle(
//                                             fontSize: kSmallFontSize,
//                                             color:
//                                                 itemColor)), // Use the index to get the subtitle
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 234, 234, 234),
//                     borderRadius: BorderRadius.all(Radius.circular(20))),
//                 height: 300,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: FutureBuilder<List<ChartStackData>>(
//                     future: fetchStackData(widget.selectedRadio),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         List<ChartStackData> chartData = snapshot.data!;
//                         chartData.forEach((data) => print(data.name));
//                         print("hhhhhhhhhhhh");
//                         return Container(
//                             height: 400,
//                             child: SfCartesianChart(
//                               primaryXAxis: CategoryAxis(
//                                 // labelRotation: -45,
//                                 // labelRotation: 45,
//                                 labelIntersectAction:
//                                     AxisLabelIntersectAction.rotate45,
//                                 labelStyle: TextStyle(
//                                     fontSize: 8, fontWeight: FontWeight.bold),
//                               ),
//                               series: <ChartSeries>[
//                                 StackedColumnSeries<ChartStackData, String>(
//                                   dataSource: chartData,
//                                   xValueMapper: (ChartStackData data, _) =>
//                                       data.status,
//                                   yValueMapper: (ChartStackData data, _) =>
//                                       data.value,
//                                   dataLabelSettings:
//                                       DataLabelSettings(isVisible: false),
//                                   pointColorMapper: (ChartStackData data, _) {
//                                     // Dynamically assign colors based on the category name
//                                     return Color(
//                                             (data.name.hashCode * 0xFFFFFF) ~/
//                                                 0xFFFF0000)
//                                         .withOpacity(0.5);
//                                   },
//                                 ),
//                               ],
//                               tooltipBehavior: TooltipBehavior(
//                                 enable: true,
//                                 header: '',
//                                 format: 'point.y',
//                                 canShowMarker: true,
//                                 builder: (dynamic data,
//                                     dynamic point,
//                                     dynamic series,
//                                     int pointIndex,
//                                     int seriesIndex) {
//                                   ChartStackData chartDataa =
//                                       chartData[pointIndex];
//                                   // String status = chartDataa.status;
//                                   String tooltipText =
//                                       '${chartDataa.name}: ${chartDataa.value}';
//                                   return Container(
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(5),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.grey.withOpacity(0.5),
//                                             spreadRadius: 2,
//                                             blurRadius: 5,
//                                             offset: Offset(0, 3),
//                                           ),
//                                         ],
//                                       ),
//                                       padding: EdgeInsets.all(10),
//                                       child: Text(
//                                         '$tooltipText',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ));
//                                 },
//                               ),
//                             ));
//                       } else if (snapshot.hasError) {
//                         return Text('Failed to load data');
//                       } else {
//                         return Center(child: CircularProgressIndicator());
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
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<charts.Color> colorList = [
//     charts.MaterialPalette.blue.shadeDefault,
//     charts.MaterialPalette.red.shadeDefault,
//     charts.MaterialPalette.green.shadeDefault,
//     charts.MaterialPalette.yellow.shadeDefault,
//     // Add more colors if needed
//   ];

//   List<charts.Series<ChartData, String>> createChartData(List<ChartData> data) {
//     return data.map((chartData) {
//       final index = data.indexOf(chartData);
//       return charts.Series<ChartData, String>(
//         id: chartData.category,
//         colorFn: (_, __) => colorList[index % colorList.length],
//         domainFn: (ChartData sales, _) => sales.status,
//         measureFn: (ChartData sales, _) => sales.value,
//         data:
//             data.where((item) => item.category == chartData.category).toList(),
//       );
//     }).toList();
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
//           'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/7?start_time=$startTime&end_time=$endTime'),
//     );

//     if (response != null && response.statusCode == 200) {
//       Map<String, dynamic> apiResponse = jsonDecode(response.body);
//       List<dynamic> result = apiResponse['result']['result'];

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
//         Color.fromARGB(255, 156, 140, 0),
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
//           dotData: FlDotData(show: false),
//           belowBarData: BarAreaData(show: false),
//         ));
//         index++;
//       });

//       return [chartData, dateLabels];
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   double calculateInterval() {
//     double maxCount = linesData
//         .map((line) => line.spots.map((spot) => spot.y as double).reduce(max))
//         .toList()
//         .cast<double>()
//         .reduce(max);
//     return maxCount / 5; // Adjust this value to change the number of intervals
//   }

//   Future<List<ChartStackData>> fetchStackData(selectedDate) async {
//     String? clientId = await SharedPrefsHelper().getClientId();
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
//           'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/6?start_time=$startTime&end_time=$endTime'),
//       requestBody: "",
//     );
//     if (response != null && response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//       List<dynamic> results = data['result']['result'];

//       List<ChartStackData> chartData = [];
//       results.forEach((result) {
//         String status = result['Status'];
//         List<dynamic> counts = result['Counts'];

//         counts.forEach((count) {
//           String name = count.keys.first;
//           int value = count[name];
//           chartData.add(ChartStackData(status, name, value));
//         });
//       });

//       return chartData;
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }

// class ChartStackData {
//   ChartStackData(this.status, this.name, this.value);
//   final String status;
//   final String name;
//   final int value;
// }

// class Sales {
//   final String quarter;
//   final int sales;

//   Sales(this.quarter, this.sales);
// }

// class MultilineChartData {
//   dynamic date;
//   final int count;
//   final String status;

//   MultilineChartData(this.date, this.count, this.status);
// }

// Future<List<ChartData>> fetchData(selectedDate) async {
//   String? clientId = await SharedPrefsHelper().getClientId();
//   String? userId = await SharedPrefsHelper().getMerchantUserId();
//   DateTime now = DateTime.now();
//   String startTime, endTime;

//   switch (selectedDate) {
//     case 'Today':
//       startTime = endTime = now.toIso8601String().split('T')[0];
//       break;
//     case 'Yesterday':
//       startTime =
//           now.subtract(Duration(days: 1)).toIso8601String().split('T')[0];
//       endTime = now.toIso8601String().split('T')[0];
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
//           'https://${Globals.DomainPointer}/dashboard-services/rest/v1/reports/896360/$userId/report/6?start_time=$startTime&end_time=$endTime'),
//       requestBody: "",
//     );

//     if (response != null && response.statusCode == 200) {
//       List<ChartData> data = [];
//       var jsonResponse = jsonDecode(response.body);
//       var results = jsonResponse['result']['result'];

//       for (var result in results) {
//         String status = result['Status'];
//         var counts = result['Counts'];

//         for (var count in counts) {
//           count.entries.forEach((entry) {
//             data.add(ChartData(status, entry.key, entry.value));
//           });
//         }
//       }

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

// class ChartData {
//   final String status;
//   final String category;
//   final int value;

//   ChartData(this.status, this.category, this.value);
// }
