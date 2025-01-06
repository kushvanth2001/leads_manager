  import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/views/chat/NewChatDetailsController.dart';
import 'package:leads_manager/widgets/vedioplayerurl.dart';
import 'package:mime/mime.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

chatsBubbles(Message messages) {
    String direction = messages.direction ?? "";
    int timestamp = messages.timestamp ~/ 1;

    String time = getTime(timestamp);
    Widget textWidget;

    final String? urlMessage = messages.fileUrl;

    print("the $urlMessage ,urlmessage inside chatbubles");
    final RegExp urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final Iterable<RegExpMatch> matches = urlRegex.allMatches(urlMessage ?? '');

    if (matches.isNotEmpty) {
      final String url = matches.first.group(0)!;
      final String extension = url.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        textWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url),
            Text("${messages.message}",style: TextStyle(
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14
             ))
          ],
        );
      } else if (['mp4', 'avi', 'mov', 'wmv'].contains(extension)) {
 print("lamba");
print(urlMessage);
print(url);
 
     textWidget =  Column(
             mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey.withOpacity(0.25),
              child: InkWell(
                onTap: () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            url.split('/').last,
                            style:
                                TextStyle(color: Color.fromARGB(255, 27, 110, 178),fontWeight:  FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14,),
                          ),
                          Text(
                            '$extension',style: TextStyle(
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14,
             color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      splashColor: Colors.blue,
                      icon: Icon(Icons.file_download),
                      onPressed: () async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
             Text("${messages.message}",style: TextStyle(
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14
             ))
          ],
        );
      } else if (['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx']
          .contains(extension)) {
        textWidget = Column(
             mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey.withOpacity(0.25),
              child: InkWell(
                onTap: () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            url.split('/').last,
                            style:
                                TextStyle(color: Color.fromARGB(255, 27, 110, 178),fontWeight:  FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14,),
                          ),
                          Text(
                            '$extension',style: TextStyle(
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14,
             color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      splashColor: Colors.blue,
                      icon: Icon(Icons.file_download),
                      onPressed: () async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
             Text("${messages.message}",style: TextStyle(
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14
             ))
          ],
        );
      } else {
        if (urlMessage != null &&
            urlMessage.contains('https://filemanager.gupshup.io')) {
          textWidget = CachedNetworkImage(
            imageUrl: urlMessage,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Linkify(
              text: urlMessage,
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                }
              },
            ),
          );
        } else {
          textWidget = Linkify(
            text: urlMessage ?? '',
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              }
            },
          );
        }
      }
    } else {
      textWidget = Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: messages.message ?? '',
        style: TextStyle(color: kSecondayTextcolor,  fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14
        
        ),
        linkStyle: TextStyle(color: Colors.blue,
          fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 14
        
        ),
      );
    }

    if (direction.contains("IN")) {
      return Container(
        child: 
            Column(
              children: [
                Bubble(
                  style: SnapPeUI.styleSomebody,
                  child: textWidget,
                ),
                Container(
                  padding: EdgeInsets.only(top: 2),
                  alignment: Alignment.bottomLeft,
                  child:     Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      Text(
                        "$time",
                        style:
                            TextStyle(fontStyle: FontStyle.italic, color: Colors.white,
                            
                          fontWeight:    FontWeight.normal,
              
                fontSize: 14,
                            ),
                      ),
                    SizedBox(height: 2,),
       //messages.status==null? Icon( Icons.done_all,color: Colors.blue,):messages.status=="failed"?Icon(Icons.close,color: Colors.red,):messages.status=="received"?Icon(Icons.done_all,color: Colors.grey,):Icon(Icons.done_all,color: Colors.blue,)
                    ],
                  ),
                ),
              ],
            ),
      
      );
    } else {
      return Container(
        
       
           child: Column(
              children: [
                Bubble(
                  style: SnapPeUI.styleMe,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: 16.0,
                            right: 16.0), // Adjust the padding as needed
                        child: textWidget,
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: Icon(Icons.done_all,
                      //       color: const Color.fromARGB(
                      //           255, 115, 115, 115)), // This is the tick icon
                      // ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 2),
                  alignment: Alignment.bottomRight,
                  child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      Text(
                        "$time",
                        style:
                            TextStyle(fontStyle: FontStyle.italic, color: Colors.white,fontWeight:  FontWeight.normal,
            
                fontSize: 14,),
                      ),
                    SizedBox(height: 2,),
       messages.status==null? Container():messages.status!.toLowerCase()=="failed"?Icon(Icons.close,color: Colors.red,):messages.status!.toLowerCase()=="delivered"?Icon(Icons.done_all,color: Colors.grey,) :messages.status!.toLowerCase()=="sent"?Icon(Icons.check,color: Colors.grey,):  Icon(Icons.done_all,color: Colors.blue,)
                    ],
                  ),
                ),
              ],
            ),
            
        
      );
    }
    // if (direction.contains("IN")) {
    //   if (matches.isNotEmpty) {
    //     final String? url = urlMessage;
    //     if (url == null) {
    //       Linkify(
    //         onOpen: (link) async {
    //           if (await canLaunch(link.url)) {
    //             await launch(link.url);
    //           } else {
    //             throw 'Could not launch $link';
    //           }
    //         },
    //         text: messages.message ?? '',
    //         style: TextStyle(color: kSecondayTextcolor),
    //         linkStyle: TextStyle(color: Colors.blue),
    //       );
    //     } else {
    //       textWidget = Image.network(url);
    //     }
    //   } else {
    //     textWidget = Linkify(
    //       onOpen: (link) async {
    //         if (await canLaunch(link.url)) {
    //           await launch(link.url);
    //         } else {
    //           throw 'Could not launch $link';
    //         }
    //       },
    //       text: messages.message ?? '',
    //       style: TextStyle(color: kSecondayTextcolor),
    //       linkStyle: TextStyle(color: Colors.blue),
    //     );
    //   }

    //   return Container(
    //     child: Column(
    //       children: [
    //         Bubble(
    //           style: SnapPeUI.styleSomebody,
    //           child: textWidget,
    //         ),
    //         Container(
    //           padding: EdgeInsets.only(top: 2),
    //           alignment: Alignment.bottomLeft,
    //           child: Text(
    //             "$time",
    //             style:
    //                 TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }
  }
   String getTime(int timestamp) {
    var format = new DateFormat('dd MMM hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var str = format.format(date);
    return str;
  }
    String getDate(int timestamp) {
    var format = new DateFormat('dd-MM-yyyy');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var str = format.format(date);
    return str;
  }

  Future<bool>  overrideProcess (bool _isSwitched,bool isfromleadscreen,String customernumber) async{
    if (_isSwitched == true) {
      ChatDetailsController.istakeoverd.value=true;
      // ChatDetailsController.overRideStatusTitle.value = "Release";
      // _chatDetailsController.takeOver(
      //   widget.chatModel?.customerNo,
      //   widget.isFromLeadsScreen,
      // );
    await  postOverrideStatus(  customernumber

    , isfromleadscreen??false);
    return true;
    } else {
      ChatDetailsController.istakeoverd.value=false;
   await   deleteOverrideStatus( customernumber, isfromleadscreen??true);
      // ChatDetailsController.overRideStatusTitle.value = "TakeOver";
      // _chatDetailsController.release(
      //     widget.chatModel?.customerNo, widget.isFromLeadsScreen);
return false;
    }



  }



 Future<String?> showAttachmentDialog(List<String> msg) async {
  TextEditingController textEditingController = TextEditingController();
  List<Widget> chatBubbles = msg.map((e) => buildWidgetFromUrl(e)).toList();

  final result = await Get.dialog<String>(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Container(
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Container
            Container(
              height: 100,
              width: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: chatBubbles,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), // Circular image
              ),
            ),
            SizedBox(height: 20),
            // TextField
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter your text',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Send and Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Close the dialog without returning a value
                    Get.back();
                    print(msg); // Print the file link list
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // If no text is entered, return an empty string
                    String enteredText = textEditingController.text.trim();
                    // Close the dialog and return the text (or empty string)
                    Get.back(result: enteredText);
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );

  return result;
}


  
Widget buildWidgetFromUrl(String url) {
  final String extension = url.split('.').last.toLowerCase();

  if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
    return Image.network(url);
  } else if (['mp4', 'avi', 'mov', 'wmv'].contains(extension)) {
    return Icon(
            Icons.videocam,
            size: 50.0, // Adjust the size as needed
            color: Colors.blue, // Change the color as needed
          );
    // final VideoPlayerController _controller =
    //     VideoPlayerController.network(url);
    // final chewieController = ChewieController(
    //   videoPlayerController: _controller,
    //   autoPlay: false,
    //   looping: false,
    // );
    // return FittedBox(
    //   fit: BoxFit.contain,
    
    //   child: Chewie(
    //     controller: chewieController,
    //   ),
    // );
  } else if (['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx']
      .contains(extension)) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey.withOpacity(0.25),
      child: InkWell(
        onTap: () async {
          if (await canLaunch(url)) {
            await launch(url);
          }
        },
        child: Row(
          children: [
            Icon(Icons.insert_drive_file),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    url.split('/').last,
                    style: TextStyle(color: Color.fromARGB(255, 27, 110, 178)),
                  ),
                  Text(
                    '$extension',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              splashColor: Colors.blue,
              icon: Icon(Icons.file_download),
              onPressed: () async {
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            ),
          ],
        ),
      ),
    );
  } else {
    return Linkify(
      text: url,
      onOpen: (link) async {
        if (await canLaunch(link.url)) {
          await launch(link.url);
        }
      },
    );
  }
}
Future<bool> showTakeOverDialog(BuildContext context,) async {
  // Retrieve the initial checkbox state from SharedPrefsHelper
  bool isChecked =  false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Do you want to Take Over the Customer?'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Ensures dialog is only as big as needed
              children: [
                Text(
                  'If you take over the customer, the bot messages will stop being sent, '
                  'and you will be able to send messages. When you release the takeover, '
                  'the bot will be able to sending messages.',
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) async{
                        setState(() {
                          print(value);
                          isChecked=!isChecked;
                         // Update the checkbox state
                        });
                        print(isChecked);
                        // Save the updated checkbox value
                        SharedPrefsHelper().setShowTakeoverDiolouge(!isChecked);
                        var k=await SharedPrefsHelper().canShowTakeoverDiolouge();
                        print("PP");
                        print(k);
                      },
                    ),
                    Text('Do not show this again'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                
                  Navigator.of(context).pop(false); // Return false when "Cancel" is pressed
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
              
                  Navigator.of(context).pop(true); // Return true when "Yes" is pressed
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    },
  ) ?? false; // Default to false in case the dialog is dismissed without a choice
}
  Widget attachmentButton(ChatList chatList) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed:(){ _handleFileInput(chatList);},
        icon: const Icon(
          Icons.attach_file_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }
  


  void _handleFileInput(ChatList? chatinfo) async {
     String? fileType;
 List<dynamic> _selectedFiles = [];

try{
 final status = await Permission.storage.status;
  if (status.isDenied) {
    // Request permission
    await Permission.storage.request();
  }
}catch(e){
  print("Error in requesting Permission$e");
}



  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      
        _selectedFiles = result.files;
      

      for (var file in _selectedFiles) {
        String? filePath = file.path;
        String? mimeType;

        if (filePath != null) {
          mimeType = lookupMimeType(filePath);
          // Use the value of 'mimeType' here
        }

        if (mimeType != null) {
          List<String> parts = mimeType.split('/');
          fileType = parts[0];
          // Use the value of 'fileType' here
        } else {
          // Handle the case where 'mimeType' is null
          fileType = null;
        }
      }

     _uploadFiles(_selectedFiles,chatinfo);
     _selectedFiles=[];
    } else {
      // User canceled file selection or no files were picked
      // Handle this case as appropriate for your app
    }
  } catch (e) {
    // Handle error
    print('Error picking files: $e');
  }
}

    void _uploadFiles(List<dynamic> files,ChatList? chatinfo) async {
      List<String> returnedlinks=[];
    var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
    var uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/files/upload?bucket=taskBucket");
    var request = http.MultipartRequest('POST', uri);
var uuid = Uuid();

    for (var file in files) {
      
    File k= File(file.path) ;
      request.files.add(http.MultipartFile.fromBytes(
          'files', k.readAsBytesSync(),
          filename: file.path.split('/').last )
          
      );
    }
    var response = await NetworkHelper()
        .request(RequestType.post, uri, requestBody: request);
    if (response != null && response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      // handle response
      print("this is reponseJson $responseJson");
    var  fileLink = responseJson["documents"][0]["fileLink"];
      print("$fileLink");
   List<String> filelinklist =[];
 for(int i=0;i<responseJson["documents"].length;i++){
  filelinklist.add(responseJson["documents"][i]["fileLink"]);
 }
print(filelinklist);
String? attacmentmessage =await showAttachmentDialog(filelinklist);
print("/----------$attacmentmessage");
if(attacmentmessage!=null){
for(int i=0;i<responseJson["documents"].length;i++){

  final mimeType = lookupMimeType(responseJson["documents"][i]["fileLink"]);

  if (mimeType != null) {
    if (mimeType.startsWith('image/')) {
 
        await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    chatinfo?.customerNo!.value,
                    false,fileType:"image" ,attachmentmessgae:i==0?attacmentmessage:null);
    } else if (mimeType.startsWith('audio/')) {
        await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    chatinfo?.customerNo!.value,
                    false,fileType:"audio" ,attachmentmessgae:i==0?attacmentmessage:null);
    } else if (mimeType.startsWith('video/')) {
        await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                   chatinfo?.customerNo!.value,
                  false,fileType:"video",attachmentmessgae:i==0?attacmentmessage:null );
    } else if (mimeType.startsWith('application/pdf')) {
        await NewChatDetailsController().sendMessage(
                  responseJson["documents"][i]["fileLink"],
                    chatinfo?.customerNo!.value,
                    false,fileType: "document",attachmentmessgae:i==0?attacmentmessage:null);
    }else if (mimeType.startsWith('text/csv')) {
      await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                chatinfo?.customerNo!.value,
                    false,fileType:"document" ,attachmentmessgae:i==0?attacmentmessage:null);
    } 
    
    
    else if (mimeType.startsWith('text/')) {
      await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    chatinfo?.customerNo!.value,
                    false,fileType: "text",attachmentmessgae:i==0?attacmentmessage:null);
    } else {
        await NewChatDetailsController().sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    chatinfo?.customerNo!.value,
                    false,fileType: "text", attachmentmessgae:i==0?attacmentmessage:null);
    }
  } else {
    print("unknown to dtermine the type");
  }
}
    
      print("after chatcontoller");
    } else {
      throw Exception('Failed to upload files');
    }}
  }



