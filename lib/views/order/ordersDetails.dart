import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/views/order/orderScreen.dart';
import 'package:leads_manager/views/order/selectitemswidget.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

import '../../Controller/orderAction_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_catalogue.dart';
import '../../models/model_order_summary.dart';
import '../../models/model_orders.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/styleConstants.dart';

class OrderDetailsScreen extends StatefulWidget {
  final bool isquotation;
  final int? orderId;
  final bool isPendingOrder;
  final Order order;
  final VoidCallback onBack;
  final bool? isfromlead;
  const OrderDetailsScreen(
      {Key? key,
      required this.orderId,
      required this.isPendingOrder,
      required this.order,
      required this.onBack,
      required this.isquotation,
      this.isfromlead = false})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? order;
  List<bool> isEditingList = [];
  List<Sku>? orderPrevious;
  bool istable=false;
  @override
  void initState() {
    super.initState();
    loadData();
    _controller.addListener(() => setState(() {}));
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  void loadData() async {
    var response = await SnapPeNetworks().getOrderDetail(
        widget.orderId ?? 0, widget.isPendingOrder, widget.isquotation);

    setState(() {
      // List<OrderSummaryModel> osList = List<OrderSummaryModel>.from(
      //   orderSummaryArray.map((x) => OrderSummaryModel.fromJson(x)));
      order = orderFromJson(response);
      if (widget.isquotation) {
        DateFormat format = DateFormat('dd:MM:yyyy');

        // validtillcontroller.text=order?.deliveryTime??"";

        validtillcontroller.text = order?.validTill != null
            ? format.format(DateTime.parse((order?.validTill ?? "")))
            : order?.deliveryTime ?? '';
        order?.validTill != null
            ? validTillCatcher = DateTime.parse((order?.validTill)!)
            : validTillCatcher = format.parse((order?.deliveryTime) ?? '');
        for (var sku in order?.orderDetails ?? []) {
          sku.discountType = "lumpsum";
        }
      }
    });

    order?.orderDetails?.forEach((e) {
      if (e.discountValue != null && e.totalAmount != null && e.mrp != null) {
        e.totalAmount = (e.quantity ?? 0) * (e.mrp ?? 0) -
            (e.quantity ?? 0) * (e.discountValue ?? 0);
        e.discountPercent =
            calculateDiscountPercentage(e.mrp ?? 0, e.discountValue ?? 0);
        e.sellingPrice = (e.mrp ?? 0) - (e.discountValue ?? 0);
        e.igst = calculateGst(e.totalAmount ?? 0.0, e.gst ?? 0.0);
        getOrderTotalValue();
      }
    });
    if (order != null && order!.orderDetails != null) {
      isEditingList = List<bool>.filled(order!.orderDetails!.length, false);
    }
  }

  DateTime? validTillCatcher;
  TextEditingController validtillcontroller = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();

        return true;
      },
      child: Scaffold(
        floatingActionButton:
widget.isquotation?FloatingActionButton.extended(
      label: Text("${istable?"Card View":"Table View"}"),
      icon:  Icon(
        Icons.article,
        color: Colors.white,
      ),
      onPressed: (){
  setState(() {
    istable=!istable;
  });
}
    )  :null,
        appBar: buildAppBar(),
        backgroundColor: Colors.grey[200],
        body: buildBodyContent(),
      ),
    );
  }

  getOrderTotalValue() {
    
    setState(() {
      order?.orderAmount = order!.orderDetails!.fold<double>(
            0, // Initial value for the sum
            (previousValue, element) =>
                previousValue + (element.totalAmount ?? 0),
          ) -
          (order?.discountValue ?? 0) +
          (order?.deliveryCharges ?? 0) +
          (order!.orderDetails!.fold<double>(0,
              (previousValue, element) => previousValue + (element.igst ?? 0)));

      print(order?.discount);
      print(order?.orderAmount);
      print("${(order?.orderAmount ?? 0) - (order?.discountValue ?? 0)}");
      print(order?.igst);
    });
  }

  buildBodyContent() {
    if (order == null) {
      return Center(
        child: CupertinoActivityIndicator(radius: 20),
      );
    }
    return ListView(children: <Widget>[
      widget.isquotation ? istable?quotationDetailsTable(): Column(children: [quotationDetailsCard(),quotationDetailsTotal()],)   : ordersDetailsTable(),
      
//       Center(child: ElevatedButton(onPressed: (){
// _showSearchAndAddItemDialog(context);

//       }, child: Text("Add Item")),),
      customerDetailsCard(),
      !widget.isquotation ? deliveryScheduleCard() : Container(),
      //  widget.isquotation? MarkdownToolbar(
      //        width: 70,
      //           height: 50,
      //           useIncludedTextField: true,
      //   controller: _controller,
      //           focusNode: _focusNode,
      //         ):Container(),
      widget.isquotation ? quotationActionCard() : actionCard()
    ]);
  }

  _showSearchAndAddItemDialog(BuildContext context) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return SearchAndAddItemDialog(
          order: order!,
          skuList: [],
          onItemAdded: (newitem) async {
            var itemExists = false;
            setState(() {
              if (order != null && order!.orderDetails != null) {
                for (Sku item in order!.orderDetails!) {
                  if (item.id == newitem.id) {
                    itemExists = true;
                    item.quantity = item.quantity + 1;
                    item.totalAmount = item.sellingPrice! * item.quantity;
                    break;
                  }
                }
                if (!itemExists) {
                  order?.orderDetails?.add(newitem);
                }
              }
            });

            Map<String, dynamic>? k = order?.toJson();

            if (k != null && order?.id != null) {
              //  print( order?.toJson());

              prints(order?.toJson());

              var c = await checkQuotation(k);
              setState(() {
                order = Order.fromJson(c);
              });
            }
          },
        );
      },
    );
  }

  customerDetailsCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Name : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.customerName ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Address : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.flatNo ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'City & Pincode : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${(order?.city) ?? ""} , ${order?.pinCode ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  deliveryScheduleCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Schedule',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Delivery Date : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.deliveryTime ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  double calculateDiscountPercentage(double totalValue, double discountValue) {
    if (totalValue <= 0) {
      Fluttertoast.showToast(msg: "Enter total Total value grater then 0 ");
    }
    double discountPercentage = (discountValue / totalValue) * 100;
    return discountPercentage;
  }

  quotationActionCard() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Card(
        child: Container(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Valid Till  : "),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        height: 40,
                        child: TextFormField(
                          readOnly: true,
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: validTillCatcher != null
                                  ? validTillCatcher!
                                  : DateTime(2019, 1),
                              firstDate: validTillCatcher != null
                                  ? validTillCatcher!
                                  : DateTime(2019, 1),
                              lastDate: DateTime(2041, 12),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                validtillcontroller.text =
                                    DateFormat('dd:MM:yyyy')
                                        .format(selectedDate);
                                order?.validTill =
                                    selectedDate.toIso8601String();
                              });
                            }
                          },
                          controller: validtillcontroller,
                          decoration: InputDecoration(
                            labelText: 'Valid Till',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

// Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                       onPressed: () async {
//                           order?.orderDetails?.map((e) => e.includedInMrp=false);
//                         Map<String, dynamic>? k = order?.toJson();

//                         if (k != null && order?.id != null) {
//                           //  print( order?.toJson());

//                           prints(order?.toJson());

//                         var c = await checkQuotation(k);
// setState(() {
//   order= Order.fromJson( c);
// });
//                         }
//                       },
//                       child: Text("check")),
//                 ),

             istable?   Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        order?.orderDetails
                            ?.map((e) => e.includedInMrp = false);
                        Map<String, dynamic>? k = order?.toJson();

                        if (k != null && order?.id != null) {
                          //  print( order?.toJson());

                          prints(order?.toJson());

                          //var c = await checkQuotation(k);

                          var res =
                              await updateQuotation(k, (order?.id.toString())!);

                          if (res) {
                            widget.onBack != null ? widget.onBack() : null;
                            Navigator.canPop(context)
                                ? Navigator.pop(context)
                                : null;
                            widget.isfromlead!
                                ? Get.to(OrderScreen(
                                    tabIndex: 2,
                                  ))
                                : null;
                          }
                        }
                      },
                      child: Text("Update")),
                ):Container(),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: 200),
                //   child: SelectableText ("${order?.toJson()}"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  actionCard() {
    OrderActionController actionController = new OrderActionController();
    final paymentStatusItems = [
      'Select',
      'PENDING',
      'NOT_REQUIRED',
      'COMPLETED',
      'PARTIAL',
      'CANCELLED',
      'FULL_REFUND',
      'PARTIAL_REFUND'
    ];
    final orderStatusItems = ['Select', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Action',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Order Status : ',
                        style: TextStyle(
                            fontSize: kMediumFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),

                        // dropdown below..
                        child: Obx(() => DropdownButton<String>(
                              value: actionController.selectedOrderStatus.value,
                              onChanged: (x) {
                                actionController.setOrderStatus(x!);
                              },
                              items: orderStatusItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                  .toList(),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              underline: SizedBox(),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 55,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Payment Status : ',
                        style: TextStyle(
                            fontSize: kMediumFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),

                        // dropdown below..
                        child: Obx(() => DropdownButton<String>(
                              value:
                                  actionController.selectedPaymentStatus.value,
                              onChanged: (x) {
                                actionController.setPaymentStatus(x!);
                              },
                              items: paymentStatusItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                  .toList(),

                              // add extra sugar..
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              underline: SizedBox(),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: () {
                  SnapPeNetworks().updateOrder(
                      actionController.selectedOrderStatus.value == "Select"
                          ? null
                          : actionController.selectedOrderStatus.value,
                      actionController.selectedPaymentStatus.value == "Select"
                          ? null
                          : actionController.selectedPaymentStatus.value,
                      widget.order);
                  Navigator.pop(context);
                },
                child: Text("Update")),
            ElevatedButton(
                onPressed: () {
                  SnapPeNetworks().getQRCode(order!);
                },
                child: Text("Show QR Code")),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  buildAppBar() {
    var id = "";
    var orderDate = "";
    if (order != null) {
      id = "${order?.id}";

      DateTime tempDate = DateTime.parse("${order?.createdOn}");
      orderDate = DateFormat.yMMMMd().format(tempDate);
    }
    return AppBar(
      toolbarHeight: 80,
      actions: [
        IconButton(
            onPressed: () async {
              var url = "tel:${order?.customerNumber! ?? ""}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: SizedBox(
                 height: 30,
              width: 50,
              child: Image.asset("assets/icon/callIcon.png"))),
        IconButton(
            onPressed: () async {
              var url =
                  "https://wa.me/${order?.customerNumber!}?text=Hello ${order?.customerName!}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: SizedBox(
              height: 30,
              width: 50,
              child: Image.asset("assets/icon/whatsappIcon.png")))
      ],
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SnapPeUI().appBarText("Order #$id", kBigFontSize),
        SnapPeUI().appBarSubText("$orderDate", kSmallFontSize),
      ]),
    );
  }

  ordersDetailsTable() {
    List<DataRow> rowList = order!.orderDetails!
        .map(
          (e) => DataRow(cells: [
            DataCell(SizedBox(width: 30, height: 30, child: Text("")
                // e.images!.isEmpty
                //     ? Text("")
                //     : Image.network("${e.images![0].imageUrl}"),
                )),
            DataCell(SizedBox(
                width: 150,
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  direction: Axis.vertical,
                  children: [Flexible(child: Text("${e.displayName ?? ""}"))],
                ))),
            DataCell(Text("${e.measurement ?? ""}")),
            DataCell(Text("${e.unit?.name ?? ""}")),
            DataCell(Text("${e.quantity ?? "0"}")),
            DataCell(Text("₹ ${e.mrp ?? "0.0"}")),
            DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),
          ]),
        )
        .toList();

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(+) Delivery Charges")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
    ]));

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(-) Discount")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text(
          "- ₹ ${order?.promotion == null ? 0.0 : (order?.promotion?.maximumDiscount?.toStringAsFixed(1)) ?? 0.0}")),
    ]));

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(
          Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text(
        "₹ ${order?.orderAmount ?? "0.0"}",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    ]));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all<Color>(Colors.black),
            dataRowHeight: 50,
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text("#")),
              DataColumn(
                  label: Text('Items',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Measurement',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Unit(s)',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Qty',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Price',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Total',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
            ],
            rows: rowList,
          ),
        ),
      ),
    );
  }

  quotationDetailsTotal() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Order Value"),
              Text("₹ ${order?.originalAmount ??order?.orderAmount??"0" }")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("GST"),
              Text("${ order?.igst??0}")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [Text("Discount"), Text("${order?.discountValue ?? 0}")],
          ),
          Divider(
            color: Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Total Order Value"),
              Text(
                "₹ ${order?.orderAmount}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  quotationDetailsCard() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: order!.orderDetails!.length,
        itemBuilder: (context, index) {
          var e = order!.orderDetails![index];
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0), // Adjust the radius as needed
              ),
              child: ListTile(
                isThreeLine: true,
                title: Text("${e.displayName ?? ""}",style: TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (e.discountValue != 0 && e.discountValue != 0.0) ||
                            (e.discountValue != 0 && e.discountPercent != 0.0)
                        ? Row(
                            children: [
                              Text(
                                  "${e.mrp != null ? (e.mrp.toString()).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), '') : '0'}  ",
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 18,
                                    color: Colors.red,
                                  )),
                              Text("${e.sellingPrice}"),
                              Text("  Per ${1}  ${e.unit?.name ?? ""}"),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                  "${e.mrp != null ? (e.mrp.toString()).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), '') : "0"}  ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  )),
                              // Text("${e.sellingPrice}"),
                              Text(" Per ${1}  ${e.unit?.name ?? ""}"),
                            ],
                          ),
                    Text("Current Quantity:${e.quantity}")
                  ],
                ),
                trailing: Column(
                  children: [
                    Text("₹ ${e.totalAmount ?? "0.0"}"),
                  ],
                ),
              ));
        },
      ),
    );
  }

  quotationDetailsTable() {
    List<DataRow> rowList = order!.orderDetails!.asMap().entries.map((entry) {
      int index = entry.key;
      var e = entry.value;

      var k = isEditingList[index]
          ? DataRow(
              color: index % 2 == 0
                  ? MaterialStateProperty.all<Color>(Colors.white)
                  : MaterialStateProperty.all<Color>(Colors.grey),
              cells: [
                  DataCell(SizedBox(width: 30, height: 30, child: Text("")
                      // e.images!.isEmpty
                      //     ? Text("")
                      //     : Image.network("${e.images![0].imageUrl}"),
                      )),
                  DataCell(SizedBox(
                      width: 150,
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.center,
                        direction: Axis.vertical,
                        children: [
                          Flexible(child: Text("${e.displayName ?? ""}"))
                        ],
                      ))),
                  DataCell(Text("${e.measurement ?? ""}")),
                  DataCell(Text("${e.unit?.name ?? ""}")),
                  DataCell(Customtextfeild1(
                    k: (p0) {
                      print("from quatity$p0");
                      e.quantity = int.tryParse(p0) ?? 0;
                      if (e.discountValue == null) e.discountValue = 0;
                      print(
                          " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
                      if (e.discountValue != null &&
                          e.totalAmount != null &&
                          e.discountValue != null &&
                          e.mrp != null) {
                        setState(() {
                          e.totalAmount =
                              e.quantity * e.mrp - e.quantity * e.discountValue;
                          e.discountPercent = calculateDiscountPercentage(
                              e.mrp ?? 0, e.discountValue ?? 0);
                          e.sellingPrice = e.mrp! - e.discountValue!;
                          // e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
                          // getOrderTotalValue();
                        });
                      }
                      print(e.quantity);
                    },
                    intialvlaue:
                        "${removeRightFromPeriod(e.quantity.toString()) ?? "0"}",
                  )),

                  DataCell(Customtextfeild1(
                    k: (p0) {
                      setState(() {
                        e.discountValue = double.tryParse(p0) ?? 0;
                        if (e.discountValue == null) e.discountValue = 0;
                        print(
                            " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
                        if (e.discountValue != null &&
                            e.totalAmount != null &&
                            e.discountValue != null &&
                            e.mrp != null) {
                          e.totalAmount =
                              e.quantity * e.mrp - e.quantity * e.discountValue;
                          e.discountPercent = calculateDiscountPercentage(
                              e.mrp ?? 0, e.discountValue ?? 0);
                          e.sellingPrice = e.mrp! - e.discountValue!;
                        }
                        // e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
                        //                 print("discountvalu${e.discountValue}");
                        //                 print("discountpercent${e.discountPercent}");
                        //                 print("discountpercent${e.discountType}");
                        //                 getOrderTotalValue();
                      });
                    },
                    intialvlaue: "${e.discountValue ?? "0"}",
                  )),

                  DataCell(Customtextfeild1(
                    k: (p0) {
                      setState(() {
                        e.mrp = double.tryParse(p0) ?? 0;
                        if (e.discountValue == null) e.discountValue = 0;
                        print(
                            " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
                        if (e.discountValue != null &&
                            e.totalAmount != null &&
                            e.discountValue != null) {
                          e.totalAmount =
                              e.quantity * e.mrp - e.quantity * e.discountValue;
                          e.sellingPrice = e.mrp! - e.discountValue!;
                          e.discountPercent = calculateDiscountPercentage(
                              e.mrp ?? 0, e.discountValue ?? 0);
                        }
                        // print(e.mrp);
                        //   e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
                        // getOrderTotalValue();
                      });
                    },
                    intialvlaue: "${e.mrp ?? "0"}",
                  )),
                  DataCell(Text("${e.sellingPrice}")),
                  DataCell(Text("₹${e.igst} (${e.gst ?? "0.0"}%)")),
                  // DataCell(Text("₹ ${e.mrp ?? "0.0"}")),
                  DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),

                  DataCell(Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              order?.orderDetails = orderPrevious;
                              isEditingList[index] = false;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                          )),
                      IconButton(
                        onPressed: () async {
                          Map<String, dynamic>? k = order?.toJson();

                          if (k != null && order?.id != null) {
                            //  print( order?.toJson());

                            prints(order?.toJson());

                            var c = await checkQuotation(k);
                            setState(() {
                              order = Order.fromJson(c);
                              isEditingList[index] = false;
                            });
                          }
                        },
                        icon: Icon(Icons.check),
                      ),
                    ],
                  )),
                ])
          : DataRow(
              color: index % 2 == 0
                  ? MaterialStateProperty.all<Color>(Colors.white)
                  : MaterialStateProperty.all<Color>(Colors.grey),
              cells: [
                  DataCell(SizedBox(width: 30, height: 30, child: Text("")
                      // e.images!.isEmpty
                      //     ? Text("")
                      //     : Image.network("${e.images![0].imageUrl}"),
                      )),
                  DataCell(SizedBox(
                      width: 150,
                      child: Flex(
                        mainAxisAlignment: MainAxisAlignment.center,
                        direction: Axis.vertical,
                        children: [
                          Flexible(child: Text("${e.displayName ?? ""}"))
                        ],
                      ))),
                  DataCell(Text("${e.measurement ?? ""}")),
                  DataCell(Text("${e.unit?.name ?? ""}")),
                  DataCell(Text(
                      "${removeRightFromPeriod(e.quantity.toString()) ?? "0"}")),

                  DataCell(Text("${e.discountValue ?? "0"}")),

                  DataCell(Text("${e.mrp ?? "0"}")),
                  DataCell(Text("${e.sellingPrice}")),
                  DataCell(Text("₹${e.igst} (${e.gst ?? "0.0"}%)")),
                  // DataCell(Text("₹ ${e.mrp ?? "0.0"}")),
                  DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),

                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isEditingList[index] = true;
                              orderPrevious = order?.orderDetails
                                  ?.map((e) => Sku.fromJson(e.toJson()))
                                  .toList();
                            });
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {

                                if(order?.orderDetails?.length!=1){
                                order?.orderDetails?.removeAt(index);

                                }else{
                                  Fluttertoast.showToast(msg: "You cannot Delete the Last Item Since Order needs at least one item");
                                }

if(order?.orderDetails==null || order?.orderDetails?.length==0){
order?.deliveryCharges=0.0;
order?.discountValue=0;
order?.orderAmount=0;
order?.igst=0;
}

                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  )
                ]);

      return k;
    }).toList();

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(+) Delivery Charges")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell((TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),

          isDense: true, // Reduce height
          contentPadding: EdgeInsets.symmetric(
              vertical: 8, horizontal: 8), // Adjust padding
        ),
        initialValue: "${order?.deliveryCharges ?? "0.0"}",
        keyboardType: TextInputType.number,
        onChanged: (value) async {
          setState(() {
            print(value);
            order?.deliveryCharges = double.tryParse(value);

            getOrderTotalValue();
          });
          Map<String, dynamic>? k = order?.toJson();

          if (k != null && order?.id != null) {
            //  print( order?.toJson());

            prints(order?.toJson());

            var c = await checkQuotation(k);
            setState(() {
              order = Order.fromJson(c);
            });
          }
        },
      ))),
      // DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
      DataCell(Text("")),
    ]));
    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(+) Gst")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("${order?.igst = order!.orderDetails!.fold<double>(
        0, // Initial value for the sum
        (previousValue, element) => previousValue + (element.igst ?? 0),
      )}")),
      // DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
      DataCell(Text("")),
    ]));
    rowList.add(
        DataRow(color: MaterialStateProperty.all<Color>(Colors.grey), cells: [
      DataCell(Text("")),
      DataCell(Text("(-) Discount")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (value) async {
          setState(() {
            print(value);
            order?.discountValue = int.tryParse(removeRightFromPeriod(value));
            order?.orderDetails;
            print(order?.discountValue);
            getOrderTotalValue();
          });

          Map<String, dynamic>? k = order?.toJson();

          if (k != null && order?.id != null) {
            //  print( order?.toJson());

            prints(order?.toJson());

            var c = await checkQuotation(k);
            setState(() {
              order = Order.fromJson(c);
            });
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true, // Reduce height
          contentPadding: EdgeInsets.symmetric(
              vertical: 8, horizontal: 8), // Adjust padding
        ),
        initialValue: "${order?.discountValue ?? 0}",
      )),
      // DataCell(Text(
      //     "- ₹ ${order?.promotion == null ? 0.0 : (order?.promotion?.maximumDiscount?.toStringAsFixed(1)) ?? 0.0}")),

      DataCell(Text("")),
    ]));

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(
          Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text(
        "₹ ${order?.orderAmount}",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      DataCell(Text("")),
    ]));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all<Color>(Colors.black),
            dataRowHeight: 50,
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text("#")),
              DataColumn(
                  label: Text('Items',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Measurement',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Unit(s)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Qty',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('₹ Discount',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('₹ Mrp Price',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('₹ Actual Price',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('₹ Gst',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('₹ Total',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
            ],
            rows: rowList,
          ),
        ),
      ),
    );
  }
}

