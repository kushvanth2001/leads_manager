import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../utils/snapPeUI.dart';
import '../../../domainvariables.dart';
class Promotions extends StatefulWidget {
  const Promotions({Key? key}) : super(key: key);

  @override
  State<Promotions> createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildbody(),
    );
  }

  buildbody() {
    return Column(children: [
      CupertinoSearchTextField(
        placeholder: "Search Promotion",
        decoration: SnapPeUI().searchBoxDecoration(),
        onChanged: (value) {
          // _searchOrder(keyword: value);
        },
      ),
      Expanded(
        child: FutureBuilder<List<Promotion>>(
          future: merchantPromotions(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Promotion>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text(
                          'Status: ${snapshot.data![index].status}\nCreated On: ${snapshot.data![index].createdOn}\nCommunication List Name: ${snapshot.data![index].communicationList.name}'),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return SnapPeUI().loading();
          },
        ),
      ),
    ]);
  }

  Future<List<Promotion>> merchantPromotions() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions?page=0&size=20&sortBy=createdOn&sortOrder=DESC'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = json.decode(response.body);
        final List<dynamic> promotionsList = parsed['promotions'];
        final List<Promotion> promotions =
            promotionsList.map((json) => Promotion.fromJson(json)).toList();
        return promotions;
      } else {
        print('Failed to load merchant promotions');
        throw Exception('Failed to load merchant promotions');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
}

class CommunicationList {
  final String name;

  CommunicationList({required this.name});

  factory CommunicationList.fromJson(Map<String, dynamic> json) {
    return CommunicationList(
      name: json['name'],
    );
  }
}

class Promotion {
  final String name;
  final String status;
  final String createdOn;
  final CommunicationList communicationList;

  Promotion(
      {required this.name,
      required this.status,
      required this.createdOn,
      required this.communicationList});

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      name: json['name'],
      status: json['status'],
      createdOn: json['createdOn'],
      communicationList: CommunicationList.fromJson(json['communicationList']),
    );
  }
}
