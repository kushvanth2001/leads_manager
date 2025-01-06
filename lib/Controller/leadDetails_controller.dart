import 'package:get/get.dart';
import 'package:leads_manager/models/model_lead.dart';
import '../models/model_LeadNotes.dart';
import '../models/model_leadDetails.dart';
import '../utils/snapPeNetworks.dart';

class LeadDetailsController extends GetxController {
  Rx<LeadDetailsModel> leadDetailsModel = LeadDetailsModel().obs;
  Rx<LeadNotesModel> leadNotesModel = LeadNotesModel().obs;
  Rx<int?> leadid=null.obs;
  LeadDetailsController(int? leadId) {
    loadData(leadId);
    
  }

  Future<void> loadData(int? leadId) async {
      
    String? res = await SnapPeNetworks().getLeadNotes(leadId);
    if (res != null) {
            
      leadNotesModel.value = leadNotesModelFromJson(res);
    }
    //Get Lead Details
   
    String? response = await SnapPeNetworks().getLeadDetails(leadId);
    if (response != null) {
      print("<<responseleaddetailsmodel$response");
      leadDetailsModel.value = leadDetailsModelFromJson(response);
    }
    // Get Lead Notes
  
  }
 Future<void> loadNotes(int ? leadId)async{
     String? res = await SnapPeNetworks().getLeadNotes(leadId);
    if (res != null) {
            
      leadNotesModel.value = leadNotesModelFromJson(res);
    }
  }
}