String removeRightFromPeriod(String input) {
  if (input.contains('.')) {
    return input.split('.').first;
  }
  return input; // Return the original string if no period is found
}

dynamic clauclatePrice(double price, int quantity, double discount) {
  price = quantity * price - quantity * discount;
  return price;
}

class Customtextfeild1 extends StatefulWidget {
  final Function(dynamic) k;
  final String? intialvlaue;
  const Customtextfeild1({Key? key, required this.k, this.intialvlaue})
      : super(key: key);

  @override
  State<Customtextfeild1> createState() => _Customtextfeild1State();
}

class _Customtextfeild1State extends State<Customtextfeild1> {
  TextEditingController textcontroller = TextEditingController();
  @override
  void initState() {
    widget.intialvlaue != null
        ? textcontroller.text = widget.intialvlaue!
        : null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        isDense: true, // Reduce height
        contentPadding:
            EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Adjust padding
      ),
      controller: textcontroller,
      onChanged: (value) {
        print(value);
        widget.k(value);
      },
    );
  }
}

void prints(var s1) {
  String s = s1.toString();
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
}

double calculateGst(double totalAmount, double gstPercent) {
  return totalAmount * gstPercent / 100;
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:carousel_slider/utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:textfield_datepicker/textfield_datepicker.dart';
// import '../../Controller/orderAction_controller.dart';
// import '../../constants/colorsConstants.dart';
// import '../../models/model_catalogue.dart';
// import '../../models/model_order_summary.dart';
// import '../../models/model_orders.dart';
// import '../../utils/snapPeNetworks.dart';
// import '../../utils/snapPeUI.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../constants/styleConstants.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   final bool isquotation;
//   final int? orderId;
//   final bool isPendingOrder;
//   final Order order;
//   final VoidCallback onBack;
//   const OrderDetailsScreen(
//       {Key? key,
//       required this.orderId,
//       required this.isPendingOrder,
//       required this.order,
//       required this.onBack,
//       required this.isquotation})
//       : super(key: key);

//   @override
//   _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   Order? order;
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   void loadData() async {
//     var response = await SnapPeNetworks().getOrderDetail(
//         widget.orderId ?? 0, widget.isPendingOrder, widget.isquotation);

//     setState(() {
//       // List<OrderSummaryModel> osList = List<OrderSummaryModel>.from(
//       //   orderSummaryArray.map((x) => OrderSummaryModel.fromJson(x)));
//       order = orderFromJson(response);
//       if (widget.isquotation) {
//         DateFormat format = DateFormat('dd:MM:yyyy');

//         // validtillcontroller.text=order?.deliveryTime??"";

//         validtillcontroller.text = order?.validTill != null
//             ? format.format(DateTime.parse((order?.validTill ?? "")))
//             : order?.deliveryTime ?? '';
//         order?.validTill != null
//             ? validTillCatcher = DateTime.parse((order?.validTill)!)
//             : validTillCatcher = format.parse((order?.deliveryTime) ?? '');
//         for (var sku in order?.orderDetails ?? []) {
//           sku.discountType = "lumpsum";
//         }
//       }
//     });
//   }

//   DateTime? validTillCatcher;
//   TextEditingController validtillcontroller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         widget.onBack();

//         return true;
//       },
//       child: Scaffold(
//         appBar: buildAppBar(),
//         backgroundColor: Colors.grey[200],
//         body: buildBodyContent(),
//       ),
//     );
//   }

//   getOrderTotalValue() {
//     setState(() {
//       order?.orderAmount = order!.orderDetails!.fold<double>(
//             0, // Initial value for the sum
//             (previousValue, element) =>
//                 previousValue + (element.totalAmount ?? 0),
//           ) -
//           (order?.discountValue ?? 0) +
//           (order?.deliveryCharges ?? 0)+(order!.orderDetails!.fold<double>(
//             0,
//             (previousValue, element) =>
//                 previousValue + (element.igst ?? 0)));

//       print(order?.discount);
//       print(order?.orderAmount);
//       print("${(order?.orderAmount ?? 0) - (order?.discountValue ?? 0)}");
//       print(order?.igst);
//     });
//   }

//   buildBodyContent() {
//     if (order == null) {
//       return Center(
//         child: CupertinoActivityIndicator(radius: 20),
//       );
//     }
//     return ListView(children: <Widget>[
//       widget.isquotation ? quotationDetailsTable() : ordersDetailsTable(),
//       customerDetailsCard(),
//       !widget.isquotation ? deliveryScheduleCard() : Container(),
//       widget.isquotation ? quotationActionCard() : actionCard()
//     ]);
//   }

//   customerDetailsCard() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Customer Details',
//                     style: TextStyle(
//                         fontSize: kBigFontSize, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
//               child: Wrap(
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: 'Name : ',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black54),
//                     ),
//                     TextSpan(
//                       text: '${order?.customerName ?? ""}',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize, color: kLightTextColor),
//                     ),
//                   ])),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
//               child: Wrap(
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: 'Address : ',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black54),
//                     ),
//                     TextSpan(
//                       text: '${order?.flatNo ?? ""}',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize, color: kLightTextColor),
//                     ),
//                   ])),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
//               child: Wrap(
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: 'City & Pincode : ',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black54),
//                     ),
//                     TextSpan(
//                       text: '${(order?.city) ?? ""} , ${order?.pinCode ?? ""}',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize, color: kLightTextColor),
//                     ),
//                   ])),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   deliveryScheduleCard() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Delivery Schedule',
//                     style: TextStyle(
//                         fontSize: kBigFontSize, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
//               child: Wrap(
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: 'Delivery Date : ',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black54),
//                     ),
//                     TextSpan(
//                       text: '${order?.deliveryTime ?? ""}',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize, color: kLightTextColor),
//                     ),
//                   ])),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double calculateDiscountPercentage(double totalValue, double discountValue) {
//     if (totalValue <= 0) {
//       Fluttertoast.showToast(msg: "Enter total Total value grater then 0 ");
//     }
//     double discountPercentage = (discountValue / totalValue) * 100;
//     return discountPercentage;
//   }

