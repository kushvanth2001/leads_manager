import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'dart:math';

import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/chatsidshelper.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/NewChatDetailsController.dart';
import 'package:leads_manager/views/chat/chatlistcontroller.dart';
import 'package:leads_manager/views/chat/chatwidgets.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:load_switch/load_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class Indetailchatscreen extends StatefulWidget {
  final ChatList chatinfo;
  final bool isFromLeadsScreen;

  const Indetailchatscreen({
    Key? key,
    required this.chatinfo,
    this.isFromLeadsScreen = false,

  }) : super(key: key);
  @override
  State<Indetailchatscreen> createState() => _IndetailchatscreenState();
}

class _IndetailchatscreenState extends State<Indetailchatscreen> {
  late NewChatDetailsController newchatdetailsController;
  TextEditingController inputfeildController = new TextEditingController();
  bool isswithed = false;
  List<dynamic>? templates=[];
  FocusNode focusNode=FocusNode();
  //bool waitforuserinteractiononswitch=false;
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String? seletedchatbot;
  @override
  void initState() {
    super.initState();
    initAsync();
  }

@override
void dispose() {

   //Get.delete<NewChatDetailsController>();
  super.dispose();
}

  void initAsync()async{
    ChatIdsHelper.resubscribe();
  if (widget.chatinfo.customerNo.value != null) {
if (!Get.isRegistered<NewChatDetailsController>()) {
      Get.put(NewChatDetailsController());
    }
newchatdetailsController = Get.find<NewChatDetailsController>();
  
      
      newchatdetailsController.isFromLeadScreen=widget.isFromLeadsScreen;
      NewChatDetailsController.chatinfo=widget.chatinfo;
             newchatdetailsController.loadData(widget.isFromLeadsScreen ?? false, widget.chatinfo?.customerNo.value);
          var client=await SharedPrefsHelper().getClientGroupName();

        var sel=await SharedPrefsHelper().getUserSelectedChatbot(client);
        seletedchatbot=sel;
      ChatListController.selectedApplication=sel;
      getOverrideStatus(widget.chatinfo.customerNo.value,widget.isFromLeadsScreen ?? false).then((value) {
        setState(() {
          isswithed = value;
        });
        NewChatDetailsController.istakeoverd.value = value;
      });
   

  final templatess=await getTemplates(ChatListController.selectedApplication);
   if (mounted) {setState(() {
  templates    = templatess;
   });}
    }


    if(mounted){
//     Message? message=  NewChatDetailsController.messageList.lastOrNull;
// var activeinpast24=false;
// message!=null?activeinpast24=(DateTime.now().difference( DateTime.fromMillisecondsSinceEpoch(message.timestamp)).inHours>=24)?true:false:false;
//       if(ChatListController.iswaba.value && !isswithed && !activeinpast24){

//    var k  = await  ifwabaAskfordialogue();
//    waitforuserinteractiononswitch=k??false;
// print(waitforuserinteractiononswitch);
// if(waitforuserinteractiononswitch){
//  final selectedTemplate = await showSearch(
//           context: context,
//           delegate: TemplatesSearch(templates: templates),
//         );

//         if (selectedTemplate != null) {
//           final text = utf8.decode(latin1.encode(selectedTemplate));
//           inputfeildController.text = text;
//         }else{
//           inputfeildController.clear();
//         }
//       }}
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 leading:  Padding(
   padding: const EdgeInsets.all(8.0),
   child: InkWell(
    onTap: (){
   (widget.chatinfo.leadId.value != null &&
                  widget.chatinfo.leadId.value != '')?Get.to(() => LeadDetails(
                        lead: Lead(mobileNumber: widget.chatinfo.customerNo.value,id: int.parse(widget.chatinfo.leadId.value,)),
                        isNewLead: false)):null;
    },
     child: Container(
      margin: EdgeInsets.only(left: 6),
              width: 40.0, // Adjust size as needed
              height: 40.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 24.0, // Adjust icon size as needed
              ),
            ),
   ),
 ),
      
        backgroundColor: Color(0xFF181C14),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.chatinfo?.customerName != null,
              child: Text(
                "${widget.chatinfo?.customerName ?? ""}",
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
                    ClipboardData(text: "+${widget.chatinfo?.customerNo}"));
                final snackBar = SnackBar(
                  content: Text('Customer Number Copied'),
                  behavior: SnackBarBehavior.fixed,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text(
                "${widget.chatinfo?.customerNo}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                ),
              ),
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LoadSwitch(
              width: 45,
              height: 20,
              value: isswithed,
              future: () => overrideProcess(
                  !isswithed, false, widget.chatinfo.customerNo.value),
              style: SpinStyle.material,
              onChange: (v) {
              
                setState(() {
                    isswithed = v;
                    NewChatDetailsController.istakeoverd.value=v;
                   // waitforuserinteractiononswitch=false;
                });
              },
              onTap: (v) {
                print('Tapping while value is $v');
              },
            ),
          ),
       
          IconButton(
              onPressed: () async {
                var url = "tel:+${widget.chatinfo?.customerNo.value}";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              icon: Icon(Icons.phone))
        ],
      ),
      body: Column(
        children: [
          chatsBody(),
          Container(
            color: Colors.black,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: new ConstrainedBox(
                    constraints: new BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                      maxWidth: MediaQuery.of(context).size.width,
                      minHeight: 60.0,
                      maxHeight: 135.0,
                    ),
                    child: new Scrollbar(
                      child: new TextField(
                        focusNode: focusNode,
                        maxLines: 5,
                        onChanged: (value)async{
if(value=='/'){

 templates==[]?templates=await getTemplates(ChatListController.selectedApplication):null;
        // Display searchable dialog box with list of templates
        final selectedTemplate = await showSearch(
          context: context,
          delegate: TemplatesSearch(templates: templates),
        );

        if (selectedTemplate != null) {
          final text = utf8.decode(latin1.encode(selectedTemplate));
          inputfeildController.text = text;
        }else{
          inputfeildController.clear();
        }
}

                        },
                        onTap: () async {
                onTapofTextfeild(this);
                        },
                        cursorColor: Colors.red,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        controller: inputfeildController,
                        decoration: InputDecoration(
                          suffixIcon: isswithed
                              ? attachmentButton(widget.chatinfo)
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                          prefixIcon: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: () {
                                // if (_focusNode.hasFocus) {
                                //   _focusNode.unfocus();
                                //   ChatDetailsController.emojiShowing.value =
                                //       !ChatDetailsController.emojiShowing.value;
                                // }
                              },
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0)),
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
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                      onPressed: () async {
                        //  if(waitforuserinteractiononswitch){

                        //   //call the api
                        //  }else{

                        if (inputfeildController.text.trim().isNotEmpty &&
                            await newchatdetailsController.sendMessage(
                                inputfeildController.text.trim(),
                                widget.chatinfo!.customerNo.value,
                                widget.isFromLeadsScreen)) {
                          inputfeildController.clear();
                        }
                        
                        //}
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.green,
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

//body

  Expanded chatsBody() {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg.png'), fit: BoxFit.cover)),
      child: Obx(() {
        if (NewChatDetailsController.isLoading.value == true) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        } else {
          if (NewChatDetailsController.messageList.length == 0) {
            print('returning container');
            return Container();
          } else {
            return ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(20),
              itemCount: NewChatDetailsController.messageList.length,
              itemBuilder: (context, index) {
                print(
                    "this is ${NewChatDetailsController.messageList[0].type} in details screen");
                return chatsBubbles(
                    NewChatDetailsController.messageList[index]);
              },
            );
          }
        }
      }),
    ));
  }

  //  &&
  //               await _chatDetailsController.sendMessage(
  //                   sendTextBoxController.text.trim(),
  //                   widget.chatModel!.customerNo,
  //                   widget.isFromLeadsScreen

//   Flexible messageTextbox() {
//     return Flexible(
//       child: new ConstrainedBox(
//         constraints: new BoxConstraints(
//           minWidth: MediaQuery.of(context).size.width,
//           maxWidth: MediaQuery.of(context).size.width,
//           minHeight: 60.0,
//           maxHeight: 135.0,
//         ),
//         child: new Scrollbar(
//           child: new TextField(
//             onTap: () async {
//               try{
//          onTapofTextfeild(this);}catch(e){
//           print("on tap error$e");
//          }
//             },
//             cursorColor: Colors.red,
//             keyboardType: TextInputType.multiline,
//             maxLines: null,
//             textCapitalization: TextCapitalization.sentences,
//             controller: inputfeildController,
//             decoration: InputDecoration(
//               suffixIcon: isswithed
//                   ? attachmentButton()
//                   : Container(
//                       height: 0,
//                       width: 0,
//                     ),
//               prefixIcon: Material(
//                 color: Colors.transparent,
//                 child: IconButton(
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.emoji_emotions_outlined,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.only(
//                   left: 16.0, bottom: 0, top: 10.0, right: 16.0),
//               hintText: "Type or Enter ' / '",
//               hintStyle: TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
}

Future<void> onTapofTextfeild(_IndetailchatscreenState state) async {
  print('in on tap');
if(state.isswithed==false){
          bool canshow=await  state.sharedPrefsHelper.canShowTakeoverDiolouge();
                          print("candhoe$canshow");
                          if(canshow){
                               bool permofromoperation =    await   showTakeOverDialog(state.context,);
                              if( permofromoperation){
           var k= await  postOverrideStatus(state. widget.chatinfo?.customerNo.value, state.widget.isFromLeadsScreen??false);
                                  state.   setState(() {
                                        
                       
                                  print("icscjnsdcjnsdcj$k");
                                  if(k!=null && k==true){
                                     state.isswithed= true;
                                     print('swithvlue is ${state.isswithed}');
                                     NewChatDetailsController.istakeoverd.value=true;
                                       // _chatDetailsController.takeOver(widget.chatModel?.customerNo,widget.isFromLeadsScreen,);
                                    
                                       // switchController.setSwitchValue(widget.chatModel?.customerNo, true);
                                       // ChatDetailsController.overRideStatusTitle.value = "Release";
                                  }
                                      });
                              }else{
                              
state.focusNode.unfocus();
                                FocusScope.of(state. context).unfocus();
                              }

                          }   
                           else{

                              
                                  bool isoverrided = await postOverrideStatus(state. widget.chatinfo?.customerNo.value??'', state.widget.isFromLeadsScreen??false);
                                  state.setState(() {
                                    state.isswithed=isoverrided;
                                    NewChatDetailsController.istakeoverd.value=isoverrided;
                                  });
                                  
                                  // deleteOverrideStatus(     
                                  //  state.   widget.chatinfo?.customerNo.value??'',state.widget.isFromLeadsScreen);

                                  // Only execute this code if we're not navigating back from the TemplateSearch page
                              

                                    // Reset the value of the flag

                                  
                          }}
                          }