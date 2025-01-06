import 'dart:convert';

import 'package:bottom_picker/widgets/date_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/views/order/orderScreen.dart';
import 'package:textfield_search/textfield_search.dart';
import '../../../models/model_catalogue.dart';
import '../../../models/model_order_summary.dart';
import '../../../models/model_delivery_schedule.dart';
import '../../../utils/snapPeNetworks.dart';
import '../../../utils/snapPeUI.dart';

import '../../../constants/styleConstants.dart';
import '../../../models/model_PriceList.dart';
import '../../domainvariables.dart';
import '../../helper/networkHelper.dart';
import '../../models/model_skuunits.dart';

class QuotationCartScreeen extends StatefulWidget {
  
  final OrderSummaryModel order;
  final bool fromlead;
  final Function? onBack;
  const QuotationCartScreeen(
      {Key? key, required this.order, this.fromlead = false,this.onBack})
      : super(key: key);

  @override
  _QuotationCartScreeenState createState() => _QuotationCartScreeenState();
}

class _QuotationCartScreeenState extends State<QuotationCartScreeen> {
  List<Sku> skuList = [];
  List<DeliveryOption> deliveryOption = [];
  final sugControllerBox = SuggestionsBoxController();
  TextEditingController validtill = TextEditingController();
  DateFormat formatter = DateFormat('dd/MM/yyyy');
  //String? _selectedDeliveryDate;
  @override
  void initState() {
    super.initState();
    fetchDelivery();
    setValue();
    validtill.text = formatter.format(DateTime.now().add(Duration(days: 6)));
    widget.order?.validTill =
        DateTime.now().add(Duration(days: 6)).toIso8601String();
    print(widget.order);
  }

  setValue() {
    widget.order.createdOn = DateTime.now();
    widget.order.orderStatus = "QUOTATION";
    widget.order.amountPaid = 0;
    widget.order.orderAmount = 0;
    widget.order.originalAmount = 0;
    widget.order.paymentStatus = "PENDING";
    widget.order.deliveryCharges = 0;
  }

  fetchDelivery() async {
    if (widget.order.community == null || widget.order.userId == null) {
      SnapPeUI().toastError(
          message:
              "SomeThing Wrong. (Selected customer's Community or UserId might be null.)");
      return;
    }
    showPriceListDialog(
        await SnapPeNetworks().getPriceList(widget.order.userId!));

    var result =
        await SnapPeNetworks().getDeliveryTime(widget.order.community!);
    print(result);
    if (result == "") {
      return;
    }
    DeliveryModel deliveryModel = deliveryModelFromJson(result);
    deliveryOption = deliveryModel.deliveryOptions ?? [];
    // widget.order.selectedDeliveryBucketId =
    //     deliveryModel.deliveryOptions![0].id;
    // widget.order.deliveryTime =
    //     deliveryModel.deliveryOptions![0].deliveryOption;
  }