//   quotationActionCard() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Container(
//           height: 200,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Valid Till  : "),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         width: 200,
//                         height: 40,
//                         child: TextFormField(
//                           readOnly: true,
//                           onTap: () async {
//                             DateTime? selectedDate = await showDatePicker(
//                               context: context,
//                               initialDate: validTillCatcher != null
//                                   ? validTillCatcher!
//                                   : DateTime(2019, 1),
//                               firstDate: validTillCatcher != null
//                                   ? validTillCatcher!
//                                   : DateTime(2019, 1),
//                               lastDate: DateTime(2041, 12),
//                             );
//                             if (selectedDate != null) {
//                               setState(() {
//                                 validtillcontroller.text =
//                                     DateFormat('dd:MM:yyyy')
//                                         .format(selectedDate);
//                                 order?.validTill =
//                                     selectedDate.toIso8601String();
//                               });
//                             }
//                           },
//                           controller: validtillcontroller,
//                           decoration: InputDecoration(
//                             labelText: 'Valid Till',
//                             border: OutlineInputBorder(),
//                             suffixIcon: Icon(Icons.calendar_today),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                       onPressed: () async {
//                           order?.orderDetails?.map((e) => e.includedInMrp=false);
//                         Map<String, dynamic>? k = order?.toJson();

