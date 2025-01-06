import 'dart:convert';

import 'package:flutter/services.dart';

class ForegroundServiceManager {
  static const MethodChannel _channel = MethodChannel('com.example.foreground_service');

  static Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }
  
    static Future<void> showNotLeadOverlayDialog(Map<String, dynamic> data) async {
    try {
      String jsonString = jsonEncode(data);
      await _channel.invokeMethod('showNotLeadOverlayDialog', {'jsonString': jsonString});
    } on PlatformException catch (e) {
      print("Failed to show not lead overlay dialog: '${e.message}'.");
    }
  }
  static Future<void> showOverlayDialog(Map<String, dynamic> data) async {
    try {
      String jsonString = jsonEncode(data);
      await _channel.invokeMethod('showOverlayDialog', {'jsonString': jsonString});
    } on PlatformException catch (e) {
      print("Failed to show overlay dialog: '${e.message}'.");
    }
  }
}
