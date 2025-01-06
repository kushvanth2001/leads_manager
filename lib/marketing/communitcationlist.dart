import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import 'addcommucationlist.dart';
import 'addpromotions.dart';
import '../models/model_customer.dart';
import '../utils/snapPeUI.dart';
import '../../../domainvariables.dart';
import '../models/model_customerroles.dart';

class CommunicationListsScreen extends StatefulWidget {
  const CommunicationListsScreen({Key? key}) : super(key: key);

  @override
  State<CommunicationListsScreen> createState() =>
      _CommunicationListsScreenState();
}

class _CommunicationListsScreenState extends State<CommunicationListsScreen>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  List<CustomerList> trueCustomerLists = [];
  double _previousScrollPosition = 0.0;
  int maxpage = 50000;
  List<CustomerList> totalCustomerLists = [];
  bool isapicall = false;
  int currentsortlent = 1;
  String searchvlaue = "";
  late TabController _tabController;
int tabindex=1;
int previoustabindex=0;
TextEditingController _nameController=TextEditingController();
TextEditingController _descriptionController=TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCustomerLists(true);
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
     
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

          await fetchCustomerLists(false);

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
          actions: [ElevatedButton(onPressed: (){
 showDialog(
  barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          
          title:  Column(children: [
Text("Add Communication List",style: TextStyle(fontSize: 18),),
Divider(color: Colors.black,)

    ],),
          content: AddCommunicationList( typeisdynamic:tabindex==0 || tabindex==2?false:true,typeislead: tabindex==0 || tabindex==1?true:false,));
      });

          }, child: Row(
            children: [
              
              Icon(Icons.add),
              Text('Create'),
              SizedBox(width: 1,)
            ],
          ))],
          bottom: TabBar(
    
            onTap: (value)async{
              setState(() {
         

                tabindex=value;
                currentPage=0;
                    
              });
            
await fetchCustomerLists(true);
              
            },
            isScrollable: true,
            controller: _tabController,
            tabs: [
                   Tab(text: "Static Leads"),
              Tab(text: "Dynamic Leads"),
          Tab(text: "Static Customer"),
                   Tab(text: "Dynamic Customer"),
             
          Tab(text: "Roles"),
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
           buildListView(),
  
            
          ],
        ),
      ),
    );
  }

  buildTabBody(String tabTitle) {
   

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: "Search ",
                decoration: SnapPeUI().searchBoxDecoration(),
                onChanged: (value) async {
                  setState(() {
                    searchvlaue = value;
                    currentPage=0;
                  });
                  print("value" + value);
               fetchCustomerLists(true);
                },
              ),
            ),
          ),

          
          Expanded(
            child: totalCustomerLists.isEmpty && isapicall
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
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: totalCustomerLists.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 1, left: 4, right: 4, top: 3),
                        child: Slidable(
                          startActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async{
                              if(tabindex==0 || tabindex==2)
                                {
                                 _nameController.text = totalCustomerLists[index].name;
                                 _descriptionController.text=totalCustomerLists[index].description??"";
showDialog(context: context, builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Update Customer List'),
      content: SingleChildScrollView(
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.black,),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child:   Text("Name *",style: TextStyle(fontSize: 19),),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width*0.6,
        height: 50,
        child: TextFormField(
  
          controller: _nameController,
      decoration: InputDecoration(hintText: "Name",border: OutlineInputBorder()),
      
        )),
      
        SizedBox(height: 20,),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child:   Text("Description:",style: TextStyle(fontSize: 19),),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width*0.6,
        height: 120,
        child: TextFormField(
              controller: _descriptionController,
          expands: true,
          minLines: null,
          maxLines: null,
      decoration: InputDecoration(hintText: "Description",border: OutlineInputBorder()),
       textAlignVertical: TextAlignVertical.top
        ))
        ],),
      ),
      actions: [
        TextButton(
          onPressed: () {
          
            Navigator.of(context).pop(); 
          },
          child: Text('Cancel'),
        ),  TextButton(
          onPressed: ()async {

if(_nameController.text==""){
Fluttertoast.showToast(msg: "Enter a valid name");
}else{
 Navigator.of(context).pop();
  await CustomerList.editCommunicationList({"id": totalCustomerLists[index].id, "name": _nameController.text, "description": _descriptionController.text, "type": "list", "isDynamic": false},totalCustomerLists[index].id, false);
 
 await fetchCustomerLists(true);

}

          
            
          },
          child: Text('Update'),
        ),
      ],
    );
  },);

                                }
      
                              else{

showDialog(context: context, builder: (BuildContext context) {
    return AlertDialog(
     content:AddCommunicationList(typeisdynamic: true,typeislead:totalCustomerLists[index].type=="lead"?true:false,fromedit:totalCustomerLists[index] ,) ,
    );
  },);


;

                                }
                                },
                                backgroundColor: Color.fromARGB(255, 52, 41, 139),
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                            ],
                          ), 
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async{
                                await deleteCustomerList(totalCustomerLists[index].id);
                                
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 8,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  totalCustomerLists[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              trailing: InkWell(
                                onTap: (){
                                      Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPromotions(fromcustomerlist: totalCustomerLists[index],)),
            );

                                },
                                child: CircleAvatar(backgroundColor: Colors.blue,radius: 14,child: Icon(Icons.send_sharp,size: 15,),)),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Type: ${totalCustomerLists[index].type}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
 Widget buildListView() {
    return FutureBuilder<List<CustomerRole>>(
      future:  CustomerRole.fetchCustomerRoles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(4),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    title:Text(
                                  snapshot.data![index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    
                    
                    subtitle: Text(
                        'Type:  Role'),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> deleteCustomerList(int customerId) async {
      String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
  try {
    // Replace the URL with the actual delete endpoint for customer lists
    final response = await NetworkHelper().request(
      RequestType.delete,
      Uri.parse( tabindex==0 || tabindex==2?"https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists/$customerId":'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports/$customerId'), // Replace with the correct delete URL
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
    
      print('Customer list deleted successfully');
      
     
      await fetchCustomerLists(true);
    } else {
      print('Failed to delete customer list');

      throw Exception('Failed to delete customer list');
    }
  } catch (e) {
    print('Exception occurred during delete: $e');
  
    throw e;
  }
}


  Future<void> fetchCustomerLists(bool istabchange) async {
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
print( 'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists?type=${tabindex==0 || tabindex==1?"lead":"customer"}&page=$currentPage&size=20${searchvlaue==""?"":"&name=$searchvlaue"}&sortBy=createdOn&sortOrder=DESC');
        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> customerLists =   tabindex==0 || tabindex==2?   parsed['customerLists']:parsed["reports"];

          final List<CustomerList> lists = customerLists
              .map((json) => CustomerList.fromJson(json))
              .toList();

          setState(() {
            if(!istabchange){
                   totalCustomerLists.addAll( lists);
            }else{
              totalCustomerLists=lists;
            }
     
            isapicall = true;
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

class CustomerList {
  final int id;
  final String name;
  final String? description;
  final String type;

  CustomerList({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });

  factory CustomerList.fromJson(Map<String, dynamic> json) {
    return CustomerList(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      type: json['type'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
    };
}


  static Future<CustomerList> postCommunicationList(CustomerList customer,bool isdynamic) async {
       String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";

    Uri uri = Uri.parse(
       isdynamic? "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports":
"https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists");

    try {
      final response = await NetworkHelper().request(
      RequestType.post,
        uri,
       
        requestBody: jsonEncode(customer.toJson()),
      );

      if ( response!=null&&response.statusCode == 200) {
      var  res=jsonDecode(response.body);
      Fluttertoast.showToast(msg: 'Successfully Add Communication List');
      return CustomerList.fromJson(res);
      } else {
        // If the server did not return a 201 CREATED response,
        // throw an exception.
        //return CustomerList(id: 0, name: "", type: "");
        throw Exception('Failed to post data');
        
      }
    } catch (error) {
      // Handle any error that occurred during the HTTP request.
      print('Error: $error');
      throw Exception('Failed to post data');
    }
  }


static Future<CustomerList> editCommunicationList(Map<String,dynamic> body,int id, bool isDynamic) async {
  try {
    String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";

    Uri uri = Uri.parse(
      isDynamic
          ? "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports/$id"
          : "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists/$id",
    );

    final response = await NetworkHelper().request(
      RequestType.put, // Assuming you are using HTTP PUT for editing
      uri,
      requestBody: jsonEncode(body),
    );

    if (response != null && response.statusCode == 200) {
      var res = jsonDecode(response.body);
      Fluttertoast.showToast(msg: 'Successfully Edited Communication List');
      return CustomerList.fromJson(res);
    } else {
      throw Exception('Failed to edit data');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to edit data');
  }
}
static Future<List<CustomerList>> fetchAllCommunicationLists() async {
  List<CustomerList> allcustomerlist=[];
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response1 = await NetworkHelper().request(
        RequestType.get,
              Uri.parse(
       'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customer-lists'
        ),
        requestBody: "",
      );

      if (response1 != null && response1.statusCode == 200) {
        final parsed = json.decode(response1.body);
        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> customerLists =     parsed['customerLists'];

          final List<CustomerList> lists = customerLists
              .map((json) => CustomerList.fromJson(json))
              .toList();
allcustomerlist.addAll(lists);
          
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load customer lists');
        throw Exception('Failed to load customer lists');
      }



  final response2 = await NetworkHelper().request(
        RequestType.get,
              Uri.parse(
       
'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports'
        ),
        requestBody: "",
      );

      if (response2 != null && response2.statusCode == 200) {
        final parsed = json.decode(response2.body);
        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> customerLists =    parsed["reports"];

          final List<CustomerList> lists = customerLists
              .map((json) => CustomerList.fromJson(json))
              .toList();
allcustomerlist.addAll(lists);
          
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
  return allcustomerlist;
  }
}



