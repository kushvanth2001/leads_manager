import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import '../../Controller/customers_controller.dart';
import '../../utils/snapPeUI.dart';
import 'customerWidget.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({Key? key}) : super(key: key);
  final CustomerController customersController = CustomerController();

  _customers() {
    if (customersController.customersModel.value.customers == null ||
        customersController.customersModel.value.customers!.length == 0) {
      // return SnapPeUI().noDataFoundImage();
      return SnapPeUI().loading();
    } else {
      return Expanded(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: customersController
                      .customersModel.value.customers!.length,
                  itemBuilder: (context, index) {
                    return Slidable(
  
  endActionPane: ActionPane(
    motion: ScrollMotion(),
    children: <Widget>[
      SlidableAction(
        onPressed: (context) async{
if(customersController.customersModel.value.customers![index].id!=null){
await SnapPeNetworks().deleteCustomer(customersController.customersModel.value.customers![index].id!.toString());
customersController.loadData(forcedReload: true);
                     
                            }

        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ],
  ),
  child: CustomerWidget(
                        customer: customersController
                            .customersModel.value.customers![index]), // Replace with your actual child widget
);

                    
                   
                  }),
            ),
          ],
        ),
      );
    }
  }

  _buildBody() {
    return SafeArea(
      child: RefreshIndicator(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              CupertinoSearchTextField(
                placeholder: "Search Customer by Name or Mobile Number",
                decoration: SnapPeUI().searchBoxDecoration(),
                onChanged: (value) {
                  customersController.searchCustomer(value);
                },
                // onChanged: (value) {},
              ),
              SizedBox(height: 5),
              Obx(() => _customers())
            ],
          ),
        ),
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 1),
            () {
              customersController.loadData(forcedReload: true);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
