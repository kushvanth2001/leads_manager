import 'package:flutter/material.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_catalogue.dart';
import '../../utils/snapPeNetworks.dart';

import '../../constants/styleConstants.dart';
import 'catalogueScreen.dart';
import 'itemDetailsScreen.dart';

class ItemWidget extends StatefulWidget {
  final Sku item;
  final CatalogueScreenState catalogueScreenState;
  const ItemWidget(
      {Key? key, required this.item, required this.catalogueScreenState})
      : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState(catalogueScreenState);
}

class _ItemWidgetState extends State<ItemWidget> {
  late CatalogueScreenState catalogueScreenState;
  _ItemWidgetState(catalogueScreen) {
    this.catalogueScreenState = catalogueScreen;
  }
  String subTitle = "";
  @override
  void initState() {
    super.initState();
    subTitle =
        "₹${widget.item.sellingPrice} per ${widget.item.measurement} ${widget.item.unit!.name}";
  }

  @override
  Widget build(BuildContext context) {
    //timeDilation = 2.0;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Stack(alignment: Alignment.centerRight, children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: "c-${widget.item.id}",
                      child: SizedBox(
                        child: widget.item.images!.length == 0
                            ? Image.asset("assets/images/noImage.png")
                            : Image.network(
                                widget.item.images![0].imageUrl ?? "",
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("assets/images/noImage.png"),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.displayName!,
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.w500,
                          color: kSecondayTextcolor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      subTitle,
                      style: TextStyle(color: kLightTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            shareItem()
          ]),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItemDetailsScreen(
                        skuItem: widget.item,
                        catalogueScreenState: catalogueScreenState,
                      )));
          print(widget.item.id);
        },
      ),
    );
  }

  Positioned shareItem() {
    return Positioned(
      bottom: 33,
      right: -10,
      child: IconButton(
        onPressed: () {
          SnapPeNetworks().downloadItemsImages(widget.item);
        },
        icon: SizedBox(
            width: 28, height: 28, child: Image.asset("assets/icon/share.png")),
      ),
    );
  }
}
