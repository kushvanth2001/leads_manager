import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';

import '../../models/model_lead.dart';



class ViewLead extends StatefulWidget {
  final String leadId;
  
  ViewLead({required this.leadId});

  @override
  _ViewLeadState createState() => _ViewLeadState();
}

class _ViewLeadState extends State<ViewLead> {
  Lead? leadData;
  bool isLoading = true;
 final DateFormat formatter = DateFormat('dd-MM-yy HH:mm');
  @override
  void initState() {
    super.initState();
    fetchLeadData(widget.leadId);
  }

  Future<void> fetchLeadData(String leadId) async {
    print("$leadId[-]");
   dynamic k= await SnapPeNetworks().getSingleLead("$leadId");
print(k);
    setState(() {
    leadData=k;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  buildDetailRow('Id', "${leadData?.id}"),
                  buildDetailRow('Customer Name', leadData?.customerName),
                  buildDetailRow('Organization Name', leadData?.organizationName),
                  buildDetailRow('Email', leadData?.email),
                  buildDetailRow('Mobile Number', leadData?.mobileNumber),
                          buildDetailRow('City', leadData?.city),
                  buildDetailRow('State', leadData?.state),
                   buildDetailRow('Country', leadData?.country),
                  buildDetailRow("Lead Status", leadData?.leadStatus?.name),
                  buildDetailRow('Lead Scource', "${leadData?.leadSource?.sourceName}"),
                   buildDetailRow("Assigned To", leadData?.assignedTo?.userName),
                         buildDetailRow('Created on',leadData?.createdOn!=null?formatter.format( leadData?.createdOn??DateTime.now()):""),
                 
                   
                  
                ],
              ),
            ),
    );
  }

  Widget buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  List<Widget> buildCustomColumns(List<dynamic>? customColumns) {
    if (customColumns == null) return [];
    return customColumns.map((column) {
      return buildDetailRow(column['displayName'], column['value']);
    }).toList();
  }
}