String getlinktype(String fileurl){
   final mimeType = lookupMimeType(fileurl);

  if (mimeType != null) {
    if (mimeType.startsWith('image/')) {
 
     return"image";
    } else if (mimeType.startsWith('audio/')) {
    return"audio";
    } else if (mimeType.startsWith('video/')) {
       return"vedio";
    } else if (mimeType.startsWith('application/pdf')) {
       return"pdf";
    }else if (mimeType.startsWith('text/csv')) {
return"csv";
    } 
    
    
    else if (mimeType.startsWith('text/')) {
return "text";
    } else {
       return "Unknown";
    }
  } else {
    print("unknown to dtermine the type");
    return "unknown";
  }

}




Future<bool> selectedApplicationisWaba()async{
  String? cliengroupname=await SharedPrefsHelper().getClientGroupName();
 String selectedchatbot=await SharedPrefsHelper().getUserSelectedChatbot(cliengroupname);
 String? fristappname=await SharedPrefsHelper().getFristappName();
 selectedchatbot==''?selectedchatbot=fristappname??'':null;
 List<dynamic>? application=await SharedPrefsHelper().getApplications();
if(application!=null && selectedchatbot!='' ){
var k= application.firstWhere((app) => app['applicationName'] == selectedchatbot, orElse: () => null);

if(k["chanel"]=="waba"){
  return true;}else{ return false;}
}else{
  return false;
}
}
class TemplatesSearch extends SearchDelegate<String> {
  final List<dynamic>? templates;
  List<String> pinnedList = [];
  final prefsHelper = SharedPrefsHelper();
  SnapPeNetworks snapPeNetworks = SnapPeNetworks();
  final ValueNotifier<int> _notifier = ValueNotifier<int>(0);

