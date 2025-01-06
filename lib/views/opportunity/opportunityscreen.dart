import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:leads_manager/views/opportunity/addopportunity.dart';
import 'package:leads_manager/views/opportunity/opportunitycard.dart';

class OpportunityListScreen extends StatefulWidget {
  @override
  _OpportunityListScreenState createState() => _OpportunityListScreenState();
}

class _OpportunityListScreenState extends State<OpportunityListScreen> {
  ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _opportunities = [];
  int _currentPage = 0;
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchOpportunities() async {
    setState(() {
      _isFetchingData = true;
    });

    List<Map<String, dynamic>> newOpportunities = await SnapPeNetworks().fetchOpportunity (currentPage: _currentPage);
    setState(() {
      _opportunities.addAll(newOpportunities);
      _isFetchingData = false;
      _currentPage++;
    });
  }

  void _scrollListener() {
    double threshold = _scrollController.position.maxScrollExtent * 0.75;

    if (_scrollController.position.pixels >= threshold && !_isFetchingData) {
      _fetchOpportunities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opportunities'),
        actions: [IconButton(onPressed: ()async{

Map<String,dynamic>? lead= await selectLeadDialog(context);

if(lead!=null){


Get.to(()=> AddOpportunityScreen(editedData: {
  'leadid':lead['leadid'],
  "mobileNumber":lead['mobileNumber'],
  "customerName":lead['customerName']
  
},));
}else{
  Fluttertoast.showToast(msg: "Lead Not Selected");
}
        }, icon: Icon(Icons.add))],
      ),
      body: RefreshIndicator(
                  onRefresh:()async{ 
                    _opportunities=[];
_currentPage=0;
_fetchOpportunities();
                 },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _opportunities.length,
          itemBuilder: (context, index) {
            return OpportunityCard(opportunity: _opportunities[index]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


Future<Map<String, dynamic>?> selectLeadDialog(BuildContext context) {
  final searchController = TextEditingController();

  return showCupertinoModalPopup<Map<String, dynamic>>(
    barrierColor: kPrimaryColor.withOpacity(0.3),
    barrierDismissible: true,
    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        title: Text(
          "Select Lead",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5),
                TypeAheadField(
                  noItemsFoundBuilder: (context) {
                    return Text("No Lead Found.");
                  },
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search Lead",
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    var k=await SnapPeNetworks().leadSugestionsCallback(pattern);
                    return k ;
                  },
                  itemBuilder: (context, Map<String, dynamic> lead) {
                    return ListTile(
                      title: Text("${lead["customerName"]}"),
                      subtitle: Text("${lead["mobileNumber"]}"),
                    );
                  },
                  onSuggestionSelected: (dynamic lead) {
                    Navigator.pop(context, lead);
                  },
                ),
                SizedBox(height: 30),
                Text(
                  "- - or - -",
                  style: TextStyle(color: kLightTextColor),
                ),
                MaterialButton(
                  child: Text(
                    "Create new Lead",
                    style: TextStyle(color: kLinkTextColor),
                  ),
                  onPressed: () async{
                    // Handle create new lead action
                    Navigator.pop(context);
              var  result= await   Get.to(()=>LeadDetails(lead: Lead(), isNewLead: true));
              if(result!=null){
             Get.to(()=> AddOpportunityScreen(editedData: {
  'leadid':result.id!=null?result.id.toString():null,
  "mobileNumber":result.mobileNumber!=null?result.mobileNumber.toString():null,
  "customerName":result.customerName
  
},));
              }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Example usage in a function
Future<void> handleSelectLead(BuildContext context) async {
  Map<String, dynamic>? selectedLead = await selectLeadDialog(context);
  if (selectedLead != null) {
    // Use the selected lead
    print("Selected lead: ${selectedLead["customerName"]}");
  } else {
    print("No lead selected");
  }
}
