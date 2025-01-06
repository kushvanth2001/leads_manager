import 'package:flutter/material.dart';
import 'package:leads_manager/Controller/theme_contoller.dart';
import 'package:leads_manager/marketing/addpromotions.dart';
import 'package:leads_manager/views/dashboard/notneeded.dart';
import 'package:leads_manager/views/profile/profileScreen.dart';
import '../constants/colorsConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../utils/snapPeNetworks.dart';
import '../utils/snapPeUI.dart';
import 'package:get/get.dart';
import '../widgets/errowidget.dart';
import 'CallLogScreen.dart';
import 'dashboard/dashboard.dart';
import 'support/support.dart';


class CustomDrawer extends StatefulWidget {
  final BuildContext context;

  CustomDrawer({required this.context});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {


  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  SnapPeNetworks snapPeNetworks = SnapPeNetworks();
  SnapPeUI snapPeUI = SnapPeUI();
  List<Map<String, dynamic>> properties = [];
  bool _LeadswitchValue = false;
  bool _NotLeadswitchValue = false;
  bool _checkContactsForNumber=false;
  bool _convertallcallsasLeads=false;
  @override
  void initState() {
    super.initState();
    storeLeadSaveProperty();
  }

  Future<void> storeLeadSaveProperty() async {
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
    // String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
    // "Yes" ? true : false;
    bool  leadswitchvalue=await sharedPrefsHelper.canShowCallDiolougesForLead();
     bool  botleadswitchvalue=await sharedPrefsHelper.canShowCallDiolougesForNotLead();
     bool contascheck=await sharedPrefsHelper.getneedtoCheckContactsForNumber();
bool converteallcallasleads=await sharedPrefsHelper.getconvertAllcallsAsLeads();
    setState(() {
      _LeadswitchValue = leadswitchvalue;
 _NotLeadswitchValue = botleadswitchvalue;
 _checkContactsForNumber=contascheck;
    _convertallcallsasLeads=converteallcallasleads;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            child: snapPeUI.appLogoDrawer(),
            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(1))),
            ListTile(
          leading: Icon(Icons.person_rounded,),
          title: Text("Profile"),
          onTap: () {
            Get.back();
            Get.to(() => ProfileScreen());
          },
        ),
     
 ExpansionTile(
            leading: Icon(Icons.settings),
            title: Text(" Call Dialog Preferences"),
            children: [
              SwitchListTile(
                title: Text("Call OutCome Dialogue-Lead"),
                                                subtitle: Text('Shows Lead Dialogue for a call from existing lead',style: TextStyle(color: Colors.grey,fontSize: 10),),
                value: _LeadswitchValue,
                onChanged: (bool value) {
                  setState(() {
                    _LeadswitchValue = value;
                  });
                 // SnapPeUI().sendSwitchValue(value);
                  sharedPrefsHelper.setcanShowCallDiolougesForLead(_LeadswitchValue);
                },
              ),
              SwitchListTile(
                title: Text("Call OutCome Dialogue-Not Lead"),
                                subtitle: Text('Show Lead Dialogue for a new number',style: TextStyle(color: Colors.grey,fontSize: 10),),
                value: _NotLeadswitchValue,
                onChanged: (bool value) {
                  setState(() {
                    _NotLeadswitchValue = value;
                  });
                 // SnapPeUI().sendSwitchValue(value);
                  sharedPrefsHelper.setcanShowCallDiolougesForNotLead(_NotLeadswitchValue);
                },
              ),
              SwitchListTile(
                title: Text("Convert All Calls as Leads"),
                                subtitle: Text('Convert All calls as Leads',style: TextStyle(color: Colors.grey,fontSize: 10),),
                value: _convertallcallsasLeads,
                onChanged: (bool value) {
                  setState(() {
                    _convertallcallsasLeads = value;
                  });
                 // SnapPeUI().sendSwitchValue(value);
                  sharedPrefsHelper.setconvertAllcallsAsLeads(_convertallcallsasLeads);

                                       var  properties = [{
            "id": 23936605,
            "type": "client_user_attributes",
            "allowedValues": "yes,no",
            "lastModifiedTime": DateTime.now().toIso8601String(),
            "lastModifiedBy": "10618",
            "isActive": true,
             "propertyValue":_convertallcallsasLeads == true ? "yes" : "no",
            "name": "convert_all_calls_to_leads",
            "category": "",
            "displayName": "Convert all calls to Leads",
            "defaultValue": "no",
            "editableByClient": true,
            "remarks": null,
            "isVisibleToClient": true,
            "interfaceType": null

        }];
                      
    SnapPeNetworks().changeProperty(properties);
                },
              ),
              SwitchListTile(
                
                title: Text("Ignore Contacts"),
                subtitle: Text('Ignore calls from  numbers not stored as leads but are in my contacts',style: TextStyle(color: Colors.grey,fontSize: 10),),
                value: _checkContactsForNumber,
                onChanged: (bool value) {
                  setState(() {
                    _checkContactsForNumber = value;
                  });
                 // SnapPeUI().sendSwitchValue(value);
                  sharedPrefsHelper.setneedtoCheckContactsForNumber(_checkContactsForNumber);
                },
              ),
                    ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Remove From the ignored Numbers"),
          onTap: () {

         showNumberDialog(context);

          },
        ),
            ],
          ),
     
        // StatefulBuilder(
        //   builder: (BuildContext context, StateSetter setState) {
        //     return ListTile(
        //       leading: Icon(Icons.donut_large),
        //       title: Row(
        //         children: [
        //           Text("Save Lead from Calls"),
        //           Spacer(),
        //           Switch(
        //             value: _switchValue,
        //             onChanged: (bool value) {
        //               setState(() {
        //                 _switchValue = value;

        //                 properties = [
        //                   {
        //                     "status": "OK",
        //                     "messages": [],
        //                     "propertyName": "create_lead_on_call",
        //                     "propertyType": "client_user_attributes",
        //                     "name": "Create Leads From Call",
        //                     "id": 9804159,
        //                     "propertyValue":
        //                         _switchValue == true ? "Yes" : "No",
        //                     "propertyAllowedValues": "yes,no",
        //                     "propertyDefaultValues": "no",
        //                     "isEditable": true,
        //                     "remarks": "Notification Sound ",
        //                     "category": "Lead",
        //                     "isVisibleToClient": true,
        //                     "interfaceType": "drop_down",
        //                     "pricelistCode": null
        //                   }
        //                 ];
        //               });
        //               SnapPeUI().sendSwitchValue(value);
        //               if (value == true) {
        //                 SharedPrefsHelper().setProperties("Yes");
        //               } else {
        //                 SharedPrefsHelper().setProperties("No");
        //               }
        //               snapPeNetworks.changeProperty(properties);
        //             },
        //           ),
        //         ],
        //       ),
        //       onTap: () {},
        //     );
        //   },
        // ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Switch Business"),
          onTap: () {
            Get.back();
            snapPeUI.showSelectMerchantDialog(context);
          },
        ),
           ListTile(
          leading: Icon(Icons.call),
          title: Text("Call Logs"),
          onTap: ()async{
Get.to(CallLogScreen());
          },
        ),
         ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Add Promotions"),
          onTap: () {
          Get.to(()=> AddPromotions());
          }
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Privacy Policy"),
          onTap: () {
            Navigator.of(context).pop();
            snapPeUI.dialogbox(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Support"),
          onTap: () {
            Get.back();
            Get.to(() => SupportPage());
          },
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Logout"),
          onTap: () {
            // FirebaseCrashlytics.instance.crash();
            sharedPrefsHelper.removeResponse();

            SnapPeNetworks().logOut();
          },
        ),
//       Obx(() =>     ListTile(
   
//           leading:themeController.isLightTheme.value? Icon(Icons.wb_sunny):Icon(Icons.brightness_2),
//           title: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text("${themeController.isLightTheme.value? "Light Theme":"Dark Theme"}"),
//               Transform.scale(
//                 scale: 1.0, // Adjust this value to increase or decrease the size of the Switch
//                 child: Switch(
                
//                 activeColor: Colors.grey ,
//   inactiveThumbColor: Colors.yellow ,
//                 value:true, onChanged: (value){
// themeController.isLightTheme.value=value;
// themeController.updateTheme(themeController.isLightTheme.value);

//               }),),
//             ],
//           ))
         
//         ),
        
      ],
    )); // your custom drawer widget here
  }
}