  TemplatesSearch({this.templates}) {
    String propertyValue = prefsHelper.getPinnedTemplates();
    pinnedList = propertyValue.split(',');
  }

  Future<void> savePinnedItems() async {
    String pinnedListString = pinnedList.join(',');
    print("$pinnedListString");
    List<Map<String, dynamic>> properties = [
      {
        "status": "OK",
        "messages": [],
        "propertyName": "pinned_templates",
        "propertyType": "client_user_attributes",
        "name": "Pinned templates",
        "id": 7,
        "propertyValue": pinnedListString,
        "propertyAllowedValues": "",
        "propertyDefaultValues": "",
        "isEditable": true,
        "remarks": null,
        "category": "Application",
        "isVisibleToClient": true,
        "interfaceType": "character_text",
        "pricelistCode": null
      }
    ];
    snapPeNetworks.changeProperty(properties);
    prefsHelper.setPinnedTemplates(pinnedListString);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (templates == null || templates!.isEmpty) {
      return Center(
        child: Text('No templates found'),
      );
    }

    final results = templates!
        .where((template) =>
            template['data'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    results.sort((a, b) {
      bool aIsPinned = pinnedList.contains(a['elementName']);
      bool bIsPinned = pinnedList.contains(b['elementName']);

      if (aIsPinned && !bIsPinned) {
        return -1;
      } else if (!aIsPinned && bIsPinned) {
        return 1;
      } else {
        return 0;
      }
    });

    return ValueListenableBuilder<int>(
      valueListenable: _notifier,
      builder: (context, value, child) {
        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final data = results[index]['data'].split('\n').take(3).join(' ');
            final templateName = results[index]['elementName'];

            return ListTile(
              title: Text(templateName),
              subtitle: Text(data),
              trailing: IconButton(
                icon: Icon(
                  pinnedList.contains(templateName)
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                ),
                onPressed: () {
                  if (pinnedList.contains(templateName)) {
                    pinnedList.remove(templateName);
                  } else {
                    pinnedList.add(templateName);
                  }
                  savePinnedItems();
                  _notifier.value++;
                },
              ),
              onTap: () {
                close(context, results[index]['data']);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (templates == null || templates!.isEmpty) {
      return Center(
        child: Text('No templates found'),
      );
    }

    final suggestions = templates!
        .where((template) =>
            template['data'].toLowerCase().contains(query.toLowerCase()) ||
            template['elementName'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    suggestions.sort((a, b) {
      bool aIsPinned = pinnedList.contains(a['elementName']);
      bool bIsPinned = pinnedList.contains(b['elementName']);

      if (aIsPinned && !bIsPinned) {
        return -1;
      } else if (!aIsPinned && bIsPinned) {
        return 1;
      } else {
        return 0;
      }
    });

    return ValueListenableBuilder<int>(
      valueListenable: _notifier,
      builder: (context, value, child) {
        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final data =
                suggestions[index]['data'].split('\n').take(3).join(' ');
            final templateName = suggestions[index]['elementName'];

            return ListTile(
              title: Text(suggestions[index]['elementName']),
              subtitle: Text(data),
              trailing: IconButton(
                icon: Icon(
                  pinnedList.contains(templateName)
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                ),
                onPressed: () {
                  if (pinnedList.contains(templateName)) {
                    pinnedList.remove(templateName);
                  } else {
                    pinnedList.add(templateName);
                  }
                  savePinnedItems();
                  _notifier.value++;
                },
              ),
              onTap: () {
                close(context, suggestions[index]['data']);
              },
            );
          },
        );
      },
    );
  }
}


Future<bool?> ifwabaAskfordialogue(){


  return Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirmation'),
        content: Text('The Selected Application is Waba. Do you want to send an approved template first to initiate conversation?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
}