//                         if (k != null && order?.id != null) {
//                           //  print( order?.toJson());

//                           prints(order?.toJson());

//                           //var c = await checkQuotation(k);

//                           var res =
//                               await updateQuotation(k, (order?.id.toString())!);

//                           if (res) {
//                             Navigator.canPop(context)? Navigator.pop(context): null;
//                           }
//                         }
//                       },
//                       child: Text("Update")),
//                 ),

//                 // Padding(
//                 //   padding: const EdgeInsets.only(bottom: 200),
//                 //   child: SelectableText ("${order?.toJson()}"),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   actionCard() {
//     OrderActionController actionController = new OrderActionController();
//     final paymentStatusItems = [
//       'Select',
//       'PENDING',
//       'NOT_REQUIRED',
//       'COMPLETED',
//       'PARTIAL',
//       'CANCELLED',
//       'FULL_REFUND',
//       'PARTIAL_REFUND'
//     ];
//     final orderStatusItems = ['Select', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Action',
//                     style: TextStyle(
//                         fontSize: kBigFontSize, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
//               child: Wrap(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Order Status : ',
//                         style: TextStyle(
//                             fontSize: kMediumFontSize,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black54),
//                       ),
//                       Container(
//                         padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10)),

//                         // dropdown below..
//                         child: Obx(() => DropdownButton<String>(
//                               value: actionController.selectedOrderStatus.value,
//                               onChanged: (x) {
//                                 actionController.setOrderStatus(x!);
//                               },
//                               items: orderStatusItems
//                                   .map<DropdownMenuItem<String>>(
//                                       (String value) =>
//                                           DropdownMenuItem<String>(
//                                             value: value,
//                                             child: Text(value),
//                                           ))
//                                   .toList(),
//                               icon: Icon(Icons.arrow_drop_down),
//                               iconSize: 32,
//                               underline: SizedBox(),
//                             )),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 55,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Payment Status : ',
//                         style: TextStyle(
//                             fontSize: kMediumFontSize,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black54),
//                       ),
//                       Container(
//                         padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10)),

