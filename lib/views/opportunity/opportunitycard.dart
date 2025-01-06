import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OpportunityCard extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tooltip(
              message: 'Opportunity Name',
              child: Text(
                'Opportunity: ${opportunity['opportunityName']??'-'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Tooltip(
              message: 'Mobile Number',
              child: Text('Mobile Number: ${opportunity['mobileNumber']??'-'}'),
            ),
            SizedBox(height: 8),
       opportunity['assignedTo']!=null && (opportunity['assignedTo']?['firstName']!=''||opportunity['assignedTo']?['lastName']!='')?     Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: 'Assigned To (Full Name)',
                child: Text(
                  'Assigned To:  ${opportunity['assignedTo']?['firstName'] ??''} ${opportunity['assignedTo']?['lastName']??''}',
                ),
              ),
            ):Container(),
            
            Tooltip(
              message: 'Customer Name',
              child: Text('Customer Name: ${opportunity['customerName']??'-'}'),
            ),
            SizedBox(height: 8),
          opportunity['organizationName']!=null &&  opportunity['organizationName']!=''?    Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tooltip(
                message: 'Organization Name',
                child: Text('Organization Name: ${opportunity['organizationName']??'-'}'),
              ),
          ):Container(),
            SizedBox(height: 8),
            Tooltip(
              message: 'Expected Date',
              child: Text('Expected Date: ${opportunity['expectedDate']!=null?DateFormat('dd-MM-yyyy hh:mm a').format( DateTime.parse(opportunity['expectedDate'])) : 'N/A'}'),
            ),
         
           
          ],
        ),
      ),
    );
  }
}