  showPriceListDialog(List<PricelistMaster> pricelistMaster) {
    if (pricelistMaster.length == 0) {
      return;
    }
    Get.defaultDialog(
        title: "Please select PriceList",
        content: Container(
            height: 300.0, // Change as per your requirement
            width: 300.0,
            child: Column(
              children: [
                ListTile(
                  title: Text("Public"),
                  onTap: () {
                    Get.back();
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pricelistMaster.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(pricelistMaster[index].name!),
                      onTap: () {
                        widget.order.pricelist = pricelistMaster[index];
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async {
        // Pass data back when user presses back button
         widget.fromlead?  null: widget.onBack!=null?widget.onBack!():null;
        return true; // Return true to allow back navigation
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: _buildBodyContent(),
        ),
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      toolbarHeight: 80,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SnapPeUI().appBarText("Create New Quotation", kBigFontSize),
        SnapPeUI().appBarSubText(
            "Customer Number : ${widget.order.customerNumber}",
            kMediumFontSize),
      ]),
    );
  }

  _buildBodyContent() {
    final serachController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          InkWell(
              onTap: () {
                _addItemWidget();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.add), Text("Add Item")],
              )),
          _searchItemsWidget(serachController),
          _buildItemsListVIew(),
        ],
      ),
    );
  }

  _addItemWidget() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItem();
      },
    );
  }

  _searchItemsWidget(TextEditingController serachController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Search Items",
              style: TextStyle(
                  fontSize: kBigFontSize, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TypeAheadField(
              suggestionsBoxController: sugControllerBox,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: serachController,
                  decoration: InputDecoration(labelText: "Search Items")),
              suggestionsCallback: (pattern) async{ 
                
                print(pattern);
             return   await SnapPeNetworks()
                  .itemsSuggestionsCallback(
                      pattern, widget.order.pricelist?.code);},
              itemBuilder: (context, Sku itemData) {
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    child: itemData.images == null ||
                            itemData.images!.length == 0
                        ? Image.asset("assets/images/noImage.png")
                        : Image.network(
                            "${(itemData.images!.length != 0 && itemData.images != null) ? itemData.images![0].imageUrl : ""}"),
                  ),
                  title: Text("${itemData.displayName}"),
                  trailing: TextButton(
                    child: Text("Add to cart"),
                    onPressed: () {
                      print("selected Product - ${itemData.id} ");

                  
                      bool alreadyAdded = false;

                      for (int i = 0; i < skuList.length; i++) {
                        print("checking ${skuList[i].id}   -  ${itemData.id}");
                        if (skuList[i].id == itemData.id) {
                          alreadyAdded = true;
                        }
                      }

                      if (alreadyAdded) {
                        Fluttertoast.showToast(
                            msg: "Already Added.",
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red);
                        return;
                      }else{
    widget.order.orderAmount =
                          widget.order.orderAmount! + itemData.sellingPrice!;
                      widget.order.originalAmount =
                          widget.order.originalAmount! + itemData.sellingPrice!;
                      }

                      print(alreadyAdded);
                      setState(() {
                        sugControllerBox.close();
                        itemData.quantity = 1;
                        print(
                            "sell price - ${itemData.sellingPrice}  totalAmount - ${itemData.totalAmount}");
                        itemData.totalAmount = itemData.sellingPrice;
                        itemData.size = "0";
                        itemData.skuId = itemData.id;
                        itemData.gst = 0;

                        skuList.add(itemData);
                      });
                    },
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                print(suggestion);
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildItemsListVIew() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(4),
          color: Colors.white,
          height: 250,
          child: ListView.builder(
            itemCount: skuList.length,
            itemBuilder: (context, index) {
              return _item(skuList[index]);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Valid Till  :  '),
                  SizedBox(
                      width: 160,
                      height: 40,
                      child: InkWell(
                        onTap: () async {
                          var results = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2041, 12),
                          );

                          DateFormat formatter = DateFormat('dd/MM/yyyy');
                          if (results != null) {
                            setState(() {
                              validtill.text = formatter.format(results!);

                              widget.order.validTill =
                                  results!.toIso8601String();
                            });
                          }
                          print(results);
                        },
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(color: Colors.black, fontSize: 13.0),
                          controller: validtill,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.grey.shade300,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              )),
                          enabled: false,
                          keyboardType: TextInputType.number,
                        ),
                      )),
                ],
              ),

              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Labeler(
              //       childen: SizedBox(
              //           width: 80,
              //           height: 30,
              //           child: TextFormField(
              //             decoration: InputDecoration(
              //                 border: InputBorder.none,
              //                 fillColor: Colors.grey.shade300,
              //                 filled: true),
              //             keyboardType: TextInputType.number,
              //           )),
              //       lablel: 'Delivery Charges'),
              // ),
              // Labeler(
              //     childen: SizedBox(
              //         width: 80,
              //         height: 30,
              //         child: TextFormField(
              //           decoration: InputDecoration(
              //               border: InputBorder.none,
              //               fillColor: Colors.grey.shade300,
              //               filled: true),
              //           keyboardType: TextInputType.number,
              //         )),
              //     lablel: 'Packing Charges'),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Labeler(
              //       childen: SizedBox(
              //           width: 80,
              //           height: 30,
              //           child: TextFormField(
              //             decoration: InputDecoration(
              //                 border: InputBorder.none,
              //                 fillColor: Colors.grey.shade300,
              //                 filled: true),
              //             keyboardType: TextInputType.number,
              //           )),
              //       lablel: 'Discount'),
              // ),

              // DropdownButton<int>(
              //   value: widget.order.selectedDeliveryBucketId,
              //   iconSize: 25,
              //   elevation: 16,
              //   hint: Text(
              //     "Please choose a Delivery Schedule",
              //     style: TextStyle(
              //       color: Colors.black,
              //     ),
              //   ),
              //   onChanged: (int? newValue) {
              //     setState(() {
              //       widget.order.selectedDeliveryBucketId = newValue!;
              //       //widget.order.deliveryTime =deliveryOption.
              //     });
              //   },
              //   items: deliveryOption
              //       .map<DropdownMenuItem<int>>((DeliveryOption value) {
              //     return DropdownMenuItem<int>(
              //       value: value.id,
              //       child: Text("${value.deliveryOption}"),
              //     );
              //   }).toList(),
              // ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(16),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            children: [
              // Text(
              //   "IGST : ₹${0.0}",
              //   style: TextStyle(fontSize: kMediumFontSize),
              // ),
              Text(
                "Total Amount : ₹${widget.order.orderAmount}",
                style: TextStyle(fontSize: kMediumFontSize),
              ),
              ElevatedButton(
                    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Background color
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
      // Border color
    ),),
                  onPressed: () async {
                    widget.order.orderDetails = skuList;
                    // widget.order.applicationName = "DivigoRetail";
                    // widget.order.applicationNo = "919953423108";
                    //widget.order.pinCode = 502032;
                    widget.order.status = "OK";
                    // setState(() {
                    //                       widget.order.deliveryTime=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 1, 6).toString();
                    // });
                    widget.order.selectedDeliveryBucketId =
                        (deliveryOption != null && deliveryOption.length != 0)
                            ? deliveryOption[0].id
                            : 0;

//widget.order.validTill=DateTime.now().toIso8601String();
                    widget.order.createdOn = DateTime.now().toUtc();
                    print(widget.order.selectedDeliveryBucketId);
                    if (widget.order.selectedDeliveryBucketId == null) {
                      SnapPeUI().toastWarning(
                          message: "Please Select Delivery schedule.");
                      return;
                    }
                    if (skuList.length == 0) {
                      SnapPeUI().toastWarning(
                          message: "Please Select At Least one Item.");
                      return;
                    }
                    OrderSummaryModel? model =
                        await SnapPeNetworks().createNewOrder(widget.order);
                        
                    if (model != null) {
                      Navigator.pop(context);

                widget.fromlead?      Get.to(OrderScreen(isfromlead: true,
                        tabIndex: 2,
                      )): widget.onBack!=null?widget.onBack!():null;
                    }
                  },
                  child: Text(
                    "Create Quotation",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        )
      ],
    );
  }

  _item(Sku sku) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: sku.images != null && sku.images!.isNotEmpty
            ? Image.network(sku.images![0].imageUrl ?? "")
            : Container(),
      ),
      title: Text("${sku.displayName!}"),
      subtitle: Text(
        "Price : ₹${sku.sellingPrice!}",
        style: TextStyle(color: Colors.lightGreen),
      ),
      trailing: SizedBox(
        width: 106,
        child: Row(
          children: <Widget>[
            sku.quantity != 0
                ? sku.quantity == 1
                    ? new IconButton(
                        icon: new Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(() {


                          
                          widget.order.orderAmount =
                              widget.order.orderAmount! - sku.sellingPrice!;

                          widget.order.originalAmount =
                              widget.order.originalAmount! - sku.sellingPrice!;
                          skuList.remove(sku);
                        }),
                      )
                    : new IconButton(
                        icon: new Icon(Icons.remove),
                        onPressed: () => setState(() {
                          sku.totalAmount =
                              sku.totalAmount! - sku.sellingPrice!;
                          widget.order.orderAmount =
                              widget.order.orderAmount! - sku.sellingPrice!;
                          widget.order.originalAmount =
                              widget.order.originalAmount! - sku.sellingPrice!;
                          sku.quantity = sku.quantity! - 1;
                        }),
                      )
                : new Container(),
            new Text(sku.quantity.toString()),
            new IconButton(
                icon: new Icon(Icons.add),
                onPressed: () => setState(() {
                      sku.totalAmount = sku.totalAmount! + sku.sellingPrice!;
                      widget.order.orderAmount =
                          widget.order.orderAmount! + sku.sellingPrice!;
                      widget.order.originalAmount =
                          widget.order.originalAmount! + sku.sellingPrice!;
                      sku.quantity = sku.quantity! + 1;
                    }))
          ],
        ),
      ),
    );
  }
}