//                         // dropdown below..
//                         child: Obx(() => DropdownButton<String>(
//                               value:
//                                   actionController.selectedPaymentStatus.value,
//                               onChanged: (x) {
//                                 actionController.setPaymentStatus(x!);
//                               },
//                               items: paymentStatusItems
//                                   .map<DropdownMenuItem<String>>(
//                                       (String value) =>
//                                           DropdownMenuItem<String>(
//                                             value: value,
//                                             child: Text(value),
//                                           ))
//                                   .toList(),

//                               // add extra sugar..
//                               icon: Icon(Icons.arrow_drop_down),
//                               iconSize: 32,
//                               underline: SizedBox(),
//                             )),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   SnapPeNetworks().updateOrder(
//                       actionController.selectedOrderStatus.value == "Select"
//                           ? null
//                           : actionController.selectedOrderStatus.value,
//                       actionController.selectedPaymentStatus.value == "Select"
//                           ? null
//                           : actionController.selectedPaymentStatus.value,
//                       widget.order);
//                   Navigator.pop(context);
//                 },
//                 child: Text("Update")),
//             ElevatedButton(
//                 onPressed: () {
//                   SnapPeNetworks().getQRCode(order!);
//                 },
//                 child: Text("Show QR Code")),
//             SizedBox(
//               height: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   buildAppBar() {
//     var id = "";
//     var orderDate = "";
//     if (order != null) {
//       id = "${order?.id}";

