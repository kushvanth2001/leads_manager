import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import 'addpromotions.dart';
import '../models/model_application.dart';
import '../utils/snapPeUI.dart';
import '../../../domainvariables.dart';
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  
  double _previousScrollPosition = 0.0;
  int maxpage = 5000;
  List<Promotion> totalpromotions=[];
String searchvlaue="";
bool isapicall=false;

  @override
  void initState() {
    super.initState();
     // Fetch initial data
      merchantPromotions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    setState(() {
      totalpromotions=[];
    });
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() async {
  double currentScrollPosition = _scrollController.position.pixels;

  if (currentScrollPosition > _previousScrollPosition) {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && searchvlaue=="") {
      print("start of the screen");
      
        setState(() {
          currentPage++;
      
        });
        
      await   merchantPromotions();
     
    }
  }

  _previousScrollPosition = currentScrollPosition;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Promotions"),actions:[ InkWell(
        onTap: (){
        Get.to(AddPromotions());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [Text("AddPromotions"),Icon(Icons.add)],),
      )]),
      body: buildBody(),
    );
  }

  buildBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            placeholder: "Search Promotion by Name",
            decoration: SnapPeUI().searchBoxDecoration(),
            onChanged: (value) async{
              setState(() {
                 searchvlaue=value;
              });
              print("value"+value);
              if(value==""){
                setState(() {
                 isapicall=false;
                  currentPage=0;
                  totalpromotions=[];
                });
           
              await  merchantPromotions();
              }
              else{
        await merchantPromotionsbysearch(value);
              }
            },
          ),
        ),
        Expanded(
          child:totalpromotions.length<=0 && isapicall ?Center(
                child: RefreshIndicator(
                  onRefresh:()async{ 
                    setState(() {
                      totalpromotions=[];
                        currentPage=0;
                    });
                  
                   await  merchantPromotions();},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("No Data found"),
                      SvgPicture.asset(
                        'assets/images/noData.svg',
                        semanticsLabel: 'No Data',
                        height: 250,
                      ),
                    ],
                  ),
                ),
             
  ):  RefreshIndicator(
                  onRefresh:()async{ 
                    setState(() {
                      totalpromotions=[];
                        currentPage=0;
                    });
                  
                   await  merchantPromotions();},
    child: Container(
      color: Colors.black12,
      child: ListView.builder(
                      controller: _scrollController,
                      itemCount: totalpromotions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 2,right: 4,left:4 ),
                          child:  Slidable(
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async{
                              await deletePromotion(index);
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
  startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              
                          Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddPromotions(id: totalpromotions[index].id),
    ),
  );
                            },
                            backgroundColor: Color.fromARGB(255, 52, 41, 139),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                        ],
                      ),

                     child:  Card(
                          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
              ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                            Row(
                              
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Tooltip(
                                 triggerMode: TooltipTriggerMode.tap,
                                message: totalpromotions[index].name,child: SizedBox(width: MediaQuery.of(context).size.width*0.5,child: Text(totalpromotions[index].name,overflow: TextOverflow.ellipsis,))),Row(
                                children: [
                              //     totalpromotions[index].status=="OK"?Icon(Icons.circle,color: Colors.green,):Icon(Icons.circle,color: Colors.red,size: 15,),
                              //  totalpromotions[index].status=="OK"?Text("Active"):Text("In active"),
                                ],
                              )],),
                            Divider(color: Colors.black,),
                            ListTile(leading:  Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [ Image.asset(
                      "assets/icon/whatsappIcon.png",
                      width: 20,
                    ), Text("WhatsApp"),]),
                                            Row(mainAxisSize: MainAxisSize.min,
                                              
                                              children: [Icon(Icons.check,color: Colors.blue,), Text(totalpromotions[index].status),]),   ],
                            ),trailing:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [Icon(Icons.calendar_today_outlined,color: Colors.red,),Text(

                                                                  DateFormat('M/d/yy, h:mm a').format (DateTime.parse(totalpromotions[index].createdOn).subtract(Duration(hours: 1)).toUtc()).toString().endsWith('AM')?DateFormat('M/d/yy, h:mm a').format (DateTime.parse(totalpromotions[index].createdOn).subtract(Duration(hours: 1)).toUtc()).toString().replaceAll('AM', 'PM'):DateFormat('M/d/yy, h:mm a').format (DateTime.parse(totalpromotions[index].createdOn).subtract(Duration(hours: 1)).toUtc()).toString().replaceAll('PM', 'AM')        )]),
                              Row(mainAxisSize: MainAxisSize.min,
                                
                                children: [Icon(Icons.person,color: Colors.blue,),Text(totalpromotions[index].createrName)],) ],
                            ),
                              
                              ),
                          
                    
                              ],),
                            )
                          ))
                        );
                      },
                    ),
    ),
  )
        ),
      ],
    );
  }
