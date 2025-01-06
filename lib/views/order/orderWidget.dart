import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/networkConstants.dart';
import '../../models/model_orders.dart';
import 'orderScreen.dart';
import '../../utils/snapPeNetworks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/styleConstants.dart';
import 'ordersDetails.dart';

class OrderWidget extends StatelessWidget {
  final bool isquotation;
  final Order order;
  final OrderScreenState orderScreenState;
  final VoidCallback onBack;
  final bool isfromlead;
  const OrderWidget(
      {Key? key,
      required this.order,
      required this.orderScreenState,
      required this.onBack, required this.isquotation,this.isfromlead=false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(order.orderStatus);
    return InkWell(
      onTap: () {
        print(order.id);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                  isquotation: isquotation,
                      onBack: onBack,
                      orderId: order.id,
                      isPendingOrder: orderScreenState.tabIndex==1?true:false,
                      order: order,
                      isfromlead:isfromlead ,
                    )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                clipBehavior: Clip.antiAlias,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          orderIndication(),
                          Flexible(
                            flex: 5,
                            child: Text(
                              "${order.customerName ?? ""}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: kMediumFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                            "Order ID - ${order.id ?? ""}",
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                            "${order.validTill!=null?DateFormat('dd/MM/yyyy').format( DateTime.parse( order.validTill!)):""}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Customer No - ${order.customerNumber ?? ""}", //|  ${order.customerNumber}
                            overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                              fontSize: 12
                            ),  
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Order Status - ${order.orderStatus ?? ""}",                               style: TextStyle(
                              fontSize: 12
                            ),  )
                        ],
                      ),
                     
                  orderScreenState.tabIndex!=2?    Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: order.orderStatus == "SUBMITTED",
                            child: Flexible(
                                fit: FlexFit.loose,
                                flex: 1,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.amber)),
                                  onPressed: () => _actionOperation(3, context),
                                  child: Text("Accept"),
                                )),
                          ),
                          Visibility(
                            visible: order.orderStatus == "ACCEPTED",
                            child: Flexible(
                                fit: FlexFit.loose,
                                flex: 1,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blue)),
                                  onPressed: () => _actionOperation(4, context),
                                  child: Text("Confirm"),
                                )),
                          ),
                          Visibility(
                            visible: order.paymentStatus != "COMPLETED",
                            child: Flexible(
                              fit: FlexFit.loose,
                              flex: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                child: IconButton(
                                    onPressed: () => _actionOperation(0, context),
                                    icon: Image.asset("assets/icon/send.png")),
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 1,
                            child: Container(
                               height: 50,
                                width: 50,
                              child: IconButton(
                                onPressed: () => _actionOperation(1, context),
                                icon: Image.asset("assets/icon/invoice.png"),
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 1,
                            child: Container(
                               height: 50,
                                width: 50,
                              child: IconButton(
                                onPressed: () => _actionOperation(2, context),
                                icon: Image.asset("assets/icon/whatsappIcon.png"),
                              ),
                            ),
                          ),
                        ],
                      ):Container()
                    ],
                  ),
                  // Positioned(
                  //   top: -16,
                  //   right: -15,
                  //   child: PopupMenuButton(
                  //     icon: Icon(
                  //       Icons.more_vert,
                  //       color: kPrimaryColor,
                  //     ),
                  //     itemBuilder: (context) => [
                  //       PopupMenuItem(
                  //         child: Text("Send Bills"),
                  //         value: 0,
                  //       ),
                  //       PopupMenuItem(
                  //         child: Text("Share Invoice"),
                  //         value: 1,
                  //       ),
                  //       PopupMenuItem(
                  //         child: Text("Chat with Customer"),
                  //         value: 2,
                  //       ),
                  //     ],
                  //     onSelected: (int value) {
                  //       _menuSelection(value, context);
                  //     },
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(15)),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconText(Icon iconWidget, Text textWidget) {
    return Row(
      children: [iconWidget, SizedBox(width: 5), textWidget],
    );
  }

  orderIndication() {
    MaterialColor orderStatusColor;
    switch (order.orderStatus) {
      case "DELIVERED":
        orderStatusColor = kDeliveredOrderColor;
        break;
      case "CONFIRMED":
        orderStatusColor = kConfirmedOrderColor;
        break;
      case "CANCELLED":
        orderStatusColor = kCancelledOrderColor;
        break;
      case "SUBMITTED":
        orderStatusColor = kSubmittedOrderColor;
        break;
      case "ACCEPTED":
        orderStatusColor = kAcceptedOrderColor;
        break;
      default:
        orderStatusColor = kBlackColor;
        break;
    }

    return Flexible(
      child: Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
          decoration:
              BoxDecoration(color: orderStatusColor, shape: BoxShape.circle)),
    );
  }

  void _actionOperation(int value, BuildContext context) async {
    switch (value) {
      case 0:
        SnapPeNetworks().sendBill(order.merchantName!, order.userId!, order.id!,
            order.orderAmount!, order.applicationName!, order.customerNumber!);

        break;
      case 1:
        if (!await Permission.storage.isGranted) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();
          print(statuses[Permission.storage]);
          if (statuses[Permission.storage] == PermissionStatus.granted) {
            SnapPeNetworks().downloadPdf(order.id!);
          }
        } else {
          SnapPeNetworks().downloadPdf(order.id!);
          // Share.shareFiles(["/sdcard/download/854906 _invoice.pdf"],
          //     text: "TExt", subject: "Subject");
        }
        break;
      case 2:
        var url = NetworkConstants.getWhatsappUrlWithMsg(
            order.customerNumber, order.id);
        if (await canLaunch(url)) {
          await launch(url, enableJavaScript: true, enableDomStorage: true);
        }
        break;
      case 3:
        bool result = await SnapPeNetworks().acceptOrder(order);
        if (result) {
          orderScreenState.loadData(forcedReload: true);
        }
        break;
      case 4:
        bool result = await SnapPeNetworks().confirmOrder(order);
        if (result) {
          orderScreenState.loadData(forcedReload: true);
        }
        break;
    }
  }
}
