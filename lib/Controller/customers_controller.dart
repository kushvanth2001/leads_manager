import 'package:get/get.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_customer.dart';
import '../utils/snapPeNetworks.dart';

class CustomerController extends GetxController {
  Rx<CustomersModel> customersModel = CustomersModel().obs;

  CustomerController() {loadData();}

  loadData({bool forcedReload = false}) async {
    if (forcedReload) {
      await getFromNetwork();
    } else {
      String? response = await SharedPrefsHelper().getCustomers();
      if (response != null) {
        customersModel.value = customersModelFromJson(response);
      } else {
        await getFromNetwork();
      }
    }
  }

  Future<void> getFromNetwork() async {
    String? response = await SnapPeNetworks().getCustomers();
    if (response != null) {
      customersModel.value = customersModelFromJson(response);
      SharedPrefsHelper().setCustomers(response);
    }
  }

  void searchCustomer(dynamic searchValue) async {
    customersModel.value=CustomersModel();
    String? response = await SnapPeNetworks().searchCustomer(searchValue);
    if (response != null) {
      customersModel.value = customersModelFromJson(response);
    }
  }
}
