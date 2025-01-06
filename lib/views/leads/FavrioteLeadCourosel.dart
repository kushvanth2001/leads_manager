import 'dart:convert';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class FavoriteLeadCarousel extends StatefulWidget {
  @override
  _FavoriteLeadCarouselState createState() => _FavoriteLeadCarouselState();
}

class _FavoriteLeadCarouselState extends State<FavoriteLeadCarousel> {
  List<Lead> leads = [];

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(msg: "Feature under development!");
    _fetchLeads();
  }

  LeadController leadcontroller=Get.find<LeadController>();

Future<void> _fetchLeads() async {
  String? k = await SharedPrefsHelper().getFavoriteLeads();
  print("kvalue$k");
List<dynamic> leadIds =[];
  if(k!=null){
leadIds = jsonDecode(k).map((e){
return e.toString();
}).toList();


  }
  

  // Create a list of futures for fetching leads
  List<Future<Lead>> leadFutures = leadIds.map((id) {
    // Ensure the method returns Future<Lead>
    return getLead(id) ;
  }).toList();

  try {
    // Await all futures and gather results
    List<Lead> fetchedLeads = await Future.wait(leadFutures);

    // Update the state with the fetched leads
    setState(() {
      leads = fetchedLeads;
      print("leads$leads");
    });
  } catch (e) {
    // Handle any errors that occurred during fetching
    print('Error fetching leads: $e');
    // You might want to update the state or show an error message here
  }
}
removeFavoriteLead(String leadid)async{
  
    String? k = await SharedPrefsHelper().getFavoriteLeads();
  print("kvalue$k");
  print("leadid$leadid");
List<dynamic> Ids =[];
  if(k!=null){
Ids = jsonDecode(k).map((e){
return e.toString();
}).toList();

Ids.contains(leadid)?Ids.remove(leadid):null;
 await SharedPrefsHelper().setFavoriteLeads(jsonEncode( Ids));
_fetchLeads();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Favorites"),
      ),
      backgroundColor: Colors.transparent,
      body:   BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          
        child: Stack(
          children: [
        
            Center(
              child:leads.isNotEmpty? CarouselSlider(
                items: leads.map((lead) {
                  return  Dismissible(
                          key: Key(lead.id.toString()), // Assuming 'lead' has a unique ID
                          direction: DismissDirection.endToStart, // Swipe to the right
                          onDismissed: (direction) {
                            setState(() {
                              leads.remove(lead);
                              // Optionally, you can remove it from shared preferences here
                              removeFavoriteLead(lead.id.toString());
                            });
                            Fluttertoast.showToast(msg: "Lead removed from favorites");
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                    child: LeadWidget(
                      onBack: () {},
                      reducewidth: true,
                      index: leads.indexOf(lead),
                      leadController: leadcontroller,
                      liveAgentUserName: SharedPrefsHelper().getMerchantName(),
                      lead: lead,
                      isNewleadd: false,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 700,
                  aspectRatio: 16 / 9,
               viewportFraction: 0.4, // Shows part of the previous and next cards
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOut,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.vertical,
                  
                )
           )  :Text("Drag a Lead to the bottom in the lead screen to add it into favorites") 
            ),
        
            //   VerticalCardPager(
            // titles:leads.map((lead) => "").toList(),
            //   images: leads.map((lead) {
            //       return Container(
            //         height: 300,
            //         margin: EdgeInsets.all(value),
            //         child: LeadWidget(
            //           onBack: () {},
            //           reducewidth: true,
            //           index: leads.indexOf(lead),
            //           leadController: leadcontroller,
            //           liveAgentUserName: SharedPrefsHelper().getMerchantName(),
            //           lead: lead,
            //           isNewleadd: false,
            //         ),
            //       );
            //     }).toList(),
            //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //   onPageChanged: (page) {},
            //   onSelectedItem: (index) {},
            // ),
            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: Icon(Icons.close,color: Colors.red,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),

              Positioned(
              left: 16,
              top: 16,
              child: ElevatedButton(
                child: Text("Clear Favorite",),
                onPressed: () {
                SharedPrefsHelper().removeFavoriteLeads();
                 Navigator.of(context).pop();
                },
              ),
            ),
      Positioned(
  bottom: 0,
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child:  Container(
          width: MediaQuery.of(context).size.width*0.9,
          child: Wrap(
            children: [
             
            ],
          ),
        ),
      ),
    ],
  ),
)

          ],
        ),
      ),
    );
  }
}
Future<Lead> getLead(String id)async{
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$id'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    return Lead.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to get the Lead');
  }
}