//       DateTime tempDate = DateTime.parse("${order?.createdOn}");
//       orderDate = DateFormat().format(tempDate);
//     }
//     return AppBar(
//       toolbarHeight: 80,
//       actions: [
//         IconButton(
//             onPressed: () async {
//               var url = "tel:${order?.customerNumber! ?? ""}";
//               if (await canLaunch(url)) {
//                 await launch(url);
//               } else {
//                 throw 'Could not launch $url';
//               }
//             },
//             icon: Image.asset("assets/icon/callIcon.png")),
//         IconButton(
//             onPressed: () async {
//               var url =
//                   "https://wa.me/${order?.customerNumber!}?text=Hello ${order?.customerName!}";
//               if (await canLaunch(url)) {
//                 await launch(url);
//               } else {
//                 throw 'Could not launch $url';
//               }
//             },
//             icon: Image.asset("assets/icon/whatsappIcon.png"))
//       ],
//       title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         SnapPeUI().appBarText("Order #$id", kBigFontSize),
//         SnapPeUI().appBarSubText("$orderDate", kSmallFontSize),
//       ]),
//     );
//   }

//   ordersDetailsTable() {
//     List<DataRow> rowList = order!.orderDetails!
//         .map(
//           (e) => DataRow(cells: [
//             DataCell(SizedBox(width: 30, height: 30, child: Text("")
//                 // e.images!.isEmpty
//                 //     ? Text("")
//                 //     : Image.network("${e.images![0].imageUrl}"),
//                 )),
//             DataCell(SizedBox(
//                 width: 150,
//                 child: Flex(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   direction: Axis.vertical,
//                   children: [Flexible(child: Text("${e.displayName ?? ""}"))],
//                 ))),
//             DataCell(Text("${e.measurement ?? ""}")),
//             DataCell(Text("${e.unit?.name ?? ""}")),
//             DataCell(Text("${e.quantity ?? "0"}")),
//             DataCell(Text("₹ ${e.mrp ?? "0.0"}")),
//             DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),
//           ]),
//         )
//         .toList();

