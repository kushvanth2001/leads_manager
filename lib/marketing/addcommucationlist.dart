import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'package:leads_manager/models/model_leadsource.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../Controller/leads_controller.dart';
import '../constants/colorsConstants.dart';
import '../constants/constantdropdownlist.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../models/model_LeadStatus.dart';
import '../models/model_Merchants.dart';
import '../models/model_PriceList.dart';
import '../models/model_customColumn.dart';
import '../models/model_customerroles.dart';
import '../models/model_definitions.dart';
import '../models/model_lead.dart';
import '../utils/snapPeNetworks.dart';
import '../widgets/calender.dart';
import 'communitcationlist.dart';
import '../../../domainvariables.dart';
class AddCommunicationList extends StatefulWidget {
  final bool typeislead;
  final bool typeisdynamic;
  final CustomerList? fromedit;

  AddCommunicationList(
      {Key? key,
      required this.typeislead,
      required this.typeisdynamic,
      this.fromedit})
      : super(key: key);

  @override
  State<AddCommunicationList> createState() => _AddCommunicationListState();
}

class _AddCommunicationListState extends State<AddCommunicationList> {
  LeadController leadController =Get.find<LeadController>();
  bool typeisdynamic = true;
  bool typeislead = false;
  List<Tag> tags = [];
  List<Tag> _selectedtags = [];
  List<User> users = [];
  List<User> _selectedassigned = [];
  List<AllLeadsStatus> leadstatus = [];
  List<AllLeadsStatus> _selectedleadstatus = [];
  List<LeadSource> leadsources = [];
  List<LeadSource> _selectedsources = [];
  TextEditingController nameeditingcontroller = TextEditingController();
  TextEditingController descriptioneditingcontroller = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController customertextfeildcontroller = TextEditingController();
  TextEditingController textfieldcontroller = TextEditingController();
  String score1 = "";
  String score2 = "";
  SingleValueDropDownController timedropdowncontoller =
      SingleValueDropDownController();
  String scorefilter = "Equals/Contains";
  String createdOnfilter = "Between";
  int createdondate1 = 0;
  int createdondate2 = 0;
  List<String> customeriteamname = [];
  String selectedcusotmersiteamname = "";
  List<String> leadstatuslist = [];
  String Insuranceduedatefilter = "Between";
  int Insuranceduedate1 = 0;
  int Insuranceduedate2 = 0;
  String expectedlastdatefilter = "Between";
  int expectedlastdate1 = 0;
  int expectedlastdate2 = 0;
  String eventonfilter = "Between";
  int eventondate1 = 0;
  int eventondate2 = 0;
  String lastactivityfilter = "Between";
  int lastactivitydate1 = 0;
  int lastactivitydate2 = 0;
  List<String> featureslookingfor = [];
  String fristdropdownvalue = 'Tags';
  List<String> products = [];
  List<String> leadtype = [];
  List<String> partner = [];
  bool equalsto = true;

  String customerdropdown = "Customer Action";
  String customerinformation = "Tags";
  String customeractions = "Order Amount";
  String customerorderamountfilter = "Equals/Contains";
  String customerorderamount1 = "";
  String customerorderamount2 = "";
  String customerorderdatefilter = "Between";
  int customerorderdate1 = 0;
  int customerorderdate2 = 0;
  String customerlogindatefilter = "Between";
  int customerlogindate1 = 0;
  int customerlogindate2 = 0;
  List<String> customertags = [];
  List<CustomerRole> allcustomerroles = [];
  List<CustomerRole> selectedcustomerroles = [];
  List<String> customeraffiliatestatus = [];
  List<Definitions> definitions = [];
  List<PricelistMaster> customerpricelist = [];
  List<PricelistMaster> selectedcustomerpricelist = [];
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    var u = await fetchLeadSources();
    var s = await CustomerRole.fetchCustomerRoles();
    var h = await SnapPeNetworks.getItemNameCustomer();
    var v = await SnapPeNetworks.getAllMasterPricelist();

