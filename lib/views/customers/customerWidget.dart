import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/networkConstants.dart';
import '../../models/model_customer.dart';
import 'customerDetailsScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/styleConstants.dart';

class CustomerWidget extends StatelessWidget {
  const CustomerWidget({Key? key, required this.customer}) : super(key: key);
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(customer.userId);
        Get.to(() => CustomerDetailsScreen(
              customer: customer,
            ));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
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
                          Flexible(
                            flex: 5,
                            child: Text(
                              "${customer.customerName ?? ""}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
                        children: [
                          Text(
                            "${customer.organizationName ?? ""}", //|  ${order.customerNumber}
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible:
                                customer.mobileNumber == null ? false : true,
                            child: Flexible(
                              fit: FlexFit.loose,
                              flex: 1,
                              child: Container(
                                height: 70,
                                width: 70,
                                child: IconButton(
                                  
                                    onPressed: () async {
                                      var url = "tel:${customer.mobileNumber!}";
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    icon:
                                        Image.asset("assets/icon/callIcon.png")),
                              ),
                            ),
                          ),
                          Visibility(
                            visible:
                                customer.mobileNumber == null ? false : true,
                            child: Flexible(
                              fit: FlexFit.loose,
                              flex: 1,
                              child: Container(
                                height: 70,
                                width: 70,
                                child: IconButton(
                                  onPressed: () {
                                    btnWhatsapp();
                                  },
                                  icon:
                                      Image.asset("assets/icon/whatsappIcon.png"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> btnWhatsapp() async {
    var url = NetworkConstants.getWhatsappUrl(customer.mobileNumber);
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true, enableDomStorage: true);
    }
  }

  Widget iconText(Icon iconWidget, Text textWidget) {
    return Row(
      children: [iconWidget, SizedBox(width: 5), textWidget],
    );
  }
}
