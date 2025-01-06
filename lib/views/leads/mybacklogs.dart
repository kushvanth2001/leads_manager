import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';

class MyBackLogs extends StatefulWidget {
  const MyBackLogs({super.key});

  @override
  State<MyBackLogs> createState() => _MyBackLogsState();
}

class _MyBackLogsState extends State<MyBackLogs> {
  String? liveAgentUserName;
  String? firstAppName;
  LeadController leadController = Get.find<LeadController>();

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingData = false;
  int _currentPage = 0;
  List<Lead> leads = [];

  @override
  void initState() {
    super.initState();
    initAsync();
    _scrollController.addListener(_scrollListener);
    _fetchLeads(); // Initial fetch
  }

  Future<void> initAsync() async {
    liveAgentUserName = await SharedPrefsHelper().getMerchantName();
    firstAppName = await SharedPrefsHelper().getFristappName();
    setState(() {}); // Refresh UI after fetching initial data
  }

  Future<void> _fetchLeads() async {
    setState(() {
      _isFetchingData = true;
    });

    try {
      List<Map<String, dynamic>> newLeads =
          await SnapPeNetworks().fetchBacklogLeads(currentPage: _currentPage);

      setState(() {
        leads.addAll(newLeads.map((e) => Lead.fromJson(e)).toList());
        _isFetchingData = false;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isFetchingData = false;
      });
      debugPrint("Error fetching leads: $e");
    }
  }

  void _scrollListener() {
    double threshold = _scrollController.position.maxScrollExtent * 0.75;

    if (_scrollController.position.pixels >= threshold && !_isFetchingData) {
      _fetchLeads();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Backlogs"),
      ),
      body: leads.isEmpty
          ? const Center(child: Text("No BackLogs"))
          : ListView.builder(
              controller: _scrollController,
              itemCount: leads.length,
              itemBuilder: (context, index) {
              
                return LeadWidget(
                  index: index,
                  onBack: () {},
                  liveAgentUserName: liveAgentUserName,
                  lead: leads[index],
                  leadController: leadController,
                  isNewleadd: false,
                  firstAppName: firstAppName,
                  chatModels: ChatController.newRequestList,
                );
              },
            ),
    );
  }
}
