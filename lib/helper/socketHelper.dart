// import 'package:leads_manager/Controller/chatDetails_controller.dart';
// import 'package:leads_manager/constants/networkConstants.dart';
// import 'package:leads_manager/helper/SharedPrefsHelper.dart';
// import 'package:leads_manager/utils/snapPeUI.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:typed_data';

// class SocketHelper {
//   SocketHelper.__privateConstructor();

//   static final SocketHelper _instance = SocketHelper.__privateConstructor();

//   static SocketHelper get getInstance => _instance;

//   Socket? _mSocket;

//   Socket? get getSocket {
//     print(
//         'SocketHelper getSocket called, returning $_mSocket and ${_mSocket?.id}');
//     return _mSocket;
//   }

//   String chatType = "agent";

//   String? sessionId;
//   String notificationSessionId =
//       DateTime.now().millisecondsSinceEpoch.toString();
//   String chatSessionId = (DateTime.now().millisecondsSinceEpoch + 1).toString();

//   initialize(liveAgentUserId, token, clientGroup) async {
//     try {
//       // Create an instance of the SharedPrefsHelper class
//       final prefs = SharedPrefsHelper();
//       // Retrieve the value of "chat_Socket_Session_Id" from SharedPreferences using the new getChatSessionId method
//       final chatSessonId = await prefs.getChatSessionId();
//       if (chatSessonId != null) {
//         // If a value is found, assign it to the chatSessionId property
//         this.chatSessionId = chatSessonId;
//       } else {
//         // If no value is found, store the current value of the chatSessionId property in SharedPreferences using the new setChatSessionId method
//         prefs.setChatSessionId(this.chatSessionId);
//       }

//       final String transportName = "websocket";

//       var query = {
//         "app_name": null,
//         "destination_id": null,
//         "live_agent_user_id": liveAgentUserId,
//         "type": chatType,
//         "token": token,
//         "source_applictaion": "merchant_dashboard",
//         "domain": NetworkConstants.SOCKET_DOMAIN,
//         "socket_type": "live_agent",
//         "client_group": clientGroup,
//         "divigo_session_id": chatSessionId,
//       };
//       print(query);

//       _mSocket = IO.io(
//           NetworkConstants.SOCKET_SERVER,
//           OptionBuilder()
//               .setQuery(query)
//               .enableReconnection()
//               .setReconnectionDelay(1000)
//               .setTimeout(10000)
//               .setTransports([transportName]).build());
//       print("SocketHelper initialize: _mSocket created $_mSocket");
//     } catch (ex) {
//       SnapPeUI().toastError(message: "Failed to initialize Socket Connection.");
//       print("Failed");
//     }
//   }
// // Add a key parameter to the sendMessage method

//   bool sendMessage(token, liveAgentUserId, String message, mobileNumber,
//       appName, clientGroup,
//       {String? fileType}) {
//     print("in sendmessage socket $message and ${_mSocket?.id}");
//     try {
//       if (ChatDetailsController.overRideStatusTitle.value == "TakeOver") {
//         print("$_mSocket  ");
//         SnapPeUI().toastError(message: "👤 Please TakeOver the customer.");
//         return false;
//       }
//       print("inside try $mobileNumber");
//       var json;
//       if (mobileNumber != "") {
//         print("inside if $mobileNumber");
//         if (fileType != null) {
//           print("inside if (fileType != null)");
//           json = {
//             "message": "",
//             "url": message,
//             "type": "$fileType",
//             'destination_id': mobileNumber,
//             "divigo_session_id": chatSessionId,
//             "app_name": appName
//           };
//         } else {
//           json = {
//             "message": message,
//             "type": "text",
//             'destination_id': mobileNumber,
//             "divigo_session_id": this.chatSessionId,
//             "app_name": appName
//           };
//         }
//       } else {
//         if (fileType != null) {
//           json = {
//             "message": "",
//             "url": message,
//             "type": "$fileType",
//             "divigo_session_id": this.chatSessionId,
//             "app_name": appName
//           };
//         } else {
//           json = {
//             "message": message,
//             "type": "text",
//             "divigo_session_id": this.chatSessionId,
//             "app_name": appName
//           };
//         }
//       }
//       print("json is $json");
//       playSoundFromAsset();
//       _mSocket!.emit(chatType, json);