    if (widget.fromedit != null) {
      List<Definitions> defs = [];
      defs = await Definitions.fetchDefinitions(widget.fromedit!.id);
      setState(() {
        definitions = defs;
        nameeditingcontroller.text = widget.fromedit!.name;
        descriptioneditingcontroller.text = widget.fromedit!.description ?? "";
      });
    }
    setState(() {
      typeisdynamic = widget.typeisdynamic;
      typeislead = widget.typeislead;
      tags = leadController.tags.value;
      users = leadController.assignedTo;
      allcustomerroles = s;
      leadstatus = leadController.leadStatus;
      leadsources = u;
      customeriteamname = h;
      customerpricelist = v;
      print("leadsources");
      print(leadsources);
      print(customeriteamname);
    });
  }

  Widget equalsTo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 7,
        ),
        Text(
          "Equals To :",
          style: TextStyle(
              color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 7,
        ),
        Switch(
            value: equalsto,
            onChanged: (value) {
              setState(() {
                equalsto = value;
              });
            }),
      ],
    );
  }

  String mapMatchModeToSymbol(Definitions def) {
    switch (def.matchMode.toLowerCase().replaceAll(' ', '')) {
      case "lessthan":
        return "<";
      case "equals/contains":
        return "==";
      case "equals":
        return "==";
      case "notequalsto":
        return "!=";
      case "lessthanorequalto":
        return "<=";
      case "greaterthan":
        return ">";
      case "greaterthanorequalto":
        return ">=";
      case "between":
        return "From:${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(def.from ?? 0))}\nTo:${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(def.to ?? 0))}";
      default:
        return def.matchMode;
    }
  }

  String formatDefinition(Definitions definition) {
    String matchMode = mapMatchModeToSymbol(definition);
    String name = definition.value ?? "".replaceAll(',', '-');
    return '$matchMode $name';
  }

  void cleardata() {
    setState(() {
      score1 = "";
      score2 = "";
      _selectedassigned = [];
      _selectedleadstatus = [];
      _selectedtags = [];
      _selectedleadstatus = [];
      products = [];
      leadstatuslist = [];
      partner = [];
      leadtype = [];
      featureslookingfor = [];
      createdOnfilter = "Between";
      lastactivityfilter = "Between";
      eventonfilter = "Between";
      expectedlastdatefilter = "Between";
      Insuranceduedatefilter = "Between";
      timedropdowncontoller
          .setDropDown(DropDownValueModel(name: "Between", value: "Between"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Type :",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Row(
                children: [
                  Radio(
                      activeColor: kPrimaryColor,
                      splashRadius: 10,
                      value: true,
                      groupValue: typeisdynamic,
                      onChanged: (value) {
                        setState(() {
                          typeisdynamic = value as bool;
                        });
                      }),
                  Text(" Dynamic"),
                  Radio(
                      activeColor: kPrimaryColor,
                      splashRadius: 7,
                      value: false,
                      groupValue: typeisdynamic,
                      onChanged: (value) {
                        setState(() {
                          typeisdynamic = value as bool;
                        });
                      }),
                  Text(" Static")
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "For :",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Row(
                children: [
                  Radio(
                      activeColor: kPrimaryColor,
                      splashRadius: 10,
                      value: true,
                      groupValue: typeislead,
                      onChanged: (value) {
                        setState(() {
                          typeislead = value as bool;
                        });
                      }),
                  Text(" Lead     "),
                  Radio(
                      activeColor: kPrimaryColor,
                      splashRadius: 10,
                      value: false,
                      groupValue: typeislead,
                      onChanged: (value) {
                        setState(() {
                          typeislead = value as bool;
                        });
                      }),
                  Text(" Customer")
                ],
              ),
              SizedBox(
                height: 20,
              ),
              typeisdynamic == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "*Name :",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: nameeditingcontroller,
                            decoration:
                                InputDecoration(border: OutlineInputBorder()),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Description :",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: descriptioneditingcontroller,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            decoration:
                                InputDecoration(border: OutlineInputBorder()),
                          ),
                        )
                      ],
                    )
                  : typeislead
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                                height: 40,
                                width: 200,
                                child: DropDownTextField(
                                  clearOption: false,
                                  initialValue: 'Tags',
                                  dropDownList: [
                                    DropDownValueModel(
                                        name: 'Tags', value: 'Tags'),
                                    DropDownValueModel(
                                        name: 'Customer Name',
                                        value: 'Customer Name'),
                                    DropDownValueModel(
                                        name: 'Mobile Number',
                                        value: 'Mobile Number'),
                                    DropDownValueModel(
                                        name: 'Organization Name',
                                        value: 'Organization Name'),
                                    DropDownValueModel(
                                        name: 'Email', value: 'Email'),
                                    DropDownValueModel(
                                        name: 'Assigned To',
                                        value: 'Assigned To'),
                                    DropDownValueModel(
                                        name: 'Status', value: 'Status'),
                                    DropDownValueModel(
                                        name: 'Source', value: 'Source'),
                                    DropDownValueModel(
                                        name: 'Score', value: 'Score'),
                                    DropDownValueModel(
                                        name: 'Created On',
                                        value: 'Created On'),
                                    DropDownValueModel(
                                        name: 'Last Activity',
                                        value: 'Last Activity'),
                                    DropDownValueModel(
                                        name: 'Billing Cycle',
                                        value: 'Billing Cycle'),
                                    DropDownValueModel(
                                        name: 'Priceing', value: 'Priceing'),
                                    DropDownValueModel(
                                        name: 'Features Looking for',
                                        value: 'Features Looking for'),
                                    DropDownValueModel(
                                        name: 'Insurance Due Date',
                                        value: 'Insurance Due Date'),
                                    DropDownValueModel(
                                        name: 'Requirement',
                                        value: 'Requirement'),
                                    DropDownValueModel(
                                        name: 'Quantity', value: 'Quantity'),
                                    DropDownValueModel(
                                        name: 'Lead Status',
                                        value: 'Lead Status'),
                                    DropDownValueModel(
                                        name: 'Event On', value: 'Event On'),
                                    DropDownValueModel(
                                        name: 'Product', value: 'Product'),
                                    DropDownValueModel(
                                        name: 'Lead Type', value: 'Lead Type'),
                                    DropDownValueModel(
                                        name: 'Expected Close Date',
                                        value: 'Expected Close Date'),
                                    DropDownValueModel(
                                        name: 'Partner', value: 'Partner'),
                                    DropDownValueModel(
                                        name: 'Promotion Tag',
                                        value: 'Promotion Tag'),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      dateController.text = "";
                                      textfieldcontroller.text = "";
                                      fristdropdownvalue = value.value;
                                      cleardata();
                                    });
                                  },
                                )),
                            getLeadWidget(fristdropdownvalue),
                            Container(
                              constraints: BoxConstraints(
                                  maxHeight: 400,
                                  maxWidth: 400,
                                  minHeight: 0,
                                  minWidth: 0),
                              child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: definitions.length,
                                  itemBuilder: ((context, index) {
                                    return Card(
                                      elevation: 4,
                                      child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(definitions[index].name ??
                                                  ""),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    definitions.removeAt(index);
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor: Colors.red,
                                                  child: Icon(Icons.delete),
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(
                                            formatDefinition(
                                                definitions[index]),
                                          )),
                                    );
                                  })),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "*Basic Details :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Text(
                              "*Name :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: nameeditingcontroller,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Description :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 70,
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: TextEditingController(),
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            )
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Filter :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
DropDownTextField(clearOption: false,dropDownList: [DropDownValueModel(name: "Customer Actions", value: "Customer Actions"),DropDownValueModel(name: "Customer Information", value: "Customer Information")],initialValue:"Customer Actions" ,onChanged:   (p0) {
                                setState(() {
                                  customerdropdown = p0;
                                  print(customerdropdown);
                                });
                              },),
                          


                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "*Name :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            customerdropdown == "Customer Information"
                                ? Container(
                                    child: DropDownTextField(
                                      clearOption: false,
                                      initialValue: "Tags",
                                      onChanged: (value) {
                                        setState(() {
                                          customerinformation = value.value;
                                        });
                                      },
                                      dropDownList: constcustomerinformation
                                          .map((e) => DropDownValueModel(
                                              name: e, value: e))
                                          .toList(),
                                    ),
                                  )
                                : DropDownTextField(
                                    clearOption: false,
                                    initialValue: "Order Amount",
                                    onChanged: (value) {
                                      setState(() {
                                        customeractions = value.value;
                                      });
                                    },
                                    dropDownList: constcustomeractions
                                        .map((e) => DropDownValueModel(
                                            name: e, value: e))
                                        .toList(),
                                  ),

                            getCustomerWidget(
                                customerdropdown == "Customer Information"
                                    ? customerinformation
                                    : customeractions),

                            SizedBox(
                              height: 10,
                            ),

                            Container(
                              constraints: BoxConstraints(
                                  maxHeight: 400,
                                  maxWidth: 400,
                                  minHeight: 0,
                                  minWidth: 0),
                              child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: definitions.length,
                                  itemBuilder: ((context, index) {
                                    return Card(
                                      elevation: 4,
                                      child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(definitions[index].name ??
                                                  ""),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    definitions.removeAt(index);
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor: Colors.red,
                                                  child: Icon(Icons.delete),
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(
                                            formatDefinition(
                                                definitions[index]),
                                          )),
                                    );
                                  })),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "*Basic Details :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Divider(
                              color: Colors.black,
                            ),

                            Text(
                              "*Name :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: nameeditingcontroller,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Description :",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 70,
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: TextEditingController(),
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            )
                          ],
                        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("close")),
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (nameeditingcontroller.text == "") {
                          Fluttertoast.showToast(
                              msg: 'Please Enter a valid Name');
                        } else if (definitions.length == 0 &&
                            typeisdynamic == true) {
                          Fluttertoast.showToast(
                              msg: 'Please Select Atleast one Filter');
                        } else {
                          CustomerList customerlist = widget.fromedit != null
                              ? await CustomerList.editCommunicationList({
                                  "id": widget.fromedit!.id,
                                  "name": nameeditingcontroller.text,
                                  "description":
                                      descriptioneditingcontroller.text == ""
                                          ? null
                                          : descriptioneditingcontroller.text,
                                  "type": widget.fromedit!.type,
                                }, widget.fromedit!.id, typeisdynamic)
                              : await CustomerList.postCommunicationList(
                                  CustomerList.fromJson({
                                    "type": typeislead ? "lead" : "customer",
                                    "name": nameeditingcontroller.text,
                                    "description":
                                        descriptioneditingcontroller.text
                                  }),
                                  typeisdynamic);
                          if (typeisdynamic) {
                            bool c = await Definitions.postDefinitions(
                                definitions, customerlist.id);
                            c
                                ? Fluttertoast.showToast(
                                    msg: 'Successfully Add Communication List')
                                : Fluttertoast.showToast(
                                    msg:
                                        'There is a Problem Please check and try Again');
                          }

                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(widget.fromedit != null ? "Edit" : "Add")),
                ],
              )
            ],
          ),
        ));
  }

  Widget getLeadWidget(String k) {
    if (k == "Tags") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          Text(
            "Equals To :",
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Switch(
              value: equalsto,
              onChanged: (value) {
                setState(() {
                  equalsto = value;
                });
              }),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Tags"),
            title: Text("Search Tags"),
            searchHint: "Search Tags",
            items: tags.map((e) => MultiSelectItem(e, e.name ?? "")).toList(),
            listType: MultiSelectListType.LIST,
            // isDismissible: true,
            onConfirm: (values) {
              setState(() {
                _selectedtags = values as List<Tag>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: "Tags",
                      value: _selectedtags.map((e) => e.name).join(','),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
                print(definitions);
              },
              child: Text("Add"))
        ],
      );
    } else if ([
      "Customer Name",
      "Email",
      "Mobile Number",
      "Organization Name",
      "Billing Cycle",
      "Priceing",
      "Requirement",
      "Quantity",
      "Promotion Tag"
    ].contains(k)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6,
          ),
          [
            "Billing Cycle",
            "Priceing",
            "Requirement",
            "Quantity",
            "Promotion Tag"
          ].contains(k)
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Equals To :",
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Switch(
                        value: equalsto,
                        onChanged: (value) {
                          setState(() {
                            equalsto = value;
                            print(equalsto);
                          });
                        }),
                  ],
                ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
              height: 40,
              width: 200,
              child: TextFormField(
                controller: textfieldcontroller,
                decoration: InputDecoration(border: OutlineInputBorder()),
              )),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: textfieldcontroller.text,
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Assigned To") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Equals To :",
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Switch(
              value: equalsto,
              onChanged: (value) {
                setState(() {
                  equalsto = value;
                });
              }),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Assigned To"),
            title: Text("Assigned To"),
            searchHint: "Search",
            items:
                users.map((e) => MultiSelectItem(e, e.fullName ?? "")).toList(),
            listType: MultiSelectListType.LIST,
            // isDismissible: true,
            onConfirm: (values) {
              setState(() {
                _selectedassigned = values as List<User>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: _selectedassigned.map((e) => e.fullName).join(','),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Status") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Equals To :",
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Switch(
              value: equalsto,
              onChanged: (value) {
                setState(() {
                  equalsto = value;
                });
              }),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Status"),
            title: Text("Select Status"),
            searchHint: "Search",
            items: leadstatus
                .map((e) => MultiSelectItem(e, e.statusName ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                _selectedleadstatus = values as List<AllLeadsStatus>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: _selectedleadstatus
                          .map((e) => e.statusName)
                          .join(','),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Source") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Equals To :",
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Switch(
              value: equalsto,
              onChanged: (value) {
                setState(() {
                  equalsto = value;
                });
              }),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Source"),
            title: Text("Source"),
            searchHint: "Search",
            items: leadsources
                .map((e) => MultiSelectItem(e, e.sourceName ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                _selectedsources = values as List<LeadSource>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value:
                          _selectedsources.map((e) => e.sourceName).join(','),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Score") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              clearOption: false,
              initialValue: "Equals/Contains",
              onChanged: (value) {
                setState(() {
                  scorefilter = value.value;
                });
              },
              textFieldDecoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Select Value"),
              dropDownList: constscorelist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            onChanged: (value) {
              setState(() {
                score1 = value;
              });
            },
            decoration: InputDecoration(
                hintText: scorefilter == "Between" ? "From" : null,
                border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          scorefilter == "Between"
              ? TextFormField(
                  onChanged: (value) {
                    setState(() {
                      score2 = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "TO"),
                  keyboardType: TextInputType.number,
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: null,
                      from: int.tryParse(score1),
                      to: scorefilter == "Between"
                          ? int.tryParse(score2)
                          : null,
                      matchMode: scorefilter,
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Created On") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              controller: timedropdowncontoller,
              clearOption: false,
              onChanged: (value) {
                setState(() {
                  createdOnfilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    createdondate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    createdondate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    createdondate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    createdondate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    createdondate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    createdondate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    createdondate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: constcalenderlist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          createdOnfilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              createdondate1 = start.millisecondsSinceEpoch;
                              createdondate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: null,
                      from: createdondate1,
                      to: createdondate2,
                      matchMode: createdOnfilter,
                      id: definitions.length));
                  createdOnfilter = "Between";
                  createdondate1 = 0;
                  createdondate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Last Activity") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              clearOption: false,
              controller: timedropdowncontoller,
              onChanged: (value) {
                setState(() {
                  lastactivityfilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    lastactivitydate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    lastactivitydate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    lastactivitydate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    lastactivitydate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    lastactivitydate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    lastactivitydate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    lastactivitydate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: constcalenderlist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          lastactivityfilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              lastactivitydate1 = start.millisecondsSinceEpoch;
                              lastactivitydate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: null,
                      from: lastactivitydate1,
                      to: lastactivitydate2 == 0 ? null : lastactivitydate2,
                      matchMode: scorefilter,
                      id: definitions.length));
                  lastactivityfilter = "Between";
                  lastactivitydate1 = 0;
                  lastactivitydate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Features Looking for") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Features"),
            title: Text("Select Features"),
            searchHint: "Search",
            items: constfeatureslooklist
                .map((e) => MultiSelectItem(e, e ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                featureslookingfor = values as List<String>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: featureslookingfor.map((e) => e).join(','),
                      matchMode: "equals",
                      id: definitions.length,
                      from: null,
                      to: null));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Insurance Due Date") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              clearOption: false,
              controller: timedropdowncontoller,
              onChanged: (value) {
                setState(() {
                  Insuranceduedatefilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    Insuranceduedate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    Insuranceduedate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    Insuranceduedate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    Insuranceduedate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    Insuranceduedate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    Insuranceduedate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    Insuranceduedate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: [
                DropDownValueModel(name: "Between", value: "Between"),
                DropDownValueModel(name: "Today", value: "Today"),
                DropDownValueModel(name: "Yesterday", value: "Yesterday"),
                DropDownValueModel(name: "Last 7 days", value: "Last 7 days"),
                DropDownValueModel(name: "This Month", value: "This Month"),
                DropDownValueModel(name: "Last Month", value: "Last Month"),
                DropDownValueModel(name: "This Year", value: "This Year"),
                DropDownValueModel(name: "last Year", value: "Last Year"),
              ]),
          SizedBox(
            height: 5,
          ),
          Insuranceduedatefilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              Insuranceduedate1 = start.millisecondsSinceEpoch;
                              Insuranceduedate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: Insuranceduedatefilter,
                      value: null,
                      from: Insuranceduedate1,
                      to: Insuranceduedate2 == 0 ? null : Insuranceduedate2,
                      matchMode: Insuranceduedatefilter,
                      id: definitions.length));
                  Insuranceduedatefilter = "Between";
                  Insuranceduedate1 = 0;

                  Insuranceduedate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Lead Status") {
      return Column(
        children: [
          SizedBox(
            height: 7,
          ),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Lead Status"),
            title: Text("Select Lead Status"),
            searchHint: "Search",
            items: constleadstatus
                .map((e) => MultiSelectItem(e, e ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            // isDismissible: true,
            onConfirm: (values) {
              setState(() {
                leadstatuslist = values as List<String>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: leadstatuslist.map((e) => e).join(','),
                      matchMode: "equals",
                      id: definitions.length,
                      from: null,
                      to: null));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Event On") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropDownTextField(
              clearOption: false,
              controller: timedropdowncontoller,
              onChanged: (value) {
                setState(() {
                  eventonfilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    eventondate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    eventondate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    eventondate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    eventondate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    eventondate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    eventondate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    eventondate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: [
                DropDownValueModel(name: "Between", value: "Between"),
                DropDownValueModel(name: "Today", value: "Today"),
                DropDownValueModel(name: "Yesterday", value: "Yesterday"),
                DropDownValueModel(name: "Last 7 days", value: "Last 7 days"),
                DropDownValueModel(name: "This Month", value: "This Month"),
                DropDownValueModel(name: "Last Month", value: "Last Month"),
                DropDownValueModel(name: "This Year", value: "This Year"),
                DropDownValueModel(name: "last Year", value: "Last Year"),
              ]),
          SizedBox(
            height: 5,
          ),
          eventonfilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              eventondate1 = start.millisecondsSinceEpoch;
                              eventondate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: null,
                      from: eventondate1,
                      to: eventondate2 == 0 ? null : eventondate2,
                      matchMode: eventonfilter,
                      id: definitions.length));

                  eventonfilter = "Between";
                  eventondate1 = 0;
                  eventondate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Product") {
      return Column(
        children: [
          SizedBox(
            height: 7,
          ),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Product"),
            title: Text("Select Product"),
            searchHint: "Search",
            items: constproductlist
                .map((e) => MultiSelectItem(e, e ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                products = values as List<String>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: products.map((e) => e).join(','),
                      matchMode: "equals",
                      id: definitions.length,
                      from: null,
                      to: null));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Lead Type") {
      return Column(
        children: [
          SizedBox(
            height: 7,
          ),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Lead Type"),
            title: Text("Select Lead Type"),
            searchHint: "Search",
            items: constleadtypelist
                .map((e) => MultiSelectItem(e, e ?? ""))
                .toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                leadtype = values as List<String>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: leadtype.map((e) => e).join(','),
                      matchMode: "equals",
                      id: definitions.length,
                      from: null,
                      to: null));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Expected Close Date") {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 7,
        ),
        DropDownTextField(
            clearOption: false,
            controller: timedropdowncontoller,
            onChanged: (value) {
              setState(() {
                expectedlastdatefilter = value.value;
                // Update Createdondate1 based on the selected value
                if (value.value == "Today") {
                  expectedlastdate1 = DateTime.now().millisecondsSinceEpoch;
                } else if (value.value == "Yesterday") {
                  expectedlastdate1 = DateTime.now()
                      .subtract(Duration(days: 1))
                      .millisecondsSinceEpoch;
                } else if (value.value == "Last 7 days") {
                  expectedlastdate1 = DateTime.now()
                      .subtract(Duration(days: 7))
                      .millisecondsSinceEpoch;
                } else if (value.value == "This Month") {
                  expectedlastdate1 =
                      DateTime(DateTime.now().year, DateTime.now().month, 1)
                          .millisecondsSinceEpoch;
                } else if (value.value == "Last Month") {
                  expectedlastdate1 =
                      DateTime(DateTime.now().year, DateTime.now().month - 1, 1)
                          .millisecondsSinceEpoch;
                } else if (value.value == "This Year") {
                  expectedlastdate1 = DateTime(DateTime.now().year, 1, 1)
                      .millisecondsSinceEpoch;
                } else if (value.value == "Last Year") {
                  expectedlastdate1 = DateTime(DateTime.now().year - 1, 1, 1)
                      .millisecondsSinceEpoch;
                }
              });
            },
            textFieldDecoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            dropDownList: [
              DropDownValueModel(name: "Between", value: "Between"),
              DropDownValueModel(name: "Today", value: "Today"),
              DropDownValueModel(name: "Yesterday", value: "Yesterday"),
              DropDownValueModel(name: "Last 7 days", value: "Last 7 days"),
              DropDownValueModel(name: "This Month", value: "This Month"),
              DropDownValueModel(name: "Last Month", value: "Last Month"),
              DropDownValueModel(name: "This Year", value: "This Year"),
              DropDownValueModel(name: "last Year", value: "Last Year"),
            ]),
        SizedBox(
          height: 5,
        ),
        expectedlastdatefilter == "Between"
            ? TextFormField(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Your dialog content goes here
                      return CalendarPage(
                        onDateSelected: (start, end) {
                          setState(() {
                            expectedlastdate1 = start.millisecondsSinceEpoch;
                            expectedlastdate2 = end.millisecondsSinceEpoch;
                            dateController.text =
                                "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                            print("date controller" + dateController.text);
                          });
                        },
                      );
                    },
                  );
                },
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today)),
              )
            : Container(),
        SizedBox(
          height: 7,
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                definitions.add(Definitions(
                    name: fristdropdownvalue,
                    value: null,
                    from: expectedlastdate1,
                    to: expectedlastdate2 == 0 ? null : expectedlastdate2,
                    matchMode: expectedlastdatefilter,
                    id: definitions.length));
                expectedlastdatefilter = "Between";
                expectedlastdate1 = 0;
                expectedlastdate2 = 0;
              });
            },
            child: Text("Add"))
      ]);
    } else if (k == "Partner") {
      return Column(
        children: [
          SizedBox(
            height: 7,
          ),
          MultiSelectDialogField(
            // dialogHeight: 500,
            // dialogWidth: 500,
            searchable: true,
            buttonText: Text("Select Partner"),
            title: Text("Select Partner"),
            searchHint: "Search",
            items:
                constpartner.map((e) => MultiSelectItem(e, e ?? "")).toList(),
            listType: MultiSelectListType.LIST,
            //isDismissible: true,
            onConfirm: (values) {
              setState(() {
                partner = values as List<String>;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: partner.map((e) => e).join(','),
                      matchMode: "equals",
                      id: definitions.length,
                      from: null,
                      to: null));
                });
              },
              child: Text("Add"))
        ],
      );
    } else {
      return Container();
    }
  }

  Widget getCustomerWidget(k) {
    if (k == "Tags") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equalsTo(),
          SizedBox(
            height: 10,
          ),
          customColumnMultiselect(
            hintText: "Tags",
            initiallist: ["1223", "ZXC", "ABC", "PlexiHealthPotentiallnv"],
            onValueChanged: (List<dynamic> result) {
              setState(() {
                customertags = result
                    .map((dynamic element) => element.toString())
                    .toList();
              });
              customertags.removeAt(0);
              print(customertags);
            },
          ),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: k,
                      value: customertags.join(","),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if ([
      "Customer Name",
      "Email",
      "Mobile Number",
      "Parent Customer Name",
      "Organization Name",
      "Community",
      "City",
      "State",
      "Full Address",
      "Billing Cycle",
      "Priceing",
      "Requirement",
      "Quantity",
      "Promotion Tag",
      "Total Order Amount"
    ].contains(k)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6,
          ),
          [].contains(k) ? Container() : equalsTo(),
          SizedBox(
            height: 5,
          ),
          SizedBox(
              height: 40,
              width: 200,
              child: TextFormField(
                controller: customertextfeildcontroller,
                decoration: InputDecoration(border: OutlineInputBorder()),
              )),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: k,
                      value: customertextfeildcontroller.text,
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Affiliate Status") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          customColumnMultiselect(
            hintText: "Affiliate Status",
            initiallist: constaffiliatestatus,
            onValueChanged: (List<dynamic> result) {
              setState(() {
                customeraffiliatestatus = result
                    .map((dynamic element) => element.toString())
                    .toList();
                customeraffiliatestatus.removeAt(0);
              });

              print(customeraffiliatestatus);
            },
          ),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: k,
                      value: customertags.join(","),
                      matchMode: "equals",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Roles") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          customColumnMultiselect(
            considerationvalue: "name",
            hintText: "Roles",
            initiallist: allcustomerroles,
            onValueChanged: (List<dynamic> result) {
              setState(() {
                selectedcustomerroles = result as List<CustomerRole>;
              });
              selectedcustomerroles.removeAt(0);
              print(selectedcustomerroles);
            },
          ),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: customerdropdown,
                      value: customertags.join(","),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Order Amount") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              clearOption: false,
              initialValue: "Equals/Contains",
              onChanged: (value) {
                setState(() {
                  customerorderamountfilter = value.value;
                });
              },
              textFieldDecoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Select Value"),
              dropDownList: constscorelist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            onChanged: (value) {
              setState(() {
                customerorderamount1 = value;
              });
            },
            decoration: InputDecoration(
                hintText:
                    customerorderamountfilter == "Between" ? "From" : null,
                border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          scorefilter == "Between"
              ? TextFormField(
                  onChanged: (value) {
                    setState(() {
                      customerorderamount2 = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "TO"),
                  keyboardType: TextInputType.number,
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: fristdropdownvalue,
                      value: null,
                      from: int.tryParse(customerorderamount1),
                      to: customerorderamountfilter == "Between"
                          ? int.tryParse(customerorderamount2)
                          : null,
                      matchMode: customerorderamountfilter,
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Order Date") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              controller: timedropdowncontoller,
              clearOption: false,
              onChanged: (value) {
                setState(() {
                  createdOnfilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    customerorderdate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    customerorderdate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    customerorderdate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    customerorderdate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    customerorderdate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    customerorderdate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    customerorderdate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: constcalenderlist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          customerorderdatefilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              customerorderdate1 = start.millisecondsSinceEpoch;
                              customerorderdate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: customeractions,
                      value: null,
                      from: customerorderdate1,
                      to: createdondate2 == 0 ? null : customerorderdate2,
                      matchMode: createdOnfilter,
                      id: definitions.length));
                  customerorderdatefilter = "Between";
                  customerorderdate1 = 0;
                  customerorderdate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Login Date") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              controller: timedropdowncontoller,
              clearOption: false,
              onChanged: (value) {
                setState(() {
                  customerlogindatefilter = value.value;
                  // Update Createdondate1 based on the selected value
                  if (value.value == "Today") {
                    customerlogindate1 = DateTime.now().millisecondsSinceEpoch;
                  } else if (value.value == "Yesterday") {
                    customerlogindate1 = DateTime.now()
                        .subtract(Duration(days: 1))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last 7 days") {
                    customerlogindate1 = DateTime.now()
                        .subtract(Duration(days: 7))
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Month") {
                    customerlogindate1 =
                        DateTime(DateTime.now().year, DateTime.now().month, 1)
                            .millisecondsSinceEpoch;
                  } else if (value.value == "Last Month") {
                    customerlogindate1 = DateTime(
                            DateTime.now().year, DateTime.now().month - 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "This Year") {
                    customerlogindate1 = DateTime(DateTime.now().year, 1, 1)
                        .millisecondsSinceEpoch;
                  } else if (value.value == "Last Year") {
                    customerlogindate1 = DateTime(DateTime.now().year - 1, 1, 1)
                        .millisecondsSinceEpoch;
                  }
                });
              },
              textFieldDecoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              dropDownList: constcalenderlist
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 5,
          ),
          customerlogindatefilter == "Between"
              ? TextFormField(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Your dialog content goes here
                        return CalendarPage(
                          onDateSelected: (start, end) {
                            setState(() {
                              customerlogindate1 = start.millisecondsSinceEpoch;
                              customerlogindate2 = end.millisecondsSinceEpoch;
                              dateController.text =
                                  "${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";
                              print("date controller" + dateController.text);
                            });
                          },
                        );
                      },
                    );
                  },
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                )
              : Container(),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: customeractions,
                      value: null,
                      from: customerlogindate1,
                      to: customerlogindate2 == 0 ? null : customerorderdate2,
                      matchMode: createdOnfilter,
                      id: definitions.length));
                  customerorderdatefilter = "Between";
                  customerlogindate1 = 0;
                  customerlogindate2 = 0;
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Item Name") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 7,
          ),
          equalsTo(),
          SizedBox(
            height: 7,
          ),
          DropDownTextField(
              clearOption: false,
              onChanged: (value) {
                setState(() {
                  selectedcusotmersiteamname = value.value;
                });
              },
              textFieldDecoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Select Value"),
              dropDownList: customeriteamname
                  .map((e) => DropDownValueModel(name: e, value: e))
                  .toList()),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: customeractions,
                      value: null,
                      from: null,
                      to: null,
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else if (k == "Price List") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equalsTo(),
          SizedBox(
            height: 10,
          ),
          MultiSelectDialogField(
            buttonText: Text("Search"),
            onConfirm: (value) {
              setState(() {
                selectedcustomerpricelist = value as List<PricelistMaster>;
              });
            },
            items: customerpricelist
                .map((e) => MultiSelectItem(e, e.name ?? ""))
                .toList(),
          ),
          SizedBox(
            height: 7,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  definitions.add(Definitions(
                      name: k,
                      value: selectedcustomerpricelist
                          .map((e) => e.name)
                          .toList()
                          .join(","),
                      matchMode: equalsto ? "equals" : "notequalsto",
                      id: definitions.length));
                });
              },
              child: Text("Add"))
        ],
      );
    } else {
      return Container();
    }
  }

  Future<List<LeadSource>> fetchLeadSources() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-source'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['allLeadsSources'];
        return List<LeadSource>.from(
            parsed.map((json) => LeadSource.fromJson(json)));
      } else {
        print('Failed to load lead sources ${response?.statusCode}');
        throw Exception('Failed to load lead sources');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
}
