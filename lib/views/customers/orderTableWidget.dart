import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../../Controller/customerDetails_controller.dart';

import '../../constants/styleConstants.dart';
import '../../utils/snapPeUI.dart';

class OrderTableWidget extends StatelessWidget {
  final CustomerDetailscontoller customerDetailscontroller;
  const OrderTableWidget({Key? key, required this.customerDetailscontroller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => orderTable());
  }

  orderTable() {
    List<DataRow> rowList = customerDetailscontroller.orderList.value
        .map(
          (e) => DataRow(cells: [
            DataCell(Text("${e.id}")),
            DataCell(Text("${e.createdOn}")),
            DataCell(Text("${e.orderAmount}")),
            DataCell(IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
            )),
          ]),
        )
        .toList();

    return Column(
      children: [
        SnapPeUI().headingText("Order Table"),
        Container(
          height: 250,
          width: double.infinity,
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text('ID',
                            style: TextStyle(
                                fontSize: kMediumFontSize,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(
                                fontSize: kMediumFontSize,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Amount',
                            style: TextStyle(
                                fontSize: kMediumFontSize,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Action',
                            style: TextStyle(
                                fontSize: kMediumFontSize,
                                fontWeight: FontWeight.bold))),
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
