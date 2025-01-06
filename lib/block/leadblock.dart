


import 'package:bloc/bloc.dart';
import 'package:leads_manager/block/leadevent.dart';
import 'package:leads_manager/block/leadstates.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';

import '../models/model_lead.dart';

class LeadBlock extends Bloc<LeadEvents,LeadStates>{
  List<Lead> leads=[];
  LeadModel leadModel=LeadModel();

  LeadBlock():super(LeadStates(leadsmodel:LeadModel())){
    on<FetchLeads>(getleads);
  }

void getleads(FetchLeads event,Emitter<LeadStates> emit )async{
leadModel= leadModelFromJson( (await SnapPeNetworks().getLeads(1, 20))!);
leads=leadModel.leads!;
emit(state.copyWith(lead: leadModel,Liststatus: ListStatus.sucess));
}
}