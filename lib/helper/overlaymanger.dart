import 'package:flutter/services.dart';

class OverlayManager {
  static const MethodChannel _channel = MethodChannel( "com.example.flutter_catalog/overlay");

  // Start the overlay service
  Future<void> startOverlayService() async {
    try {
      await _channel.invokeMethod('startOverlayService');
    } on PlatformException catch (e) {
      print("Failed to start overlay service: ${e.message}");
    }
  }

  // Stop the overlay service
  Future<void> stopOverlayService() async {
    try {
      await _channel.invokeMethod('stopOverlayService');
    } on PlatformException catch (e) {
      print("Failed to stop overlay service: ${e.message}");
    }
  }

  // Check if the overlay service is running
  Future<bool> isOverlayServiceRunning() async {
    try {
      final bool isRunning = await _channel.invokeMethod('isOverlayServiceRunning');
      return isRunning;
    } on PlatformException catch (e) {
      print("Failed to check if overlay service is running: ${e.message}");
      return false;
    }
  }
}
