import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:intl/intl.dart';

import '../constants/styleConstants.dart';
import '../domainvariables.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../utils/snapPeUI.dart';

class CallLogScreen extends StatefulWidget {
  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<dynamic> calllogs = [];
  ScrollController scrollController = ScrollController();
  TextEditingController textcontroller=TextEditingController();
  int currentPage = 0;
  int pages = 0;
  int totalRecords = 0;
  Future<void> fetchcallogs(int page, int size,String? phonenumber, {bool reload = false}) async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
String qureyparameters="";
if(phonenumber!=null && phonenumber!=""){
  qureyparameters="&leadMobNo=$phonenumber";
}


      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/call/logs?page=$page&size=$size&sortBy=createdOn&sortOrder=DESC$qureyparameters'),
        requestBody: "",
      );

      print('Response for customer roles: ${response?.body}');

      if (response != null && response.statusCode == 200) {
        dynamic parsed = json.decode(response.body);
        setState(() {
          totalRecords = parsed["totalRecords"];
          pages = parsed["pages"];
        });
        parsed = parsed["callLogs"];
        print("parsed,$parsed,");
        if (parsed != null && parsed is List<dynamic>) {
          if (reload ) {
            setState(() {
              calllogs = parsed;
            });
          } else {
            setState(() {
              calllogs.addAll(parsed);
            });
          }
        } else {
          print('Invalid response format for calllogs');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load callogs');
        throw Exception('Failed to load calllogs');
      }
    } catch (e) {
      print('Exception occurred while fetching cllogs: $e');
      throw e;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdata();
  }

  setdata() async {
    await fetchcallogs(0, 20,null, reload: true,);

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent - scrollController.offset ==
          0) {
        // fetchCallStatus();
        // print("end currentPage - $currentPage Pages - $pages currentRecords -${leadModel.value.leads!.length}  TotalRecords - $totalRecords");
        if (currentPage != pages && calllogs.length != totalRecords) {
          setState(() {
            currentPage++;
          });

          await fetchcallogs(currentPage, 20,null);
        } else {
          SnapPeUI().toastWarning(message: "No More Record.");
        }
      }
    });
  }
  final Debouncer _debouncer = Debouncer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CallLogs"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            ExpansionTile(
              trailing: Icon(
                Icons.expand_more,
                size: 20,
                color: Colors.white,
              ),
              title: CupertinoSearchTextField(
                controller: textcontroller,
                placeholder: "Search Log by Mobile Number",
                decoration: SnapPeUI().searchBoxDecoration(),
                style: TextStyle(fontSize: kMediumFontSize),
                //onSubmitted: _onSearchChanged,

                onChanged: (value) async{
                    _debouncer.debounce(
    duration: Duration(milliseconds: 800),
    onDebounce: () async{
                  currentPage=0;
                  pages=0;
                  totalRecords=0;
calllogs=[];
                   await fetchcallogs(currentPage, 20,value ,);
                });}
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [     Text("Total records:$totalRecords  ",style: TextStyle(color: Colors.white),),Text("Total pages:$pages",style: TextStyle(color: Colors.white),)],)
           
            
              
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RefreshIndicator(
                           onRefresh: ()async{
currentPage=0;
totalRecords=0;

                pages=0;
                textcontroller.clear();
                 await fetchcallogs(0, 20,null, reload: true,);

              },
                  child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: calllogs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${calllogs[index]["lead"]["mobileNumber"]}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              minWidth: 0),
                                          child: Text(
                                            "${calllogs[index]["lead"]["customerName"] ?? " "}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                         
                                            Text(
                                              "${calllogs[index]["callType"]}  ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: calllogs[index]
                                                            ["callType"] ==
                                                        "Outgoing"
                                                    ? Colors.blue
                                                    : Colors.green,
                                              ),
                                            ),
                                            calllogs[index]["callType"] ==
                                                    "Outgoing"
                                                ? Image.asset(
                                                    "assets/images/outgoing-call.png",
                                                    width: 15,
                                                    height: 15,
                                                  )
                                                : Image.asset(
                                                    "assets/images/incoming-call (1).png",
                                                    width: 15,
                                                    height: 15,
                                                  )
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Agent: ${calllogs[index]["agentPhoneNumber"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${calllogs[index]["agentName"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Duration: ${calllogs[index]["callDuration"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:calllogs[index]["callDuration"] ==
                                                    "00:00:00"
                                                ? Colors.red.shade200:Colors.green.shade200
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2), // Add spacing between rows
                
                                Center(
                                  child: Text(
                                    "${DateFormat('dd-MM-yyyy').format(DateTime.parse(calllogs[index]["startTime"]))}(${DateFormat('EEEE').format(DateTime.parse(calllogs[index]["startTime"]))})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