class Labeler extends StatelessWidget {
  final Widget childen;
  final String lablel;
  Labeler({Key? key, required this.childen, required this.lablel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(lablel + ":     "),
        ),
        SizedBox(
          height: 20,
        ),
        childen
      ],
    );
  }
}

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdata();
  }

  setdata() async {
    try {
      var k = await SkuUnits.fetchUnits();

      setState(() {
        skuunits = k;
        print(k);
      });
    } catch (e) {
      print("-------------skuunit error$e");
    }
  }

  bool isvalidation = false;
  List<SkuUnits> skuunits = [];
  String conversionunit = "";
  SkuUnits? _takeorderby;
  SkuUnits? _selectedunit;
  String name = "";
  String mrp = "";
  String rateordiscountvalue = "";
  String mesurement = "1";
  SkuUnits? _selectedsecondaryunit;
  bool rateordiscount = false;
  TextEditingController _categorycontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.all(10),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Create Item'),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   child: Text('Cancel'),
            // ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isvalidation = true;
                });

                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isvalidation = false;
                  });
                  print(_formKey.currentState);
                  print(_categorycontroller.text);
                  if (_categorycontroller.text == "" ||
                      _categorycontroller.text == null) {
                    Fluttertoast.showToast(
                        msg: "Enter Category", gravity: ToastGravity.CENTER);
                  } else {
                    if ((_selectedsecondaryunit != null &&
                            _selectedunit != null) &&
                        _takeorderby == null) {
                      Fluttertoast.showToast(
                          msg:
                              "Take Order by is not selected, so Basic units is being selected");
                      _takeorderby = _selectedunit!;
                    }
                    print("validation succesful");
                    var k = await postIteam();
                    if (k == true) {
                      Fluttertoast.showToast(
                          msg: "Successfull", gravity: ToastGravity.CENTER);
                      Navigator.of(context).pop();




                    } else {
                      Fluttertoast.showToast(
                          msg: "post requesst failed",
                          gravity: ToastGravity.CENTER);
                    }
                  }
                }
              },
              child: Text('Add Item'),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: Colors.black,
                  ),

                  Text("Basic Details ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("Name *",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  SizedBox(
                      height: 60,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Item name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              // Adjust the value as needed
                              ),

                          filled: true,
                          fillColor: Colors.grey.shade200,
                          hintText: 'Enter Name',
                          // prefixIcon:Icon( Icons.person_2,color: Colors.blue.shade900,)
                        ),
                      )),

                  SizedBox(
                    height: 7,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("Category*",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: TypeAheadField<String>(
                        noItemsFoundBuilder: (context) {
                          return Text("No Types Found.");
                        },
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: _categorycontroller,
                            decoration: InputDecoration(
                              labelText: "Search Types",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              hintText: 'Enter Name',
                            )),
                        suggestionsCallback: (pattern) async {
                          return fetchCategoryTypes(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            _categorycontroller.text = suggestion;
                          });

                          print('Selected suggestion: $suggestion');
                        },
                      ),
                    ),
                  ),
                  (isvalidation == true && _categorycontroller.text == "")
                      ? Text(
                          "Enter the caetgory",
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        )
                      : Container(),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("Basic Unit*",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  DropDownTextField(
                    textFieldDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    clearOption: false,
                    dropDownList: skuunits.map((skuunit) {
                      return DropDownValueModel(
                          value: skuunit.id, name: skuunit.name);
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Basic Unit';
                      }
                      return null;
                    },
                    initialValue: "Customer Actions",
                    onChanged: (p0) {
                      setState(() {
                        _selectedunit = SkuUnits(id: p0.value, name: p0.name);
                      });
                    },
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  // Text(skuunits.toString()) ,
                  Text(
                    'MRP*',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 6),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Mrp';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        mrp = value;
                      });
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Radio(
                        value: false,
                        groupValue: rateordiscount,
                        onChanged: (bool? value) {
                          setState(() {
                            rateordiscount = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Rate *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Radio(
                        value: true,
                        groupValue: rateordiscount,
                        onChanged: (bool? value) {
                          setState(() {
                            rateordiscount = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Discount %*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Rate or Discount';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        rateordiscountvalue = value;
                      });
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        labelText: 'Enter Discount or Rate',
                        hintText: 'e.g., 15',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [],
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Text(
                      "Units  ($mesurement ${_selectedsecondaryunit != null ? ": ${_selectedsecondaryunit!.name} ( $conversionunit X $mesurement ${_selectedsecondaryunit!.name}  ) " : ""})",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text("Measurement*",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  SizedBox(
                      height: 50,
                      child: TextFormField(
                        initialValue: mesurement,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            mesurement = "$value";
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              // Adjust the value as needed
                              ),

                          filled: true,
                          fillColor: Colors.grey.shade200,
                          hintText: 'Measurement',
                          // prefixIcon:Icon( Icons.person_2,color: Colors.blue.shade900,)
                        ),
                      )),
                  Card(
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text("Add Secondary Unit"),
                      children: [
                        ListTile(
                          title: Text("Conversion Rate"),
                          subtitle: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    conversionunit = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      // Adjust the value as needed
                                      ),

                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  hintText: 'Conversion Rate',
                                  // prefixIcon:Icon( Icons.person_2,color: Colors.blue.shade900,)
                                ),
                              )),
                        ),
                        ListTile(
                          title: Text("Secondary Unit"),
                          subtitle: SizedBox(
                            height: 50,
                            child: DropDownTextField(
                              textFieldDecoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                              //clearOption: false,
                              dropDownList: skuunits.map((skuunit) {
                                return DropDownValueModel(
                                    value: skuunit.id, name: skuunit.name);
                              }).toList(),

                              onChanged: (p0) {
                                setState(() {
                                  if (p0.runtimeType != String) {
                                    _selectedsecondaryunit =
                                        SkuUnits(id: p0.value, name: p0.name);
                                  } else {
                                    print("cclearcalles");
                                    setState(() {
                                      _selectedsecondaryunit = null;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        ((_selectedunit != null &&
                                    _selectedsecondaryunit != null) &&
                                (_selectedsecondaryunit!.id !=
                                    _selectedunit!.id))
                            ? ListTile(
                                title: Text("Take Order By"),
                                subtitle: SizedBox(
                                  height: 50,
                                  child: DropDownTextField(
                                    textFieldDecoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                    ),
                                    clearOption: false,
                                    dropDownList: [
                                      DropDownValueModel(
                                          name: _selectedsecondaryunit!.name,
                                          value: _selectedsecondaryunit!.id),
                                      DropDownValueModel(
                                          name: _selectedunit!.name,
                                          value: _selectedunit!.id)
                                    ],
                                    onChanged: (p0) {
                                      setState(() {
                                        _takeorderby = SkuUnits(
                                            id: p0.value, name: p0.name);
                                      });
                                    },
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),

                  //ElevatedButton(onPressed: (){}, child: Text("Add Secondary Unit",))
                ],
              ),
            ),
          ),
        ));
  }

  Future<bool> postIteam() async {
    Map<String, dynamic> json = {
      "id": null,
      "thirdPartySku": null,
      "brand": null,
      "displayName": name,
      "alias": null,
      "type": _categorycontroller.text,
      "availability": true,
      "mrp": mrp,
      "discountPercent": rateordiscount == true ? null : rateordiscountvalue,
      "sellingPrice": rateordiscount == true
          ? (int.tryParse(mrp) ??
              0 -
                  (int.tryParse(mrp) ??
                      0 * (int.tryParse(rateordiscountvalue) ?? 0) / 100))
          : int.tryParse(rateordiscountvalue),
      "imageUrl": null,
      "unit": _selectedunit!.toJson(),
      "secondaryUnit": _selectedsecondaryunit == null
          ? null
          : _selectedsecondaryunit!.toJson(),
      "defaultUnit": _takeorderby == null
          ? (_selectedsecondaryunit != null && _selectedunit != null)
              ? _selectedsecondaryunit!.toJson()
              : null
          : _takeorderby!.toJson(),
      "secondaryConversionRate": conversionunit,
      "remarks": null,
      "quantity": 0,
      "measurement":
          mesurement == "" ? int.tryParse("1") : int.tryParse(mesurement),
      "description": null,
      "images": [],
      "pricelistId": null,
      "skuId": null,
      "moq": 1,
      "width": null,
      "height": null,
      "length": null,
      "weight": null,
      "gst": null,
      "includedInMrp": true,
      "isVisible": true,
      "showMrp": true,
      "isEditable": false,
      "trackInventory": false,
      "availableStock": 0,
      "priceSlabs": null,
      "purchasePrice": null,
      "forItems": null,
      "forUnit": {"id": null, "name": null},
      "complimentaryItems": null,
      "complimentaryUnit": {"id": null, "name": null},
      "appliedSchemes": null,
      "customColumns": [
        {
          "id": 13139499,
          "clientGroupId": 896360,
          "columnName": "custom_column_1",
          "displayName": "hello_world",
          "type": "sku",
          "optionValues": "",
          "isActive": true,
          "value": null,
          "optionValueArray": null,
          "dataType": "Text",
          "sequenceNumber": 1,
          "multiSelectOptions": null,
          "multiSelectedOption": null
        }
      ],
      "isMasterSku": false,
      "rootCategories": [],
    };

    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final String baseUrl =
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/skus';
      final response = await NetworkHelper().request(
          RequestType.post, Uri.parse(baseUrl),
          requestBody: jsonEncode(json));

      if (response!.statusCode == 200) {
        print("///////////${response.body}");
        Fluttertoast.showToast(msg: "Item Added");
        return true;
      } else {
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res.containsKey("messages")) {
          if (res["messages"].length != 0) {
            res["messages"].contains("109")
                ? Fluttertoast.showToast(
                    msg:
                        "The Item Your trying to create is already present try with another name",
                    textColor: Colors.blue,
                    gravity: ToastGravity.CENTER)
                : Fluttertoast.showToast(
                    msg: "Some thing went wrong plz try agian later");
            return false;
          }
        }
        throw Exception('Failed to fetch category types');
      }
    } catch (e) {
      throw Exception('Failed to fetch category types: $e');
    }
  }
}

Future<List<String>> fetchCategoryTypes(String keyword) async {
  String clientGroupName =
      await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
  try {
    final String baseUrl =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/skus-types?keyword=$keyword';
    final response =
        await NetworkHelper().request(RequestType.get, Uri.parse(baseUrl));

    if (response!.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> skuTypes = jsonData['skuTypes'];

      List<String> categoryTypes =
          skuTypes.map((type) => type.toString()).toList();

      return categoryTypes;
    } else {
      throw Exception('Failed to fetch category types');
    }
  } catch (e) {
    throw Exception('Failed to fetch category types: $e');
  }
}
