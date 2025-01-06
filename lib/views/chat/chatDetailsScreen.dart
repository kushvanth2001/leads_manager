import 'dart:io';
//import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:bubble/bubble.dart';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_rich_text/simple_rich_text.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/Controller/switch_controller.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/helper/socketHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/utils/SharedFunctions.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/chat/chatEntered.dart';
import 'package:leads_manager/views/chat/liveAgentScreen.dart';
import 'package:leads_manager/views/home.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../Controller/chatDetails_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/styleConstants.dart';
import 'package:http/http.dart' as http;
import '../../domainvariables.dart';
import '../../helper/mqttHelper.dart';
import '../../models/model_chat.dart';
import 'package:mime/mime.dart';
// import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:video_player/video_player.dart';

class ChatDetailsScreen extends StatefulWidget {
  final List<String?>? applicationNames;
  final ChatModel? chatModel;
  final isOther;
  final String? firstAppName;
  final LeadController leadController;
  final VoidCallback? onBack;
  final bool? isFromLeadsScreen;
  final bool? isFromNotification;
  final bool? fromActive;
  ChatDetailsScreen(
      {Key? key,
      required this.chatModel,
      this.isOther = false,
      this.firstAppName,
      this.onBack,
      required this.leadController,
      this.isFromLeadsScreen,
      this.applicationNames,
      this.isFromNotification,
      this.fromActive})
      : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen>
    with WidgetsBindingObserver {
  late ChatDetailsController _chatDetailsController;
  late final SharedFunctions sharedFunctions;
  final sendTextBoxController = TextEditingController();
  bool _isSwitched = false;
  final LeadController leadController = Get.find<LeadController>();
 // final SwitchController switchController = Get.find<SwitchController>();
  List<dynamic>? _templates = [];
  String? userselectedApplicationName;
  bool _isNavigatingBackFromTemplateSearch = false;
  String? defaultAppName;
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String? liveAgentUserName;
  int? leadId;
  late Lead leadd;
  final textController = TextEditingController();
  TextEditingController? txtFollowUpName;
  final TextEditingController txtDescription = new TextEditingController();
  final TextEditingController txtDateTime =
      new TextEditingController(text: DateTime.now().toString());
       ValueNotifier<bool> isfocused = ValueNotifier<bool>(false);
subscriber()async{
  try{
 String chatSessionId=await SharedPrefsHelper().getChatSessionId()??"0";
  await MqttManager.subscribeToTopic("$chatSessionId/delivery-event");
await MqttManager.subscribeToTopic("$chatSessionId/notify-dashboard");
await MqttManager.subscribeToTopic("$chatSessionId/customer-chat/customer");
  }catch(e){}
}
  @override
  void initState() {
    subscriber();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Global.ischatdetailsScreen=true;
    SharedPrefsHelper()
        .setInChatDetailsscreen(widget.chatModel?.customerNo.toString());
    if (widget.chatModel?.leadId is int) {
      leadId = widget.chatModel?.leadId;
    } else if (widget.chatModel?.leadId is String) {
      leadId = int.tryParse(widget.chatModel?.leadId);
    } else {}
    if (leadId != null) {
      initAsync(leadId, widget.chatModel?.customerNo, widget.firstAppName);
    }

    _loadAppNameAndTemplates(widget.chatModel?.customerNo);

    sendTextBoxController.addListener(() async {
      if (sendTextBoxController.text.startsWith('/')) {
        // Display searchable dialog box with list of templates
        final selectedTemplate = await showSearch(
          context: context,
          delegate: TemplatesSearch(templates: _templates),
        );

        if (selectedTemplate != null) {
          final text = utf8.decode(latin1.encode(selectedTemplate));
          sendTextBoxController.text = text;
        }
        // Update the value of the flag here
        _isNavigatingBackFromTemplateSearch = true;
      }
    });
//     _focusNode.addListener(() async {
//       if (_isSwitched == false) {
//         String? agentOverride = await getAgentOverride(
//             userselectedApplicationName ?? widget.firstAppName,
//             widget.chatModel?.customerNo);
//         // Only execute this code if we're not navigating back from the TemplateSearch page
//         if (!_isNavigatingBackFromTemplateSearch && (agentOverride == "0" || agentOverride == "null"))  {
//           if (_focusNode.hasFocus == true) {
//             setState(() {
//               _isSwitched = true;
//               postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
//              // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
//              // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
//               //ChatDetailsController.overRideStatusTitle.value = "Release";
//             });
//           }

//         } else {
//  if (_focusNode.hasFocus == true) {
//               setState(() {
//               _isSwitched = true;
//            postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
//              // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
//               ChatDetailsController.istakeoverd.value=true;
//              // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
//              // ChatDetailsController.overRideStatusTitle.value = "Release";
//             });
//  }
            
//           // Reset the value of the flag
//           _isNavigatingBackFromTemplateSearch = false;
//         }
//       }
//     });
   _focusNode
   
   .addListener(() async {
      if (_focusNode.hasFocus) {
       // setdata();
      
      }
    });
  
    print("afgter template coming here");
    print(widget.isFromLeadsScreen);
    _chatDetailsController = ChatDetailsController(context,fromlead: widget.isFromLeadsScreen??false);

    ChatDetailsController.emojiShowing.value = false;
    if (widget.chatModel != null) {
      print(
          "indie loadsdata the number is ${widget.chatModel?.customerNo} \n\n\\n/n/n//n/n/n/n/n/n/n/n//n//n/");

      _chatDetailsController
          .loadData(
              widget.isFromLeadsScreen ?? false, widget.chatModel?.customerNo)
          .then((_) {
        if (widget.chatModel?.customerNo != null) {
          getOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false ).then((value) {
            setState(() {
               _isSwitched=value; 
            });
          ChatDetailsController.istakeoverd.value=value;

});
          // switchController.getSwitchValue(
          //     widget.chatModel?.customerNo, widget.fromActive);
          // if (widget.fromActive == true) {
          //   postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
          //   // _chatDetailsController.takeOver(
          //   //   widget.chatModel?.customerNo,
          //   //   widget.isFromLeadsScreen,
          //   // );
          // }
        }
        print("$_isSwitched from initstate");
      });
    } else {
      Get.back();
    }


   // socketConnection();
  }
setdata()async{
    bool shouldShowDialog = await showTakeOverDialog(context,_focusNode);

        if (shouldShowDialog && !_isNavigatingBackFromTemplateSearch) {
          bool? showDialogResult = await showTakeOverDialog(context,_focusNode);;

          if (showDialogResult != null && showDialogResult == true) {
            setState(() {
              _isSwitched = true;
              postOverrideStatus(widget.chatModel?.customerNo, widget.isFromLeadsScreen ?? false);
              ChatDetailsController.istakeoverd.value = true;
            });
          }
        }

        _isNavigatingBackFromTemplateSearch = false;
}
  Future<void> initAsync(leadId, customerNo, selectedApplication) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unread_$customerNo');
    String clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    String? agentOverride = await getAgentOverride(
        userselectedApplicationName ?? selectedApplication, customerNo);
    // print("$agentOverride,${agentOverride.runtimeType} ");
    // if (agentOverride == "1") {
    //   _chatDetailsController.takeOver(
    //     customerNo,
    //     widget.isFromLeadsScreen,
    //   );
    //  // switchController.setSwitchValue(customerNo, true);
    // } else {
    //  _chatDetailsController.takeOver(
    //     customerNo,
    //     widget.isFromLeadsScreen,
    //   );
    // //  switchController.setSwitchValue(customerNo, false);
    // }
    // if (widget.fromActive == true) {
    //   _chatDetailsController.takeOver(customerNo, widget.isFromLeadsScreen,
    //       fromInitAsync: true);
    //   switchController.setSwitchValue(customerNo, true);
    // }

