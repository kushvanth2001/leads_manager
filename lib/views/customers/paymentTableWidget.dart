import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../Controller/customerDetails_controller.dart';
import '../../constants/styleConstants.dart';
import '../../utils/snapPeUI.dart';

class PaymentTableWidget extends StatelessWidget {
  final CustomerDetailscontoller customerDetailscontroller;
  const PaymentTableWidget({Key? key, required this.customerDetailscontroller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => paymentTable());
  }

  paymentTable() {
    List<DataRow> rowList = customerDetailscontroller.transactionList.value
        .map(
          (e) => DataRow(cells: [
            DataCell(Text("${e.id}")),
            DataCell(Text("${e.transactionTime}")),
            DataCell(Text("${e.creditAmount}")),
            DataCell(Text("${e.debitAmount}"))
          ]),
        )
        .toList();

    return Column(
      children: [
        SnapPeUI().headingText("Payment Table"),
        Container(
          height: 250,
          width: double.infinity,
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 22,
                  columns: [
                    DataColumn(
                        label: Text('Order ID',
                            style: TextStyle(
                                fontSize: kMediumFontSize, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(
                                fontSize: kMediumFontSize, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Order Amt',
                            style: TextStyle(
                                fontSize: kMediumFontSize, fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Pending Amt',
                            style: TextStyle(
                                fontSize: kMediumFontSize, fontWeight: FontWeight.bold))),
                  ],
                  rows: rowList,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