//       return true;
//     } catch (ex) {
//       // SnapPeUI().toastError(message: "Send Again");
//       return false;
//     }
//   }

//   void disconnectPermanantly() {
//     if (_mSocket != null && _mSocket!.connected) {
//       _mSocket!.close();
//       _mSocket = null;
//       print("dissonnected  \n\n\b\n\\n\n\n\\n\n\\n\n\\n\\nn");
//     }
//   }

//   void disconnect() {
//     if (_mSocket != null && _mSocket!.connected) {
//       _mSocket!.disconnect();
//       print("dissonnected  \n\n\b\n\\n\n\n\\n\n\\n\n\\n\\nn");
//     }
//   }
// }

// playSoundFromAsset() async {
//   AudioPlayer _audioPlayer = AudioPlayer();
//   ByteData data = await rootBundle.load('assets/sounds/sentSound.mp3');
//   Uint8List bytes = data.buffer.asUint8List();
//   await _audioPlayer.playBytes(bytes);
// }














































// // import 'package:leads_manager/constants/networkConstants.dart';
// // import 'package:leads_manager/utils/snapPeUI.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:socket_io_client/socket_io_client.dart';

// // class SocketHelper {
// //   SocketHelper.__privateConstructor();

// //   static final SocketHelper _instance = SocketHelper.__privateConstructor();

// //   static SocketHelper get getInstance => _instance;

// //   // Use a Map to store multiple socket connections
// //   Map<String, Socket> _sockets = {};
// //   String chatType = "agent";
// //   // Add a public getter method to retrieve a socket connection from the _sockets map using a key
// //   Socket? getSocket(String key) => _sockets[key];

// //   initialize(
// //       String key, destinationId, appName, liveAgentUserId, token, clientGroup) {
// //     try {
// //       final String transportName = "websocket";

// //       var query = {
// //         "app_name": appName,
// //         "destination_id": destinationId,
// //         "live_agent_user_id": liveAgentUserId,
// //         "type": chatType,
// //         "token": token,
// //         "domain": NetworkConstants.SOCKET_DOMAIN,
// //         "client_group": clientGroup
// //       };
// //       print(query);

// //       _sockets[key] = IO.io(
// //           NetworkConstants.SOCKET_SERVER,
// //           OptionBuilder()
// //               .setQuery(query)
// //               .enableReconnection()
// //               .setReconnectionDelay(1000)
// //               .setTimeout(10000)
// //               .setTransports([transportName]).build());
// //     } catch (ex) {
// //       SnapPeUI().toastError(message: "Failed to initialize Socket Connection.");
// //       print("Failed");
// //     }
// //   }
// // // Add a key parameter to the sendMessage method

// //   bool sendMessage(String key, String message, {String? fileType}) {
// //     print("in sendmessage socket $message $fileType");
// //     try {
// //       // Retrieve the appropriate socket connection from the _sockets Map with the key
// //       final socket = _sockets[key];
// //       if (socket == null || socket!.disconnected) {
// //         SnapPeUI().toastError(message: "Please TakeOver the customer.");
// //         return false;
// //       }
// //       var json;
// //       if (fileType != null) {
// //         json = {"message": "", "url": message, "type": "$fileType"};
// //       } else {
// //         json = {"message": message, "type": "text"};
// //       }

// //       socket.emit(chatType, json);
// //       return true;
// //     } catch (ex) {
// //       SnapPeUI().toastError(message: "Failed to send message.");
// //       return false;
// //     }
// //   }

// //   void disconnect(String key) {
// //      // Retrieve the appropriate socket connection from the _sockets Map with the key
// //     final socket = _sockets[key];
// //     if (socket != null || socket!.connected) {
// //       socket!.disconnect();
// //     }
// //   }
// //   void clearSockets() {
// //   // Iterate over all the socket connections in the _sockets map
// //   _sockets.forEach((key, socket) {
// //     // Disconnect each socket connection
// //     socket.disconnect();
// //   });
// //   // Clear the _sockets map
// //   _sockets.clear();
// // }

// // }



