void showNumberDialog(BuildContext context,) async {
await SnapPeNetworks(). leadSaveProperties();
  List<String> numbers = SharedPrefsHelper().getIgnoreNumProperties()?.split(',') ?? [];
  try{
  List<String> changednumber = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return NumberDialog(numbers: numbers);
    },
  );
if(changednumber!=null){
var k =changednumber.join(',');

SharedPrefsHelper().setIgnoreNumProperties(k);

  // Print the list of deleted numbers
                 var  properties = [
                   {
  "status": "OK",
  "messages": [],
  "propertyName": "numbers_to_be_ignored_after_call",
  "propertyType": "client_user_attributes",
  "name": "Numbers to be Ignored",
  "id": 22768173,
  "propertyValue": k,
  "propertyAllowedValues": null,
  "propertyDefaultValues": null,
  "isEditable": true,
  "remarks": "<p>These are the value that need to be ignored after the call</p>",
  "category": null, 
  "isVisibleToClient": null,
  "interfaceType": null,
  "pricelistCode": null
}
                        ];
                      
    SnapPeNetworks().changeProperty(properties);
  print('Deleted Numbers: $changednumber');}}catch(e){
    print('error in showing the Dialog or posting the request $e');
  }
}
class NumberDialog extends StatefulWidget {
  final List<String> numbers;

  NumberDialog({required this.numbers});

  @override
  _NumberDialogState createState() => _NumberDialogState();
}

class _NumberDialogState extends State<NumberDialog> {
  @override
  void initState() {
    super.initState();
    
  }


  @override
  Widget build(BuildContext context) {
    return  PopScope(
          canPop: false,
      child: AlertDialog(
        title: Text('Numbers'),
        content: Container(
          width: double.maxFinite,
          child: (widget.numbers.isEmpty || (widget.numbers.length==1&&widget.numbers[0]==''))? Text("No Numbers are ignored"):ListView.builder(
            shrinkWrap: true,
            itemCount: widget.numbers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.numbers[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                  
                      widget.numbers.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(widget.numbers);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}