//     rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(Text("(+) Delivery Charges")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
//     ]));

//     rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(Text("(-) Discount")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text(
//           "- ₹ ${order?.promotion == null ? 0.0 : (order?.promotion?.maximumDiscount?.toStringAsFixed(1)) ?? 0.0}")),
//     ]));

//     rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(
//           Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold))),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text(
//         "₹ ${order?.orderAmount ?? "0.0"}",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       )),
//     ]));

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all<Color>(Colors.black),
//             dataRowHeight: 50,
//             columnSpacing: 20,
//             columns: [
//               DataColumn(label: Text("#")),
//               DataColumn(
//                   label: Text('Items',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Measurement',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Unit(s)',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Qty',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Price',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Total',
//                       style: TextStyle(
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//             ],
//             rows: rowList,
//           ),
//         ),
//       ),
//     );
//   }

//   quotationDetailsTable() {
//     List<DataRow> rowList = order!.orderDetails!.asMap().entries.map((entry) {
//       int index = entry.key;
//       var e = entry.value;
//       return DataRow(
//           color: index % 2 == 0
//               ? MaterialStateProperty.all<Color>(Colors.white)
//               : MaterialStateProperty.all<Color>(Colors.grey),
//           cells: [
//             DataCell(SizedBox(width: 30, height: 30, child: Text("")
//                 // e.images!.isEmpty
//                 //     ? Text("")
//                 //     : Image.network("${e.images![0].imageUrl}"),
//                 )),
//             DataCell(SizedBox(
//                 width: 150,
//                 child: Flex(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   direction: Axis.vertical,
//                   children: [Flexible(child: Text("${e.displayName ?? ""}"))],
//                 ))),
//             DataCell(Text("${e.measurement ?? ""}")),
//             DataCell(Text("${e.unit?.name ?? ""}")),
//             DataCell(Customtextfeild1(
//               k: (p0) {
//                 print("from quatity$p0");
//                 e.quantity = int.tryParse(p0) ?? 0;
//                 if (e.discountValue == null) e.discountValue = 0;
//                 print(
//                     " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
//                 if (e.discountValue != null &&
//                     e.totalAmount != null &&
//                     e.discountValue != null &&
//                     e.mrp != null) {
//                   setState(() {
//                     e.totalAmount =
//                         e.quantity * e.mrp - e.quantity * e.discountValue;
//                     e.discountPercent = calculateDiscountPercentage(
//                         e.mrp ?? 0, e.discountValue ?? 0);
//                     e.sellingPrice = e.mrp! - e.discountValue!;
//                     e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
//                     getOrderTotalValue();
//                   });
//                 }
//                 print(e.quantity);
//               },
//               intialvlaue:
//                   "${removeRightFromPeriod(e.quantity.toString()) ?? "0"}",
//             )),

//             DataCell(Customtextfeild1(
//               k: (p0) {
//                 setState(() {
//                   e.discountValue = double.tryParse(p0) ?? 0;
//                   if (e.discountValue == null) e.discountValue = 0;
//                   print(
//                       " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
//                   if (e.discountValue != null &&
//                       e.totalAmount != null &&
//                       e.discountValue != null &&
//                       e.mrp != null) {
//                     e.totalAmount =
//                         e.quantity * e.mrp - e.quantity * e.discountValue;
//                     e.discountPercent = calculateDiscountPercentage(
//                         e.mrp ?? 0, e.discountValue ?? 0);
//                     e.sellingPrice = e.mrp! - e.discountValue!;
//                   }
//   e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
//                   print("discountvalu${e.discountValue}");
//                   print("discountpercent${e.discountPercent}");
//                   print("discountpercent${e.discountType}");
//                   getOrderTotalValue();
//                 });
//               },
//               intialvlaue: "${e.discountValue ?? "0"}",
//             )),

