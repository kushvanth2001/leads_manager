import 'package:get/get.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_merchant_profile.dart';
import '../utils/snapPeNetworks.dart';

class ProfileController extends GetxController {
  Rx<MerchantProfile> merchantProfile = new MerchantProfile().obs;
  RxString listofCategory = "".obs;

  ProfileController() {
    _loadData();
  }

  void _loadData() async {
    try {
      String? data = SharedPrefsHelper().getMerchantProfile();
      if (data == null) {
        await SnapPeNetworks().refreshMerchantProfile();
        data = SharedPrefsHelper().getMerchantProfile();
      }
      merchantProfile.value = merchantProfileFromJson(data!);
      merchantProfile.value.mode = merchantProfile.value.mode == "B2C"
          ? "Direct to Customer"
          : merchantProfile.value.mode == "B2B"
              ? "Through Sales Channel"
              : "Both";

      int len = merchantProfile.value.categories == null
          ? 0
          : merchantProfile.value.categories!.length;
      listofCategory.value = "";
      for (int i = 0; i < len; i++) {
        String category = merchantProfile.value.categories![i].category ?? "";
        listofCategory.value =
            listofCategory.value + category + (i == len - 1 ? "." : " , ");
      }
    } catch (ex) {
      print("Rohit Error" + ex.toString());
    }
  }
}
