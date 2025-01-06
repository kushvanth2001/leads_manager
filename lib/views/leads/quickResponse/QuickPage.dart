import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/models/model_document.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/quickResponse/filesTab.dart';
import 'package:leads_manager/views/leads/quickResponse/messageTab.dart';

class QuickResponsePage extends StatefulWidget {
  final String? customerName;
  final String? mobileNumber;
  final VoidCallback? onBack;
  LeadController? leadController;
  QuickResponsePage(this.customerName, this.mobileNumber,
      {this.onBack, this.leadController});

  @override
  _QuickResponsePageState createState() => _QuickResponsePageState();
}

class _QuickResponsePageState extends State<QuickResponsePage> {
  List<String?> _applicationNames = [];
  List<Document> _documents = [];
  List<int?> _applicationIds = [];
  List<Application> _applications = [];
  String? selectedApplicationName;
  int? selectedApplicationId;
  List<dynamic>? _elements;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    apiData();
  }

  apiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedSelectedApplicationId = prefs.getInt('selectedApplicationId');
    String? storedSelectedApplicationName =
        prefs.getString('selectedApplicationName');

    fetchApplicationsforLinkedNumber().then((applications) {
      if (mounted) {
        setState(() {
          _applicationNames =
              applications.map((app) => app.applicationName).toList();
          _applicationIds = applications.map((app) => app.id).toList();
          _applications = applications;

          if (storedSelectedApplicationId != null &&
              storedSelectedApplicationName != null) {
            selectedApplicationId = storedSelectedApplicationId;
            selectedApplicationName = storedSelectedApplicationName;
          } else if (_applicationIds.isNotEmpty) {
            selectedApplicationId = _applicationIds.first;
            final selectedApplication = _applications
                .firstWhere((app) => app.id == selectedApplicationId);
            selectedApplicationName = selectedApplication.applicationName;
          }

          if (selectedApplicationName != null) {
            getTemplates(selectedApplicationName).then((templates) {
              if (mounted) {
                setState(() {
                  _elements = templates;
                });
              }
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack != null) {
          widget.onBack!();
        }
        return true;
      },
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              // title: Text(widget.customerName ?? ''),
              title: SnapPeUI().appBarText(
                  widget.customerName ?? widget.mobileNumber, kBigFontSize),
              centerTitle: false,
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Messages'),
                  Tab(text: 'Files'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Add content for the Messages tab here
                MessagesTabContent(
                    _applications,
                    _applicationIds,
                    selectedApplicationName,
                    selectedApplicationId,
                    _elements,
                    widget.mobileNumber,
                    widget.customerName),
                // Add content for the Files tab here
                FilesTabContent(
                    _applications,
                    _applicationIds,
                    selectedApplicationName,
                    selectedApplicationId,
                    _elements,
                    widget.mobileNumber,
                    widget.customerName,
                    _applicationNames),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
