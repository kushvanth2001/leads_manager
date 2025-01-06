import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'communitcationlist.dart';
import 'promotions.dart';
import '../widgets/customcoloumnwidgets.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';




class MarketingScreen extends StatefulWidget {
  const MarketingScreen({Key? key}) : super(key: key);

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
    static const MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: Text("Marketing")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          crossAxisCount: 2, // You can adjust the number of columns as needed
          children: [
            _buildGridItem(context, " Communication \n List",CommunicationListsScreen(),Colors.cyan.withOpacity(0.3),Icon(Icons.contacts)),
             _buildGridItem(context, "Promotions",PromotionsScreen(),Colors.green.withOpacity(0.3),Icon(Icons.phone_in_talk_rounded)),
            //_buildGridItem(context, "Campaigns",MarketingScreen(),Colors.yellow.withOpacity(0.3),Icon(Icons.mail)),
            //_buildGridItem(context, "My Number ",MarketingScreen(),Colors.orange.withOpacity(0.3),Icon(Icons.phone)),
            //_buildGridItem(context, "Short Links ",MarketingScreen(),Colors.red.withOpacity(0.3),Icon(Icons.dataset_linked_outlined )),
       
      ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String text,Widget page,Color color,Icon icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to the next page when tapped
      Get.to(page);
      },
      child: Card(
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
            ),
        elevation: 4,
        child: Container(
           decoration: BoxDecoration(color: color,borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child:icon,),
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final String text;
  final Color color;

  const NextPage({Key? key, required this.text, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Next Page")),
      body: Container(
        color: color,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
    // return   Container(
    //   width: 50,
    //   height: 20,
    //   child: Column(
    //     children: [
    //       Container(
    //         decoration: BoxDecoration(border: Border.all(color: Colors.grey,width: 2),   borderRadius: BorderRadius.all( Radius.circular(20))),
    //         height:700,
    //         width: MediaQuery.of(context).size.width,
           
    //          child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //            children: [
      
    //             Container(
    //               decoration: BoxDecoration(
    //                  color:Colors.green,
    //                 borderRadius: BorderRadius.only(topRight: Radius.circular(19),topLeft: Radius.circular(19))),
                 
    //                  height:MediaQuery.of(context).size.height*0.08,
    //         width: MediaQuery.of(context).size.width,child: Row(
      
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //   Align(
    //       alignment: Alignment.centerLeft,
    //       child:   Row(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
          
    //             Icon(Icons.arrow_back,color: Colors.white),
          
    //           CircleAvatar(backgroundColor: Colors.white,radius: 15,),
          
    //       ],
          
    //       ),
    //   ),
           
    //        Padding(
    //          padding: const EdgeInsets.all(8.0),
    //          child: Row(
    //           mainAxisAlignment: MainAxisAlignment.end,
    //           children: [
    //             SizedBox(width: 30,),
    //           Icon(Icons.phone,color: Colors.white),
    //           SizedBox(width:10),
    //           Icon(Icons.video_call,color: Colors.white)
    //          ],),
    //        )
           
    //           ],
    //         ),),
    //              Expanded(
    //                child: Container(
                        
    //                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/whatsappbg.png"),fit: BoxFit.cover)),
                     
                     
                     
    //                  child: ListView.builder(
    //                    itemCount: docs.length,
    //                    itemBuilder: (contex,index){
    //                return _buildDocumentChatBubble(docs[index]);
                   
                    
                   
                   
    //                  }),
    //                ),
    //              ),
             
             
    //          Align(
    //           alignment: Alignment.bottomRight,
    //            child: Container(
    //             padding: EdgeInsets.all(8),
    //             height:60 ,
    //             decoration: BoxDecoration( image: DecorationImage(image: AssetImage("assets/images/whatsappbg.png"),fit: BoxFit.cover),  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))),
    //             child: Row(children: [
    //          Container(
              
    //            width: MediaQuery.of(context).size.width*0.7,
    //            child:   TextFormField(
               
               
               
    //              decoration: InputDecoration(
               
    //                prefixIcon: Icon(Icons.emoji_emotions),
               
    //                suffixIcon: Icon(Icons.camera),
               
    //                hintText: "Message",
               
    //                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular( 20)))),),
    //          )
    //         , SizedBox(width: 7)
    //          ,
    //          Container(
    //            height: 40,
    //       width: 40,
    //           decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.green,),child: Icon(Icons.mic,color: Colors.white,),),   ],),),
    //          )
    //            ],
    //          ),
    //        ),
    //     ],
    //   ),
    // );