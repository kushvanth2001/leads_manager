import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/views/chat/Chatlistwidget.dart';
import 'package:leads_manager/views/chat/chatlistcontroller.dart';
import 'package:leads_manager/views/leads/taskDetails.dart';
import 'package:leads_manager/widgets/applicationswitchbutton.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  double isopaque=1;
  @override
  void initState() {
    super.initState();

//   chatListController.scrollController.addListener((){
// setState(() { isopaque=(chatListController. scrollController.offset <= 0) ? 1.0 : 0.5;});
// print(isopaque);
//   });
   // print("9----${chatListController.chatLists.value}");
  }
  ChatListController chatListController=Get.find<ChatListController>();
  @override
  Widget build(BuildContext context) {
    return Obx(()=>  Scaffold(
      appBar: ChatListController.issccrollingup.value?null:PreferredSize( preferredSize:  Size.fromHeight(kToolbarHeight),
        child: AppBar(backgroundColor: Colors.blue.shade400,actions: [Applicationswitchbutton()],
        title:CupertinoSearchTextField(
                        controller: ChatListController.searchController,
                        placeholder: "Search Chats by Name or Mobile Number",
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                     
                      ),
                         onChanged: (value){
                        if(value==''){
                      ChatListController.currentPage.value=0;
                  chatListController.loadData(forcedReload: true,);}
                  
                      },
                    
                      onSubmitted: (value) {
                        print(value);
                          ChatListController.currentPage.value=0;
                      chatListController.loadData(forcedReload: true,keywords: value??"");
                      },
                        style: TextStyle(fontSize: kMediumFontSize)),
        
        
        //  TextField(
        //             controller: ,
        //               decoration:InputDecoration( contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        //                   focusColor: Colors.purple,
        //                   hintText: 'Search Chats by Name or Number',
        //                   filled: true,
        //                   fillColor: Colors.white,
        //                   hintStyle: TextStyle(color: Colors.black45),
        //                   border: OutlineInputBorder(gapPadding: 10,
        //             // Adjust the value as needed
        //             borderRadius: BorderRadius.circular(16)
        //             ),),
        //               onChanged: (value){
        //                 if(value==''){
        //               ChatListController.currentPage.value=0;
        //           chatListController.loadData(forcedReload: true,);}
                  
        //               },
                    
        //               onSubmitted: (value) {
        //                 print(value);
        //                   ChatListController.currentPage.value=0;
        //               chatListController.loadData(forcedReload: true,keywords: value??"");
        //               },
                    
        //             ),
         
        ),
      ),
        body: Column(
          children: [
       
            Expanded(
              child: Obx(
                () =>!ChatListController.isloading.value?  RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 1),
            () {
              ChatListController().clearTimes();
              ChatListController().loadData(forcedReload: true);
            },
          );
        },
                  child: ListView.builder(
                    controller: chatListController.scrollController,
                    itemCount:ChatListController.chatLists.value.length,
                    itemBuilder: (context, index) {
                      return Chatlistwidget(chatListModel: ChatListController.chatLists.value[index]);
                    },
                  ),
                ):Center(child: CircularProgressIndicator(color: Colors.black,)),
              ),
            ),
          ],
        ),
        
         floatingActionButton: ChatListController.disableopquicty.value==0?FloatingActionButton(onPressed: (){

          chatListController.scrollController.jumpTo(0);
        ChatListController.disableopquicty.value=1;
          ChatListController.issccrollingup.value=false;
         },child: Icon(Icons.arrow_circle_up),):null,
      ),
    );
  }
}