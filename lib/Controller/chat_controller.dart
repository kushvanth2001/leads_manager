import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:leads_manager/services/localNotificationService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:http/http.dart' as http;
import 'package:leads_manager/helper/socketHelper.dart';
import '../models/model_chat.dart';
import '../utils/snapPeNetworks.dart';

class Global {
  static RxInt currentPage = RxInt(0);
  static RxInt previoustime =
      RxInt(DateTime.now().millisecondsSinceEpoch ~/ 1000);
  static RxInt currenttime =
      RxInt(DateTime.now().millisecondsSinceEpoch ~/ 1000);
      static bool ischatdetailsScreen=false;
}

class ChatController extends GetxController {
  static RxList<ChatModel> myChatList = <ChatModel>[].obs;
  static Rx<bool> isloading = false.obs;
  static RxList<ChatModel> newRequestList = <ChatModel>[].obs;
  static RxList<ChatModel> otherList = <ChatModel>[].obs;
  // static final currentTimeVar = <int>[].obs;
  // static final previousTimeVar = <int>[].obs;
  final StreamController<String> previewMessageController =
      StreamController<String>.broadcast();
  static const MethodChannel _channel =
      MethodChannel('samples.flutter.dev/mqtt');
// Add a scrollController property
  ScrollController scrollController = ScrollController();
  int currentPage = 0;
  late int currentTime;
  late int previousTime;
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler((call) async {
      print("the method handler called");
      switch (call.method) {
        case 'onDataReceived':
          String receivedData = call.arguments;
          // Handle the received data in your Flutter code
          print('Received data from Android: $receivedData');
          Map<String, dynamic> data = jsonDecode(receivedData);
          // Find the ChatModel object with the matching customerNo
          //  LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "app_name".toString(),body: "message".toString())));
          if (data["type"] == "customer-chat") {
            String k = await SharedPrefsHelper().getClientGroupName() ?? "";
            String p = SharedPrefsHelper().getUserSelectedChatbot(k);
            if (data["destination_id"] != null || data['destination_id']!='' || data['destination_id'].toString()!='null') {
              final state = WidgetsBinding.instance!.lifecycleState;
              if (state == AppLifecycleState.paused) {
                LocalNotificationService.createAndDisplayNotification(
                    RemoteMessage(
                        notification: RemoteNotification(
                            title: data["destination_id"].toString(),
                            body: data["message"].toString())));
              }
            }
          }else{
             if (data["destination_id"] != null || data['destination_id']!='' || data['destination_id'].toString()!='null') {
              final state = WidgetsBinding.instance!.lifecycleState;
              if (state == AppLifecycleState.paused) {
                LocalNotificationService.createAndDisplayNotification(
                    RemoteMessage(
                        notification: RemoteNotification(
                            title: data["destination_id"].toString(),
                            body: data["message"].toString())));
              }
            }}
          ChatModel? chat = myChatList.firstWhereOrNull(
              (chat) => chat.customerNo == data['destination_id']);
          print("create and display");

          if (chat != null) {
            // Update the preview_message property of the ChatModel object
            print("create and display");
            //  LocalNotificationService.createAndDisplayNotification(RemoteMessage(notification: RemoteNotification(title: "receivedData",body: "done")));
            chat.preview_message = data['message'];
            // Notify listeners that the myChatList property has changed
            myChatList.refresh();
          }
          // You can call a method or update a state with the received data
          break;
        // Add more cases as needed
        // ...
      }
    });
  }

  ChatController() {
    currentTime = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    previousTime = currentTime - 2629746;

    print("$currentTime,$previousTime");
    scrollListener();
  }
  static Future<RxInt> getUnreadMessageCount(String customerNo) async {
    final prefs = await SharedPreferences.getInstance();
    return RxInt(prefs.getInt('unread_$customerNo') ?? 0);
  }

  void listenForNewMessages() {
    _channel.setMethodCallHandler((call) async {
      print("the method handler called");
      switch (call.method) {
        case 'onDataReceived':
          String receivedData = call.arguments;
          // Handle the received data in your Flutter code
          print('Received data from Android: $receivedData');
          Map<String, dynamic> data = jsonDecode(receivedData);
          // Find the ChatModel object with the matching customerNo
          ChatModel? chat = myChatList.firstWhereOrNull(
              (chat) => chat.customerNo == data['destination_id']);
          print("create and display");
          LocalNotificationService.createAndDisplayNotification(RemoteMessage(
              notification:
                  RemoteNotification(title: "receivedData", body: "done")));
          if (chat != null) {
            // Update the preview_message property of the ChatModel object
            print("create and display");
            LocalNotificationService.createAndDisplayNotification(RemoteMessage(
                notification:
                    RemoteNotification(title: "receivedData", body: "done")));
            chat.preview_message = data['message'];
            // Notify listeners that the myChatList property has changed
            myChatList.refresh();
          }
          // You can call a method or update a state with the received data
          break;
        // Add more cases as needed
        // ...
      }
    });
  }

  @override
  void onClose() {
    previewMessageController.close();
    super.onClose();
  }

  void sortChatsByLastMessageTime() {
    myChatList.sort((a, b) {
      if (a.lastTs != null && b.lastTs != null) {
        return b.lastTs.compareTo(a.lastTs);
      } else if (a.lastTs != null) {
        return -1;
      } else if (b.lastTs != null) {
        return 1;
      } else {
        return 0;
      }
    });
    myChatList.sort((a, b) {
      if (a.lastTs != null && b.lastTs != null) {
        return a.lastTs.compareTo(b.lastTs);
      } else if (a.lastTs != null) {
        return 1;
      } else if (b.lastTs != null) {
        return -1;
      } else {
        return 0;
      }
    });
  }

  void scrollListener() {
    // Add a listener to the scrollController
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent - scrollController.offset ==
          0.0) {
        Global.currentPage.value++;
        String? response = await SnapPeNetworks().getAllChatData(
            page: 0,
            previousTime: Global.previoustime.value,
            currentTime: Global.previoustime.value);
        print("this is from scroll controller $response ");

        if (response != null) {
          List<ChatModel> tempChatList = chatModelFromJson(response);

          if (tempChatList.isNotEmpty) {
            print("tempChatList.isNotEmpty");
            try {
              print("previous time vlaue ${tempChatList.last.lastTs}");
              Global.previoustime.value = tempChatList.last.lastTs.toInt();

              print(
                  "previous time vlaue from scroll wheel ${Global.previoustime.value}");
            } catch (e) {
              print("chat erorr $e");
            }
            // Now you can use lastTimestamp in further operations
          }
        }
        print("Global page number ${Global.currentPage.value}");
        Future.microtask(() => loadData(
              page: 0,
            ));
      }
    });
  }

  Future<void> loadData({int page = 0, bool forcedReload = false}) async {
    print(" this is xyz $page");

    forcedReload == true
        ? Global.previoustime.value =
            DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000
        : null;

    if (forcedReload) {
      newRequestList.clear();
      isloading.value = true;
    }
    List<ChatModel> chatList = [];

    String? response = await SnapPeNetworks().getAllChatData(
        page: 0,
        previousTime: Global.previoustime.value,
        currentTime: Global.previoustime.value);
    if (response != null) {
      chatList = chatModelFromJson(response);
    }

    if (chatList.isEmpty) {
      Fluttertoast.showToast(msg: "The Message List is Empty Please Refresh ");
    }
    newRequestList.addAll(chatList);
    isloading.value = false;
  }

  void clearTimes() {
    Global.previoustime =
        RxInt(DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
  }
}
