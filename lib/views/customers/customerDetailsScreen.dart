import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'customerInfoScreen.dart';
import 'orderTableWidget.dart';
import 'paymentTableWidget.dart';
//import 'package:leads_manager/views/payment/capturePayment/capturePaymentScreen.dart';
import '../../Controller/customerDetails_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/styleConstants.dart';
import '../../models/model_customer.dart';
//import '../../utils/dialogCustomer.dart';
import '../../utils/snapPeUI.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;
  //final CustomerDialogWidget customerDialogWidget = CustomerDialogWidget();

  CustomerDetailsScreen({Key? key, required this.customer}) : super(key: key);

  _buildBody(CustomerDetailscontoller controller) {
    return RefreshIndicator(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              //customerSearch(),
              customerCard(controller),
              OrderTableWidget(customerDetailscontroller: controller),
              PaymentTableWidget(customerDetailscontroller: controller),
              actionButtons()
            ],
          ),
        ),
      ),
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 5),
          () {
            //loadData(forcedReload: true);
            //setState(() {});
          },
        );
      },
    );
  }

  Row actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(

        style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Background color
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
      side: BorderSide(color: kPrimaryColor), // Border color
    ),),
          onPressed: () {},
          child: Text("Create New Order",),
        ),
        ElevatedButton(
           style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Background color
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
      side: BorderSide(color: kPrimaryColor), // Border color
    ),),
          onPressed: () {
            //Get.to(() => CapturePaymentScreen());
          },
          child: SnapPeUI().appBarText("Capture Payment", kMediumFontSize),
        ),
      ],
    );
  }

  CupertinoSearchTextField customerSearch() {
    return CupertinoSearchTextField(
      placeholder: "Select Customer",
      decoration: SnapPeUI().searchBoxDecoration(),
      onChanged: (value) {
        //CustomerDialogWidget();
        //_searchOrder(keyword: value);
      },
    );
  }

  InkWell customerCard(controller) {
    return InkWell(
      onTap: () {
        print(customer.id);
        Get.to(() => CustomerInfoScreen(
              controller: controller,
            ));
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SnapPeUI().headingText(customer.customerName ?? ""),
                    SnapPeUI().subHeadingText(customer.addressLine1 ?? ""),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            // var url = NetworkConstants.getWhatsappUrlWithMsg(
                            //     customer., order.id);
                            // if (await canLaunch(url)) {
                            //   await launch(url,
                            //       enableJavaScript: true,
                            //       enableDomStorage: true);
                            // }
                          },
                          icon: Icon(Icons.gps_fixed)),
                      Text("Capture\nLocation")
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.directions)),
                      Text("Navigate")
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

  // FloatingActionButton _fab(context) {
  //   return FloatingActionButton.extended(
  //     label: Text("Search Customer"),
  //     icon: Icon(
  //       Icons.people,
  //       color: Colors.white,
  //     ),
  //     onPressed: () {
  //       //customerDialogWidget.selectCustomerDialog(context);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    CustomerDetailscontoller _controller =
        CustomerDetailscontoller((customer.userId));

    return Scaffold(
      appBar: AppBar(title: Text("Customer Details")),
      backgroundColor: kBackgroundColor,
      body: _buildBody(_controller),
      //floatingActionButton: _fab(context),
    );
  }
}
