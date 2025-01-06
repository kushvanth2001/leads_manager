// import 'package:get/get.dart';

// class SwitchController extends GetxController {
//   // Map to store the switch values for each ListTile
//   var switchValues = <String, bool>{}.obs;

//   // Function to set the switch value for a given customer number
//   void setSwitchValue(String customerNo, bool value) {
//     print('Setting switch value for customer $customerNo: $value');
//     switchValues[customerNo] = value;
//   }

//   // Function to get the switch value for a given customer number
//   bool getSwitchValue(String customerNo, bool? fromActive) {
//     print(
//         'Getting switch value for customer $customerNo: ${switchValues[customerNo]}');
//     if (fromActive == true) {
//       return switchValues[customerNo] ?? true;
//     } else {
//       return switchValues[customerNo] ?? false;
//     }
//   }

//   void clearSwitchValues() {
//     switchValues.clear();
//   }
// }
