import 'package:flutter/material.dart';
import '../../utils/snapPeUI.dart';

class MerchantOptionWidget extends StatelessWidget {
  final String merchantName;
  const MerchantOptionWidget({Key? key, required this.merchantName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(merchantName),
      onTap: () {
        SnapPeUI().toastSuccess(message: merchantName);
      },
    );
  }
}
