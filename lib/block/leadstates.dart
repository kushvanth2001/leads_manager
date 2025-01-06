import 'package:equatable/equatable.dart';

import '../models/model_lead.dart';


enum ListStatus{loading,sucess,failure}
class LeadStates extends Equatable{
final LeadModel leadsmodel;
final Liststatus;
 LeadStates({required this.leadsmodel,this.Liststatus=ListStatus.loading});

LeadStates copyWith({LeadModel? lead,ListStatus? Liststatus}){
return LeadStates(leadsmodel: lead??this.leadsmodel,Liststatus: Liststatus??this.Liststatus);

}
  @override
  // TODO: implement props
  List<Object?> get props => [leadsmodel,Liststatus];

}