//             DataCell(Customtextfeild1(
//               k: (p0) {
//                 setState(() {
//                   e.mrp = double.tryParse(p0) ?? 0;
//                   if (e.discountValue == null) e.discountValue = 0;
//                   print(
//                       " ${e.discountValue} , ${e.totalAmount}, ${e.discountValue},${e.mrp}");
//                   if (e.discountValue != null &&
//                       e.totalAmount != null &&
//                       e.discountValue != null) {
//                     e.totalAmount =
//                         e.quantity * e.mrp - e.quantity * e.discountValue;
//                     e.sellingPrice = e.mrp! - e.discountValue!;
//                     e.discountPercent = calculateDiscountPercentage(
//                         e.mrp ?? 0, e.discountValue ?? 0);
//                   }
//                   print(e.mrp);
//                     e.igst=calculateGst(e.totalAmount??0.0, e.gst??0.0);
//                   getOrderTotalValue();

//                 });
//               },
//               intialvlaue: "${e.mrp ?? "0"}",
//             )),
//             DataCell(Text("${e.sellingPrice}")),
//             DataCell(Text("₹${e.quantity* e.igst} (${e.gst ?? "0.0"}%)")),
//             // DataCell(Text("₹ ${e.mrp ?? "0.0"}")),
//             DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),
//           ]);
//     }).toList();

//     rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(Text("(+) Delivery Charges")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell((TextFormField(
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),

//           isDense: true, // Reduce height
//           contentPadding: EdgeInsets.symmetric(
//               vertical: 8, horizontal: 8), // Adjust padding
//         ),
//         initialValue: "${order?.deliveryCharges ?? "0.0"}",
//         keyboardType: TextInputType.number,
//         onChanged: (value) {
//           setState(() {
//             print(value);
//             order?.deliveryCharges = double.tryParse(value);

//             getOrderTotalValue();
//           });
//         },
//       )))
//       // DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
//     ]));
//  rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(Text("(+) Gst")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("${ order?.igst = order!.orderDetails!.fold<double>(
//             0, // Initial value for the sum
//             (previousValue, element) =>
//                 previousValue + (element.igst ?? 0),
//           )}"))
//       // DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
//     ]));
//     rowList.add(
//         DataRow(color: MaterialStateProperty.all<Color>(Colors.grey), cells: [
//       DataCell(Text("")),
//       DataCell(Text("(-) Discount")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(TextFormField(
//         keyboardType: TextInputType.number,
//         onChanged: (value) {
//           setState(() {
//             print(value);
//             order?.discountValue = int.tryParse(removeRightFromPeriod(value));
//             order?.orderDetails;
//             print(order?.discountValue);
//             getOrderTotalValue();
//           });
//         },
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           isDense: true, // Reduce height
//           contentPadding: EdgeInsets.symmetric(
//               vertical: 8, horizontal: 8), // Adjust padding
//         ),
//         initialValue: "${order?.discountValue ?? 0}",
//       )),
//       // DataCell(Text(
//       //     "- ₹ ${order?.promotion == null ? 0.0 : (order?.promotion?.maximumDiscount?.toStringAsFixed(1)) ?? 0.0}")),
//     ]));

//     rowList.add(DataRow(cells: [
//       DataCell(Text("")),
//       DataCell(
//           Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold))),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text("")),
//       DataCell(Text(
//         "₹ ${order?.orderAmount}",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       )),
//     ]));

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all<Color>(Colors.black),
//             dataRowHeight: 50,
//             columnSpacing: 20,
//             columns: [
//               DataColumn(label: Text("#")),
//               DataColumn(
//                   label: Text('Items',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Measurement',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Unit(s)',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('Qty',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('₹ Discount',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('₹ Mrp Price',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('₹ Actual Price',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('₹ Gst',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//               DataColumn(
//                   label: Text('₹ Total',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: kMediumFontSize,
//                           fontWeight: FontWeight.bold))),
//             ],
//             rows: rowList,
//           ),
//         ),
//       ),
//     );
//   }
// }

// String removeRightFromPeriod(String input) {
//   if (input.contains('.')) {
//     return input.split('.').first;
//   }
//   return input; // Return the original string if no period is found
// }

// dynamic clauclatePrice(double price, int quantity, double discount) {
//   price = quantity * price - quantity * discount;
//   return price;
// }

// class Customtextfeild1 extends StatefulWidget {
//   final Function(dynamic) k;
//   final String? intialvlaue;
//   const Customtextfeild1({Key? key, required this.k, this.intialvlaue})
//       : super(key: key);

//   @override
//   State<Customtextfeild1> createState() => _Customtextfeild1State();
// }

// class _Customtextfeild1State extends State<Customtextfeild1> {
//   TextEditingController textcontroller = TextEditingController();
//   @override
//   void initState() {
//     widget.intialvlaue != null
//         ? textcontroller.text = widget.intialvlaue!
//         : null;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(),
//         isDense: true, // Reduce height
//         contentPadding:
//             EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Adjust padding
//       ),
//       controller: textcontroller,
//       onChanged: (value) {
//         print(value);
//         widget.k(value);
//       },
//     );
//   }
// }

// void prints(var s1) {
//   String s = s1.toString();
//   final pattern = RegExp('.{1,800}');
//   pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
// }
// double calculateGst(double totalAmount, double gstPercent) {
//   return totalAmount * gstPercent / 100;
// }
