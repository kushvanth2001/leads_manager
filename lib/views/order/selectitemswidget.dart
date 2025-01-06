import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:leads_manager/views/order/ordersDetails.dart';

import '../../models/model_catalogue.dart';
import '../../models/model_orders.dart';
import '../../utils/snapPeNetworks.dart';

class SearchAndAddItemDialog extends StatefulWidget {
  final List<Sku> skuList;
  final Function(Sku) onItemAdded;
final Order order;
  const SearchAndAddItemDialog({
    Key? key,
    required this.skuList,
    required this.onItemAdded,
    required this.order,
  }) : super(key: key);

  @override
  _SearchAndAddItemDialogState createState() => _SearchAndAddItemDialogState();
}

class _SearchAndAddItemDialogState extends State<SearchAndAddItemDialog> {
  final TextEditingController serachController = TextEditingController();
  final sugControllerBox = SuggestionsBoxController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search and Add Item",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField(
              suggestionsBoxController: sugControllerBox,
              textFieldConfiguration: TextFieldConfiguration(
                controller: serachController,
                decoration: InputDecoration(labelText: "Search Items"),
              ),
              suggestionsCallback: (pattern) async => await SnapPeNetworks()
                  .itemsSuggestionsCallback(pattern, widget.order.pricelist?.code),
              itemBuilder: (context, Sku itemData) {
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    child: itemData.images == null || itemData.images!.length == 0
                        ? Image.asset("assets/images/noImage.png")
                        : Image.network("${(itemData.images!.length != 0 && itemData.images != null) ? itemData.images![0].imageUrl : ""}"),
                  ),
                  title: Text("${itemData.displayName}"),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [



                      TextButton(
                        child: Text("Add to cart"),
                        onPressed: () {
                          setState(() {
                            itemData.quantity=1;
if(itemData.mrp!=null&& itemData.sellingPrice!=null&&itemData.mrp!=0){
itemData.discountValue=itemData.mrp!-itemData.sellingPrice!;
  itemData.discountPercent = (itemData.discountValue! / itemData.mrp!) * 100;
  itemData.totalAmount=itemData.sellingPrice;

}

                            if(itemData.gst!=null && itemData.totalAmount!=null && itemData.gst!=0.0 && itemData.totalAmount!=0.0){
itemData.igst=calculateGst(itemData.totalAmount!, itemData.gst!);}
                          });
                          widget.onItemAdded(itemData); // Callback to add item
                          Navigator.pop(context); // Close dialog after adding item
                        },
                      ),
                    ],
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                print(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }
}
