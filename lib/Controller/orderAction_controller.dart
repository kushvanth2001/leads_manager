import 'package:get/get.dart';

class OrderActionController extends GetxController {
  RxString selectedOrderStatus = "Select".obs;
  RxString selectedPaymentStatus = "Select".obs;

  void setOrderStatus(String orderStatus) {
    selectedOrderStatus.value = orderStatus;
  }

  void setPaymentStatus(String paymentStatus) {
    selectedPaymentStatus.value = paymentStatus;
  }
}
