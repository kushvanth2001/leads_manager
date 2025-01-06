import 'package:get/get.dart';
import '../models/model_transaction.dart';
import '../models/model_cutomerDetails.dart';
import '../models/model_orders.dart';
import '../utils/snapPeNetworks.dart';

class CustomerDetailscontoller extends GetxController {
  Rx<CustomerDetailsModel> customerDetailsModel = CustomerDetailsModel().obs;
  RxList<Order> orderList = <Order>[].obs;
  RxList<EnduserTransaction> transactionList = <EnduserTransaction>[].obs;
  CustomerDetailscontoller(int? customerId) {
    loadData(customerId);
  }
  loadData(int? customerId) async {
    //Get Lead Details
    String? response = await SnapPeNetworks().getCustomerDetails(customerId);
    if (response != null) {
      customerDetailsModel.value = customerDetailsModelFromJson(response);
    }
    // Get Customer's Orders
    String? resOrder = await SnapPeNetworks()
        .getOrderList(0, 20, customerNumber: "9026744092");
    if (resOrder != "") {
      orderList.value = orderModelFromJson(resOrder).orders!;
    }

    //Get Customer's Transaction

    String? resTran = await SnapPeNetworks()
        .getTransactionList(0, 20, customerNumber: "9026744092");
    if (resTran != null) {
      transactionList.value = transactionFromJson(resTran).enduserTransactions!;
    }
  }
}
