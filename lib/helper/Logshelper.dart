  
//  import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';

// import '../domainvariables.dart';
 
//  class  LogsHelper{
// static  Future<File?> getLogFile() async {
  
//   // try {
    

//   //   final directory = "/storage/emulated/0/Download";
//   //   final logFilePath = '${directory}/my_app_logs.log';
//   //   final logFile = File(logFilePath);

    
//   //   if (!await logFile.exists()) {
//   //     await logFile.create();
//   //   }

    
//   //   final now = DateTime.now();
//   //   final lastModified = await logFile.lastModified();
//   //   if (now.day != lastModified.day) {
//   //     await logFile.writeAsString('--- Log for ${now.toLocal()} ---\n',mode: FileMode.write);
//   //   }

//   //   return logFile;
//   // } catch (e) {
  
//   //   print('Error accessing log file: $e');
//   //   return File("");
//   // }
// }

// static Future<void> writeLog(String logText) async {
  
//   if(Globals.EnableLog){

//   final logFile = await getLogFile();
//   if (logFile != null && logFile.path!="") {
//     try{
//     await logFile.writeAsString('${formatDate(DateTime.now(), logText)}\n', mode: FileMode.append);}
//     catch(e){
//       log("$e");
//     }
//   }
// }else{
//   print("Log is not enabledto Write");
// }}

// static String formatDate(DateTime dateTime,String longstring) {
//   final day = dateTime.day.toString().padLeft(2, '0');
//   final month = dateTime.month.toString().padLeft(2, '0');
//   final year = dateTime.year;
//   final hour = dateTime.hour.toString().padLeft(2, '0');
//   final minute = dateTime.minute.toString().padLeft(2, '0');
//   final second = dateTime.second.toString().padLeft(2, '0');
//   final amPm = dateTime.hour < 12 ? 'AM' : 'PM';

//   return '[$day/$month/$year $hour:$minute:$second $amPm]:-----'+longstring;
// }
//  }
//  class LoggerSingleton {
//   static final LoggerSingleton _instance = LoggerSingleton._internal();
//   late Logger logger;

//   factory LoggerSingleton() {
//     return _instance;
//   }

//   LoggerSingleton._internal(){
//     initializeLogger();
//   }

//   Future<void> initializeLogger() async {
//     // final logFile = await LogsHelper.getLogFile();
//     // logger = Logger(
//     //   printer: SimplePrinter(),
//     //   output: MultiOutput([
//     //     ConsoleOutput(),
//     //     FileOutput(file: logFile),
//     //   ]),
//     // );
//   }

//  void logInfo(String message) {
//   try{
//     if (Globals.EnableLog) {
//       logger.i(message);
//     }
//   }
//   catch(e,stackTrace){
// FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'A non-fatal error occurred');
//   }
// }
//  }
// class SimplePrinter extends LogPrinter {
//   @override
//   List<String> log(LogEvent event) {
//    var k= '${LogsHelper. formatDate(DateTime.now(),   event.message)}\n';
//     return [k];
    
//   }
// }