    print("inside initasync");
    leadd = await leadDetails(leadId);
    print(" after leadd api $leadd ");
// use the lead object here

    // if (leadId is int) {
    //   // leadId is already an int, so we can pass it directly to the getLeadDetails method
    //   SnapPeNetworks()
    //       .getLeadDetails(leadId)
    //       .then((leadResponse) {
    //         print("$leadId,$leadResponse from initasync ");
    //         if (leadResponse != null) {
    //           Map<String, dynamic> leadJson = json.decode(leadResponse);
    //           leadd = Lead.fromJson(leadJson);
    //         }
    //       })
    //       .catchError((error) {
    //         print("Error: $error");
    //       });if(leadd!=null){
    //    txtFollowUpName = new TextEditingController(
    //       text: 'Follow Up with ${leadd?.customerName}');
    //       print("intialized from chat detailscscreen\n\n\n\\n\\n\nn/n/n/n/n/n//n/n//nn\n\\n\n\n\n\\n\\n\n\\n\n/n//n/n/n/n//n//n/n//nn\\n\\n\n\\n\\\n\\n\n");

    //       sharedFunctions = SharedFunctions(
    //       leadController: widget.leadController,
    //       lead: leadd!,
    //       firstAppName: widget.firstAppName);}
    // } else if (leadId is String) {
    //   // leadId is a String, so we need to convert it to an int before passing it to the getLeadDetails method
    //   int? leadIdInt = int.tryParse(leadId);
    //   if (leadIdInt != null) {
    //     SnapPeNetworks()
    //         .getLeadDetails(leadIdInt)
    //         .then((leadResponse) {
    //           print("$leadId,$leadResponse from initasync ");
    //           if (leadResponse != null) {
    //             Map<String, dynamic> leadJson = json.decode(leadResponse);
    //             leadd = Lead.fromJson(leadJson);
    //           }
    //         })
    //         .catchError((error) {
    //           print("Error: $error");
    //         });
    txtFollowUpName = new TextEditingController(
        text: 'Follow Up with ${leadd?.customerName}');
    sharedFunctions = SharedFunctions(
        liveAgentUserName: liveAgentUserName,
        leadController: widget.leadController,
        lead: leadd,
        firstAppName: widget.firstAppName);
  }

  // void socketConnection() async {
  //   await _chatDetailsController.socketReconnection();
  // }

  void _loadAppNameAndTemplates(customerNo) async {
    liveAgentUserName = await SharedPrefsHelper().getMerchantName();
    // remove later , it is to connect to socket when notifcation is opened when in terminated state
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);

    if (widget.isFromLeadsScreen == true) {
      defaultAppName = await getAppName(customerNo);
    }
    print(
        "defaul app is $defaultAppName,${customerNo}, $userselectedApplicationName,${widget.firstAppName},$appName");
    GlobalChatNumbers.updateAppName(defaultAppName ??
        userselectedApplicationName ??
        widget.firstAppName ??
        appName!);
    print(
        "defaul app is $defaultAppName,${customerNo}, $userselectedApplicationName,${widget.firstAppName}");

    _getTemplates(defaultAppName ??
        userselectedApplicationName ??
        widget.firstAppName ??
        appName);
  }

  Future<void> _getTemplates(String? _selectedApplicationName) async {
    try {
      final templates = await getTemplates(_selectedApplicationName);
      if (mounted) {
        setState(() {
          _templates = templates;
        });
      }
    } catch (e) {
      // Handle the error here
      print(e);
      // _selectedApplicationName = firstAppName;
    }
  }

  @override
  void dispose() {
    Global.ischatdetailsScreen=false;
    // bool isSwitched =
    //     switchController.getSwitchValue(widget.chatModel!.customerNo);
    // if (isSwitched == true) {
    //   _chatDetailsController.release(widget.chatModel!.customerNo);
    // }
    // if (!_isSwitched) {
    // _chatDetailsController.disconnectSocketCon(widget.chatModel!.customerNo);
    // }
    WidgetsBinding.instance.removeObserver(this);
    SharedPrefsHelper().removeInChatDetailsscreen();
    GlobalChatNumbers.clearAppName();
    _chatDetailsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused) {
  //     SocketHelper.getInstance.getSocket
  //         ?.on(NetworkConstants.EVENT_MESSAGE_RECEIVED, (data) async {
  //       _chatDetailsController.showNotification(
  //           data['message'], data["destination_id"]);
  //     });
  //   } else if (state == AppLifecycleState.resumed) {
  //     // Remove the listener when the app is resumed
  //     SocketHelper.getInstance.getSocket
  //         ?.off(NetworkConstants.EVENT_MESSAGE_RECEIVED);
  //   }
  // }

  _onEmojiSelected(Emoji emoji) {
    //emoji
    // sendTextBoxController
    //   ..text += emoji.emoji
    //   ..selection = TextSelection.fromPosition(
    //       TextPosition(offset: sendTextBoxController.text.length));
  }

  _onBackspacePressed() {
    sendTextBoxController
      ..text = sendTextBoxController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: sendTextBoxController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => Home()),
        // );
        // Future.delayed(
        //   Duration(seconds: 2),
        //   () {
        //     ChatController().clearTimes();
        //     ChatController().loadData();
        //   },
        // );
        leadController.loadData(forcedReload: true);
        print("loading leads");
        return true;
      },
      child: Scaffold(
        appBar: appbar(),
        body: Container(
          //color: Colors.green[100],
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              chatsBody(),
              bottomContainer(),
              emojiKeyboard(),
            ],
          ),
        ),
      ),
    );
  }

  Obx emojiKeyboard() {
    return Obx(() => Offstage(
          offstage: !ChatDetailsController.emojiShowing.value,
          child: SizedBox(
            height: 250,
            child:Container()
            // child: EmojiPicker(
            //     onEmojiSelected: (Category category, Emoji emoji) {
            //       _onEmojiSelected(emoji);
            //     },
            //     onBackspacePressed: _onBackspacePressed,
            //     config: Config(
            //         columns: 7,
            //         emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            //         verticalSpacing: 0,
            //         horizontalSpacing: 0,
            //         initCategory: Category.RECENT,
            //         bgColor: const Color(0xFFF2F2F2),
            //         indicatorColor: Colors.blue,
            //         iconColor: Colors.grey,
            //         iconColorSelected: Colors.blue,
            //         progressIndicatorColor: Colors.blue,
            //         backspaceColor: Colors.blue,
            //         skinToneDialogBgColor: Colors.white,
            //         skinToneIndicatorColor: Colors.grey,
            //         enableSkinTones: true,
            //         showRecentsTab: true,
            //         recentsLimit: 28,
            //         noRecentsText: 'No Recents',
            //         noRecentsStyle: TextStyle(
            //             fontSize: kMediumFontSize, color: Colors.black26),
            //         tabIndicatorAnimDuration: kTabScrollDuration,
            //         categoryIcons: const CategoryIcons(),
            //         buttonMode: ButtonMode.MATERIAL)),
          ),
        ));
  }

  Expanded chatsBody() {
    return Expanded(child: Obx(() {
      if (ChatDetailsController.messageList.length == 0) {
        return Container();
      } else {
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(20),
          itemCount: ChatDetailsController.messageList.length,
          itemBuilder: (context, index) {
            print(
                "this is ${ChatDetailsController.messageList[0].type} in details screen");
            return chatsBubbles(ChatDetailsController.messageList[index]);
          },
        );
      }
    }));
  }

  AppBar appbar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.chatModel?.customerName != null,
            child: Text(
              "${widget.chatModel?.customerName ?? ""}",
              overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
            ),
          ),
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: "+${widget.chatModel?.customerNo}"));
              final snackBar = SnackBar(
                content: Text('Customer Number Copied'),
                behavior: SnackBarBehavior.fixed,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Text(
              "${widget.chatModel?.customerNo}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13,
               fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,

              ),
            ),
          )
        ],
      ),
      actions: [
        Switch(
          value: _isSwitched,
          // activeColor: Color.fromARGB(255, 0, 0, 0),
          onChanged: (bool value) {
            setState(() {
              _isSwitched = value;
            });
            // Call the onPressed function of the TextButton here
            onPressedBtn(_isSwitched);
            if (_isSwitched) {
              _focusNode.requestFocus();
            } else {
              _focusNode.unfocus();
            }
            // Update the switch value in the controller
            // print("from switch");
            // switchController.setSwitchValue(
            //     widget.chatModel!.customerNo, value);
            // print('Updated switch value: $value');
          },
        ),

        // TextButton(
        //     child: Obx(() => Text(
        //           ChatDetailsController.overRideStatusTitle.value,
        //           style:
        //               TextStyle(color: Colors.white, fontSize: kMediumFontSize),
        //         )),
        //     onPressed: () {
        //       onPressedBtn();
        //     }),
        PopupMenuButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: Container(
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(
                    Icons.call,
                    color: Color.fromARGB(255, 0, 122, 4),
                  ),
                  title: Text(
                    'Call',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    var url = "tel:+${widget.chatModel?.customerNo}";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
            ),
            PopupMenuItem(
                child: Container(
                    child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Image.asset(
                "assets/icon/whatsappIcon.png",
                width: 35,
              ),
              title: Text(
                'Message',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                var url =
                    "https://wa.me/${widget.chatModel?.customerNo}?text=Hello ${widget.chatModel?.customerName ?? ""}";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ))),
            if (leadId != null && widget.isFromLeadsScreen != true)
              PopupMenuItem(
                child: Container(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Icon(
                      Icons.info_outline,
                      color: Color.fromARGB(255, 30, 0, 122),
                    ),
                    title: Text(
                      'Details',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      
Get.to(()=>LeadDetails(lead:Lead(id: leadId) , isNewLead: false));

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => LeadDetails(
                      //               onBack: widget.onBack,
                      //               openAssignTagsDialog:
                      //                   sharedFunctions.openAssignTagsDialog,
                      //               menuItems: sharedFunctions.popUpMenu,
                      //               leadController: widget.leadController,
                      //               leadId: leadId,
                      //               lead: leadd,
                      //               isNewleadd: false,
                      //               isFromChat: true,
                      //               buildTags: sharedFunctions.buildTags,
                      //               textController: textController,
                      //               txtFollowUpName: txtFollowUpName,
                      //               txtDescription: txtDescription,
                      //               txtDateTime: txtDateTime,
                      //             )));
                    //  Get.to(LeadDetails());
                    },
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }

  void onPressedBtn(_isSwitched) {
    if (widget.isOther) {
      Get.defaultDialog(
          title: "Action",
          content: Text(
              "This customer is taken over by another agent. \n Do you want to takeOver? "),
          actions: [
            TextButton(
                onPressed: () {
                  overrideProcess(_isSwitched);
                  Get.back();
                },
                child: Text("Yes")),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text("No")),
          ]);
    } else {
      overrideProcess(_isSwitched);
    }
  }

  overrideProcess(_isSwitched) {
    if (_isSwitched == true) {
      ChatDetailsController.istakeoverd.value=true;
      // ChatDetailsController.overRideStatusTitle.value = "Release";
      // _chatDetailsController.takeOver(
      //   widget.chatModel?.customerNo,
      //   widget.isFromLeadsScreen,
      // );
      postOverrideStatus(  widget.chatModel?.customerNo
    , widget.isFromLeadsScreen??false);
    } else {
      ChatDetailsController.istakeoverd.value=false;
      deleteOverrideStatus( widget.chatModel?.customerNo, widget.isFromLeadsScreen??true);
      // ChatDetailsController.overRideStatusTitle.value = "TakeOver";
      // _chatDetailsController.release(
      //     widget.chatModel?.customerNo, widget.isFromLeadsScreen);
    }
  }

  LayoutBuilder bottomContainer() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          color: Colors.transparent,
          padding: EdgeInsetsDirectional.all(10),
          height: sendTextBoxController.text.split('\n').length > 3 ? 100 : 66,
          child: Row(
            children: [
              
              // emojiButton(),
              messageTextbox(),
              sendButton(),
            ],
          ),
        );
      },
    );
  }

  Material sendButton() {
    return Material(
      color: Colors.transparent,
      child: IconButton(
          onPressed: () async {
            if (sendTextBoxController.text.trim().isNotEmpty &&
                await _chatDetailsController.sendMessage(
                    sendTextBoxController.text.trim(),
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen)) {
              sendTextBoxController.clear();
            }
          },
          icon: const Icon(
            Icons.send,
            color: Colors.green,
          )),
    );
  }

  final _focusNode = FocusNode();

  Flexible messageTextbox() {
    return Flexible(

      child: new ConstrainedBox(
        constraints: new BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: 60.0,
          maxHeight: 135.0,
        ),
        child: new Scrollbar(
          child: new TextField(
            onTap: ()async{
                 
bool canshow=await  sharedPrefsHelper.canShowTakeoverDiolouge();
print("candhoe$canshow");
if(canshow){
     bool permofromoperation =    await   showTakeOverDialog(context,_focusNode);
    if( permofromoperation){
   
           setState(() {
              _isSwitched = true;
           postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
             // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
              ChatDetailsController.istakeoverd.value=true;
             // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
             // ChatDetailsController.overRideStatusTitle.value = "Release";
            });
    }else{
        _focusNode.unfocus();
    }
}    else{


        if (_isSwitched == false) {
        String? agentOverride = await getAgentOverride(
            userselectedApplicationName ?? widget.firstAppName,
            widget.chatModel?.customerNo);
        // Only execute this code if we're not navigating back from the TemplateSearch page
        if (!_isNavigatingBackFromTemplateSearch && (agentOverride == "0" || agentOverride == "null"))  {
          if (_focusNode.hasFocus == true) {
            setState(() {
              _isSwitched = true;
              postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
              ChatDetailsController.istakeoverd.value=true;
             // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
             // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
              //ChatDetailsController.overRideStatusTitle.value = "Release";
            });
          }

        } else {
 if (_focusNode.hasFocus == true) {
              setState(() {
              _isSwitched = true;
           postOverrideStatus(widget.chatModel?.customerNo,widget.isFromLeadsScreen??false);
             // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
              ChatDetailsController.istakeoverd.value=true;
             // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
             // ChatDetailsController.overRideStatusTitle.value = "Release";
            });
 }
            
          // Reset the value of the flag
          _isNavigatingBackFromTemplateSearch = false;
        }}
}  

            },
            cursorColor: Colors.red,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.sentences,
            controller: sendTextBoxController,
            decoration: InputDecoration(
              suffixIcon:_isSwitched? attachmentButton():Container(height: 0,width: 0,) ,
              prefixIcon: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                      ChatDetailsController.emojiShowing.value =
                          !ChatDetailsController.emojiShowing.value;
                    }
                  },
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.only(
                  left: 16.0, bottom: 0, top: 10.0, right: 16.0),
              hintText: "Type or Enter ' / '",
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );

    // return Expanded(
    //   child: ConstrainedBox(
    //     constraints: BoxConstraints(maxHeight: 90),
    //     child: SingleChildScrollView(
    //       child: TextFormField(
    //         maxLines: null,
    //         controller: sendTextBoxController,
    //         keyboardType: TextInputType.multiline,
    //         focusNode: _focusNode,
    //         style: TextStyle(fontSize: kMediumFontSize, color: Colors.black87),
    //         decoration: InputDecoration(
    //           hintText: "Type a message or Enter ' / '",
    //           filled: true,
    //           fillColor: Colors.white,
    //           contentPadding: const EdgeInsets.only(
    //               left: 16.0, bottom: 8.0, top: 8.0, right: 16.0),
    //           border:
    //               OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  // emojiButton() {
  //   return Material(
  //     color: Colors.transparent,
  //     child: IconButton(
  //       onPressed: () {
  //         _focusNode.unfocus();
  //         ChatDetailsController.emojiShowing.value =
  //             !ChatDetailsController.emojiShowing.value;
  //       },
  //       icon: const Icon(
  //         Icons.emoji_emotions,
  //         color: Colors.white,
  //       ),
  //     ),
  //   );
  // }

  void _requestPermission()async {
    var status = await Permission.photos.status;
  
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      // Show a dialog box
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Denied'),
            content: Text(
                'Please allow the app to access files for the functionality'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
              ElevatedButton(
                child: Text('Okay'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget attachmentButton() {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: _handleFileInput,
        icon: const Icon(
          Icons.attach_file_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

 List<dynamic> _selectedFiles = [];

  String? fileType;
  void _handleFileInput() async {

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

     _uploadFiles(_selectedFiles);
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

    void _uploadFiles(List<dynamic> files) async {
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
if(attacmentmessage!=null){
for(int i=0;i<=responseJson["documents"].length;i++){

  final mimeType = lookupMimeType(responseJson["documents"][i]["fileLink"]);

  if (mimeType != null) {
    if (mimeType.startsWith('image/')) {
 
        await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType:"image" ,attachmentmessgae:i==0?attacmentmessage:null);
    } else if (mimeType.startsWith('audio/')) {
        await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType:"audio" ,attachmentmessgae:i==0?attacmentmessage:null);
    } else if (mimeType.startsWith('video/')) {
        await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType:"video",attachmentmessgae:i==0?attacmentmessage:null );
    } else if (mimeType.startsWith('application/pdf')) {
        await _chatDetailsController.sendMessage(
                  responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType: "document",attachmentmessgae:i==0?attacmentmessage:null);
    }else if (mimeType.startsWith('text/csv')) {
      await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType:"document" ,attachmentmessgae:i==0?attacmentmessage:null);
    } 
    
    
    else if (mimeType.startsWith('text/')) {
      await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType: "text",attachmentmessgae:i==0?attacmentmessage:null);
    } else {
        await _chatDetailsController.sendMessage(
                    responseJson["documents"][i]["fileLink"],
                    widget.chatModel!.customerNo,
                    widget.isFromLeadsScreen,fileType: "text", attachmentmessgae:i==0?attacmentmessage:null);
    }
  } else {
    print("unknown to dtermine the type");
  }
}
      // await _chatDetailsController.sendMessage(
      //               "",
      //               widget.chatModel!.customerNo,
      //               widget.isFromLeadsScreen,fileType: )
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


Widget buildWidgetFromUrl(String url) {
  final String extension = url.split('.').last.toLowerCase();

  if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
    return Image.network(url);
  } else if (['mp4', 'avi', 'mov', 'wmv'].contains(extension)) {
    final VideoPlayerController _controller =
        VideoPlayerController.network(url);
    final chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
    );
    return FittedBox(
      fit: BoxFit.contain,
    
      child: Chewie(
        controller: chewieController,
      ),
    );
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
Future<String?> showAttachmentDialog(List<String> msg) async {
  TextEditingController textEditingController = TextEditingController();
  List<Widget> chatBubbles = msg.map((e) => buildWidgetFromUrl(e)).toList();

  final result = await Get.dialog(
    barrierDismissible: false,
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
                    if (enteredText.isEmpty) {
                      enteredText = ""; // Handle empty text case
                    }
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
  );

  return result; // Return the result (user input or empty string) from the dialog
}
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
        final VideoPlayerController _controller =
            VideoPlayerController.network(url);
        final chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
        );
        textWidget = Column(
           mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              
              child: Chewie(
                controller: chewieController,
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
}

class Emoji {
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

// class TemplatesSearch extends SearchDelegate<String> {
//   final List<dynamic>? templates;
//   List<String> pinnedList = []; // Add this line
//   final prefsHelper = SharedPrefsHelper();
//   SnapPeNetworks snapPeNetworks = SnapPeNetworks();
//   TemplatesSearch({this.templates}) {
//     String propertyValue = prefsHelper.getPinnedTemplates();
//     pinnedList = propertyValue.split(','); // Add this line
//   }

//   Future<void> savePinnedItems() async {
//     String pinnedListString = pinnedList.join(',');
//     print("$pinnedListString");
//     List<Map<String, dynamic>> properties = [
//       {
//         "status": "OK",
//         "messages": [],
//         "propertyName": "pinned_templates",
//         "propertyType": "client_user_attributes",
//         "name": "Pinned templates",
//         "id": 7,
//         "propertyValue": pinnedListString,
//         "propertyAllowedValues": "",
//         "propertyDefaultValues": "",
//         "isEditable": true,
//         "remarks": null,
//         "category": "Application",
//         "isVisibleToClient": true,
//         "interfaceType": "character_text",
//         "pricelistCode": null
//       }
//     ];
//     snapPeNetworks.changeProperty(properties);
//     prefsHelper.setPinnedTemplates(pinnedListString);
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     if (templates == null || templates!.isEmpty) {
//       return Center(
//         child: Text('No templates found'),
//       );
//     }

//     final results = templates!
//         .where((template) =>
//             template['data'].toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     results.sort((a, b) {
//       bool aIsPinned = pinnedList.contains(a['elementName']);
//       bool bIsPinned = pinnedList.contains(b['elementName']);

//       if (aIsPinned && !bIsPinned) {
//         return -1;
//       } else if (!aIsPinned && bIsPinned) {
//         return 1;
//       } else {
//         return 0;
//       }
//     });

//     return ListView.separated(
//       itemCount: results.length,
//       separatorBuilder: (context, index) => Divider(),
//       itemBuilder: (context, index) {
//         final data = results[index]['data'].split('\n').take(3).join(' ');
//         final templateName = results[index]['elementName'];

//         return ListTile(
//           title: Text(templateName),
//           subtitle: Text(data),
//           trailing: IconButton(
//             icon: Icon(
//               pinnedList.contains(templateName)
//                   ? Icons.push_pin
//                   : Icons.push_pin_outlined,
//             ),
//             onPressed: () {
//               if (pinnedList.contains(templateName)) {
//                 pinnedList.remove(templateName);
//               } else {
//                 pinnedList.add(templateName);
//               }
//               savePinnedItems();
//               showResults(context);
//             },
//           ),
//           onTap: () {
//             close(context, results[index]['data']);
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     if (templates == null || templates!.isEmpty) {
//       return Center(
//         child: Text('No templates found'),
//       );
//     }

//     final suggestions = templates!
//         .where((template) =>
//             template['data'].toLowerCase().contains(query.toLowerCase()) ||
//             template['elementName'].toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     suggestions.sort((a, b) {
//       bool aIsPinned = pinnedList.contains(a['elementName']);
//       bool bIsPinned = pinnedList.contains(b['elementName']);

//       if (aIsPinned && !bIsPinned) {
//         return -1;
//       } else if (!aIsPinned && bIsPinned) {
//         return 1;
//       } else {
//         return 0;
//       }
//     });

//     return ListView.separated(
//       itemCount: suggestions.length,
//       separatorBuilder: (context, index) => Divider(),
//       itemBuilder: (context, index) {
//         final data = suggestions[index]['data'].split('\n').take(3).join(' ');
//         final templateName = suggestions[index]['elementName'];

//         return ListTile(
//           title: Text(suggestions[index]['elementName']),
//           subtitle: Text(data),
//           trailing: IconButton(
//             icon: Icon(
//               pinnedList.contains(templateName)
//                   ? Icons.push_pin
//                   : Icons.push_pin_outlined,
//             ),
//             onPressed: () {
//               if (pinnedList.contains(templateName)) {
//                 pinnedList.remove(templateName);
//               } else {
//                 pinnedList.add(templateName);
//               }
//               savePinnedItems();
//               showResults(context);
//             },
//           ),
//           onTap: () {
//             close(context, suggestions[index]['data']);
//           },
//         );
//       },
//     );
//   }
// }

// class TemplatesSearch extends SearchDelegate<String> {
//   final List<dynamic>? templates;
//   TemplatesSearch({this.templates});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     if (templates == null || templates!.isEmpty) {
//       return Center(
//         child: Text('No templates found'),
//       );
//     }

//     final results = templates!
//         .where((template) =>
//             template['data'].toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return ListView.separated(
//       itemCount: results.length,
//       separatorBuilder: (context, index) => Divider(),
//       itemBuilder: (context, index) {
//         final data = results[index]['data'].split('\n').take(3).join(' ');
//         return ListTile(
//           title: Text(results[index]['elementName']),
//           subtitle: Text(data),
//           trailing: IconButton(
//             icon: Icon(Icons.push_pin),
//             onPressed: () {},
//           ),
//           onTap: () {
//             close(context, results[index]['data']);
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     if (templates == null || templates!.isEmpty) {
//       return Center(
//         child: Text('No templates found'),
//       );
//     }

//     final suggestions = templates!
//         .where((template) =>
//             template['data'].toLowerCase().contains(query.toLowerCase()) ||
//             template['elementName'].toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return ListView.separated(
//       itemCount: suggestions.length,
//       separatorBuilder: (context, index) => Divider(),
//       itemBuilder: (context, index) {
//         final data = suggestions[index]['data'].split('\n').take(3).join(' ');
//         return ListTile(
//           title: Text(suggestions[index]['elementName']),
//           subtitle: Text(data),
//           trailing: IconButton(
//             icon: Icon(Icons.push_pin),
//             onPressed: () {},
//           ),
//           onTap: () {
//             close(context, suggestions[index]['data']);
//           },
//         );
//       },
//     );
//   }
// }

Future<Lead> leadDetails(int? leadId) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$leadId'),
    requestBody: "",
  );

  if (response != null) {
    String responseBody = response.body;
    Map<String, dynamic> leadJson = json.decode(responseBody);
    Lead lead = Lead.fromJson(leadJson);
    return lead;
  } else {
    throw Exception('Failed to load lead details');
  }
}

Future<String?> getAgentOverride(selectedApplication, customerNo) async {
  try {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$customerNo?merchantName=$clientGroupName'),
      requestBody: "",
    );
    if (response != null) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print("$data");
      print(  'https://${Globals.DomainPointer}/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$customerNo?merchantName=$clientGroupName');
      String? agentOverride = data['override']['agent_override'].toString();
      print("$agentOverride from api call");
      return agentOverride;
    } else {
      // Handle error
      return null;
    }
  } catch (e) {
    // Handle exception
    print(e);
    return null;
  }
}
// Future<String?> getAgentOverride(selectedApplication, customerNo) async {
//   try {
//     String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//     String k = await SharedPrefsHelper().getMerchantUserId() ?? "";
    
//     Map<String, dynamic> requestBody = {
//       "live_agent_user_id": k,
//       "client_group": clientGroupName
//     };
//     print(requestBody);

//     final response = await NetworkHelper().request(
//       RequestType.post,
//       Uri.parse('https://retail.snap.pe/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$customerNo?merchantName=$clientGroupName'),
//       requestBody: jsonEncode(requestBody),
//     );

//     if (response != null) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//       print(response.statusCode);
//       print("$data");
//       print('https://retail.snap.pe/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$customerNo?merchantName=$clientGroupName');
   
//       return "1";
//     } else {
//       // Handle error
//       return null;
//     }
//   } catch (e) {
//     // Handle exception
//     print("error from agent over ride $e");
//     return null;
//   }
// }

Future<bool> showTakeOverDialog(BuildContext context, FocusNode focusNode) async {
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
                  focusNode.unfocus();
                  Navigator.of(context).pop(false); // Return false when "Cancel" is pressed
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  focusNode.unfocus();
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
