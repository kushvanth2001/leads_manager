import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import '../../../domainvariables.dart';
import 'communitcationlist.dart';

class CommunicationListDropdown extends StatefulWidget {
   final Function(String,int) onItemSelected;
    final String initialSelectedValue;
    final Function(List<CustomerList>) allComList;
  const CommunicationListDropdown({Key? key, required this.onItemSelected, required this.initialSelectedValue, required this.allComList}) : super(key: key);

  @override
  State<CommunicationListDropdown> createState() =>
      _CommunicationListDropdownState();
}

class _CommunicationListDropdownState extends State<CommunicationListDropdown>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  List<CustomerList> trueCustomerLists = [];
  double _previousScrollPosition = 0.0;
  int maxpage = 5000;
  List<CustomerList> totalCustomerLists = [];
  bool isapicall = false;
  int currentsortlent = 1;
  String searchvlaue = "";
  late TabController _tabController;
    String selectedValue = "";
int tabindex=0;
  @override
  void initState() {
    super.initState();
    fetchCustomerLists();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 4, vsync: this);
  
    setState(() {
      
      if(widget.initialSelectedValue!=""){
      selectedValue=widget.initialSelectedValue;
      
      }
    });
     
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollListener() async {
    double currentScrollPosition = _scrollController.position.pixels;

    if (currentScrollPosition > _previousScrollPosition) {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("start of the screen");

        if (currentPage < maxpage) {
          setState(() {
            currentPage++;
          });

          await fetchCustomerLists();

          setState(() {});
        }
      }
    }

    _previousScrollPosition = currentScrollPosition;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Communication List"),
          bottom: TabBar(
            
            onTap: (value)async{
              setState(() {
                // totalCustomerLists=[];
                // trueCustomerLists=[];
                tabindex=value;
              });
            
await fetchCustomerLists();
              
            },
            isScrollable: true,
            controller: _tabController,
            tabs: [
                   Tab(text: "Static Leads"),
              Tab(text: "Dynamic Leads"),
          Tab(text: "Static Customer"),
                   Tab(text: "Dynamic Customer"),
             
         
            ],
          ),
        ),
        body: TabBarView(
           physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
              buildTabBody("Static Leads"),
             buildTabBody("Dynamic Leads"),
                    buildTabBody("Static Customer"),
           buildTabBody("Dynamic Customer"),
  
            
          ],
        ),
      ),
    );
  }

  buildTabBody(String tabTitle) {
   

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: CupertinoSearchTextField(
                placeholder: "Search Customer List",
                decoration: SnapPeUI().searchBoxDecoration(),
                onChanged: (value) async {
                  setState(() {
                    searchvlaue = value;
                  });
                  print("value" + value);
                  if (value == "") {
                    setState(() {
                      isapicall = false;
                      currentPage = 0;
                      totalCustomerLists = [];
                    });
                    await fetchCustomerLists();
                  } else {
                    setState(() {
                      List<CustomerList> filteredCustomerLists = trueCustomerLists
                          .where((customer) =>
                              customer.name.toLowerCase().startsWith(value.toLowerCase()))
                          .toList();
                      totalCustomerLists = filteredCustomerLists;
                      print(totalCustomerLists.length.toString() + isapicall.toString());
                      isapicall = true;
                    });
                  }
                },
              ),
            ),
            totalCustomerLists.length <= 0 && isapicall
                ? Center(
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
                  )
                : Container(
                  height: MediaQuery.of(context).size.height*0.7,
        
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: totalCustomerLists.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 1, left: 4, right: 4, top: 3),
                          child: Card(
                            elevation: 8,
                            child: RadioListTile(
                                      title: Text(
                                        totalCustomerLists[index].name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Type: ${totalCustomerLists[index].type}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: totalCustomerLists[index].name,
                                      groupValue: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue =
                                              value.toString(); // Update the selected value
                                        });
                                        widget.onItemSelected(
                                            value.toString(),totalCustomerLists[index].id); // Notify the callback
                                      },
                                    ),
                          ),
                              
                        );
                      },
                    ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchCustomerLists() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
              Uri.parse(
           tabindex==0 || tabindex==2? 'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists?type=${tabindex==0 || tabindex==1?"lead":"customer"}&page=$currentPage&size=20${searchvlaue==""?"":"&name=$searchvlaue"}&sortBy=createdOn&sortOrder=DESC': 
'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports/search-type?type=${tabindex==0 || tabindex==1?"lead":"customer"}&page=$currentPage&size=20${searchvlaue==""?"":"&name=$searchvlaue"}&sortBy=createdOn&sortOrder=DESC'
        ),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> customerLists =   tabindex==0 || tabindex==2?   parsed['customerLists']:parsed["reports"];
print(customerLists);
          final List<CustomerList> lists = customerLists
              .map((json) => CustomerList.fromJson(json))
              .toList();

          setState(() {
           totalCustomerLists=tabindex==0 || tabindex==1?  lists.where((element) => element.type == "lead").toList():lists.where((element) => element.type == "customer").toList();
            trueCustomerLists = totalCustomerLists;
            isapicall = true;
            widget.allComList(totalCustomerLists);
          });
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load customer lists');
        throw Exception('Failed to load customer lists');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
}