Future<void> merchantPromotions() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions?page=$currentPage&size=20&sortBy=createdOn&sortOrder=DESC',
      ),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      final parsed = json.decode(response.body);

      if (parsed != null && parsed is Map<String, dynamic>) {
        setState(() {
          maxpage = parsed['pages'];
          print(maxpage);
        });

        final List<dynamic> promotionsList = parsed['promotions'];
        final List<Promotion> promotions =
            promotionsList.map((json) => Promotion.fromJson(json)).toList();
        setState(() {
          totalpromotions.addAll(promotions);
          isapicall=true;
        });
      } else {
        print('Invalid response format');
        throw Exception('Invalid response format');
      }
    } else {
      print('Failed to load merchant promotions');
      throw Exception('Failed to load merchant promotions');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

Future<void> merchantPromotionsbysearch(String name) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions?page=$currentPage&size=20&sortBy=createdOn&sortOrder=DESC&name=$name',
      ),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      final parsed = json.decode(response.body);

      if (parsed != null && parsed is Map<String, dynamic>) {
        setState(() {
          maxpage = parsed['pages'];
          print(maxpage);
        });

        final List<dynamic> promotionsList = parsed['promotions'];
        final List<Promotion> promotions =
            promotionsList.map((json) => Promotion.fromJson(json)).toList();
        setState(() {
          totalpromotions=promotions;
        });
      } else {
        print('Invalid response format');
        throw Exception('Invalid response format');
      }
    } else {
      print('Failed to load merchant promotions');
      throw Exception('Failed to load merchant promotions');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

Future<void> deletePromotion(int index,) async {
   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      // Get promotion ID or any other identifier based on your API
      int promotionId = totalpromotions[index].id!;

      // Send a delete request to your API
      final response = await NetworkHelper().request(
        RequestType.delete,
        Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions/$promotionId',
        ),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
      
        setState(() {
          totalpromotions.removeAt(index);
        });
      } else {
        print('Failed to delete promotion');
  
      }
    } catch (e) {
      print('Exception occurred during deletion: $e');
    
    }
  }

}





class PromotionsList {
  final String name;

  PromotionsList({required this.name});

  factory PromotionsList.fromJson(Map<String, dynamic> json) {
    return PromotionsList(
      name: json['name'],
    );
  }
}

class Promotion {
  final int? pages;
  final String name;
  final String status;
  final String createdOn;
  final PromotionsList promotionsList;
  final int? id;
  final String createrName;

  Promotion(  {required this.id,
    required this.pages,
    required this.name,
    required this.status,
    required this.createdOn,
    required this.promotionsList,
    required this.createrName,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id:json["id"]??0,
      pages: json['pages'] ?? 0,
      name: json['name'] ?? "",
      status: json['status'] ?? "",
      createdOn: json['createdOn'] ?? "",
       createrName: json[ "createrName"] ?? "",
      promotionsList: PromotionsList.fromJson(json['promotionsList']??{"name":"nodata"}),
    );
  }
}
