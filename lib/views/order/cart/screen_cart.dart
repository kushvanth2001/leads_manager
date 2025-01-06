import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../models/model_catalogue.dart';
import '../../../models/model_order_summary.dart';
import '../../../models/model_delivery_schedule.dart';
import '../../../utils/snapPeNetworks.dart';
import '../../../utils/snapPeUI.dart';

import '../../../constants/styleConstants.dart';
import '../../../models/model_PriceList.dart';

class CartScreen extends StatefulWidget {
  final OrderSummaryModel order;
  const CartScreen({Key? key, required this.order}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Sku> skuList = [];
  List<DeliveryOption> deliveryOption = [];
  final sugControllerBox = SuggestionsBoxController();
  //String? _selectedDeliveryDate;
  @override
  void initState() {
    super.initState();
    fetchDelivery();
    setValue();
  }

  setValue() {
    widget.order.orderStatus = "SUBMITTED";
    widget.order.amountPaid = 0;
    widget.order.orderAmount = 0;
    widget.order.originalAmount = 0;
    widget.order.paymentStatus = "PENDING";
    widget.order.deliveryCharges = 0;
  }

  fetchDelivery() async {
    if (widget.order.community == null || widget.order.userId == null) {
      SnapPeUI().toastError(
          message:
              "SomeThing Wrong. (Selected customer's Community or UserId might be null.)");
      return;
    }
    showPriceListDialog(
        await SnapPeNetworks().getPriceList(widget.order.userId!));

    var result =
        await SnapPeNetworks().getDeliveryTime(widget.order.community!);
    print(result);
    if (result == "") {
      return;
    }
    DeliveryModel deliveryModel = deliveryModelFromJson(result);
    deliveryOption = deliveryModel.deliveryOptions ?? [];
    // widget.order.selectedDeliveryBucketId =
    //     deliveryModel.deliveryOptions![0].id;
    // widget.order.deliveryTime =
    //     deliveryModel.deliveryOptions![0].deliveryOption;
  }

  showPriceListDialog(List<PricelistMaster> pricelistMaster) {
    if (pricelistMaster.length == 0) {
      return;
    }
    Get.defaultDialog(
        title: "Please select PriceList",
        content: Container(
            height: 300.0, // Change as per your requirement
            width: 300.0,
            child: Column(
              children: [
                ListTile(
                  title: Text("Public"),
                  onTap: () {
                    Get.back();
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pricelistMaster.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(pricelistMaster[index].name!),
                      onTap: () {
                        widget.order.pricelist = pricelistMaster[index];
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: _buildBodyContent(),
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      toolbarHeight: 80,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SnapPeUI().appBarText("Create New Order", kBigFontSize),
        SnapPeUI().appBarSubText(
            "Customer Number : ${widget.order.customerNumber}",
            kMediumFontSize),
      ]),
    );
  }

  _buildBodyContent() {
    final serachController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _searchItemsWidget(serachController),
          _buildItemsListVIew(),
        ],
      ),
    );
  }

  _searchItemsWidget(TextEditingController serachController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Search Items",
              style: TextStyle(
                  fontSize: kBigFontSize, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TypeAheadField(
              suggestionsBoxController: sugControllerBox,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: serachController,
                  decoration: InputDecoration(labelText: "Search Items")),
              suggestionsCallback: (pattern) async => await SnapPeNetworks()
                  .itemsSuggestionsCallback(
                      pattern, widget.order.pricelist?.code),
              itemBuilder: (context, Sku itemData) {
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    child:
                        itemData.images == null || itemData.images!.length == 0
                            ? Image.asset("assets/images/noImage.png")
                            : Image.network("${itemData.images![0].imageUrl}"),
                  ),
                  title: Text("${itemData.displayName}"),
                  trailing: TextButton(
                    child: Text("Add to cart"),
                    onPressed: () {
                      print("selected Product - ${itemData.id} ");

                      widget.order.orderAmount =
                          widget.order.orderAmount! + itemData.sellingPrice!;
                      widget.order.originalAmount =
                          widget.order.originalAmount! + itemData.sellingPrice!;
                      bool alreadyAdded = false;

                      for (int i = 0; i < skuList.length; i++) {
                        print("checking ${skuList[i].id}   -  ${itemData.id}");
                        if (skuList[i].id == itemData.id) {
                          alreadyAdded = true;
                        }
                      }

                      if (alreadyAdded) {
                        Fluttertoast.showToast(
                            msg: "Already Added.",
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red);
                        return;
                      }

                      print(alreadyAdded);
                      setState(() {
                        sugControllerBox.close();
                        itemData.quantity = 1;
                        print(
                            "sell price - ${itemData.sellingPrice}  totalAmount - ${itemData.totalAmount}");
                        itemData.totalAmount = itemData.sellingPrice;
                        itemData.size = "0";
                        itemData.skuId = itemData.id;
                        itemData.gst = 0;

                        skuList.add(itemData);
                      });
                    },
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                print(suggestion);
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildItemsListVIew() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(4),
          color: Colors.white,
          height: 250,
          child: ListView.builder(
            itemCount: skuList.length,
            itemBuilder: (context, index) {
              return _item(skuList[index]);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            children: [
              DropdownButton<int>(
                value: widget.order.selectedDeliveryBucketId,
                iconSize: 25,
                elevation: 16,
                hint: Text(
                  "Please choose a Delivery Schedule",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    widget.order.selectedDeliveryBucketId = newValue!;
                    //widget.order.deliveryTime =deliveryOption.
                  });
                },
                items: deliveryOption
                    .map<DropdownMenuItem<int>>((DeliveryOption value) {
                  return DropdownMenuItem<int>(
                    value: value.id,
                    child: Text("${value.deliveryOption}"),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(16),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            children: [
              Text(
                "Total Amount : ₹${widget.order.orderAmount}",
                style: TextStyle(fontSize: kMediumFontSize),
              ),
              ElevatedButton(
                  onPressed: () async {
                    widget.order.orderDetails = skuList;
                    // widget.order.applicationName = "DivigoRetail";
                    // widget.order.applicationNo = "919953423108";
                    //widget.order.pinCode = 502032;
                    widget.order.status = "OK";
                    if (widget.order.selectedDeliveryBucketId == null) {
                      SnapPeUI().toastWarning(
                          message: "Please Select Delivery schedule.");
                      return;
                    }

                    OrderSummaryModel? model =
                        await SnapPeNetworks().createNewOrder(widget.order);
                    if (model != null) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Place Order",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        )
      ],
    );
  }

  _item(Sku sku) {
    return ListTile(
      leading: SizedBox(
          width: 50, child:(sku.images!=null&& sku.images!.isNotEmpty)? Image.network("${sku.images![0].imageUrl}"):Container()),
      title: Text("${sku.displayName!}"),
      subtitle: Text(
        "Price : ₹${sku.sellingPrice!}",
        style: TextStyle(color: Colors.lightGreen),
      ),
      trailing: SizedBox(
        width: 106,
        child: Row(
          children: <Widget>[
            sku.quantity != 0
                ? sku.quantity == 1
                    ? new IconButton(
                        icon: new Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(() {
                          widget.order.orderAmount =
                              widget.order.orderAmount! - sku.sellingPrice!;

                          widget.order.originalAmount =
                              widget.order.originalAmount! - sku.sellingPrice!;
                          skuList.remove(sku);
                        }),
                      )
                    : new IconButton(
                        icon: new Icon(Icons.remove),
                        onPressed: () => setState(() {
                          sku.totalAmount =
                              sku.totalAmount! - sku.sellingPrice!;
                          widget.order.orderAmount =
                              widget.order.orderAmount! - sku.sellingPrice!;
                          widget.order.originalAmount =
                              widget.order.originalAmount! - sku.sellingPrice!;
                          sku.quantity = sku.quantity! - 1;
                        }),
                      )
                : new Container(),
            new Text(sku.quantity.toString()),
            new IconButton(
                icon: new Icon(Icons.add),
                onPressed: () => setState(() {
                      sku.totalAmount = sku.totalAmount! + sku.sellingPrice!;
                      widget.order.orderAmount =
                          widget.order.orderAmount! + sku.sellingPrice!;
                      widget.order.originalAmount =
                          widget.order.originalAmount! + sku.sellingPrice!;
                      sku.quantity = sku.quantity! + 1;
                    }))
          ],
        ),
      ),
    );
  }
}
