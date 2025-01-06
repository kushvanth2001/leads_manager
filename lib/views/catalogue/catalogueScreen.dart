import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_catalogue.dart';
import '../../utils/snapPeNetworks.dart';
import 'itemWidget.dart';
import '../../utils/snapPeUI.dart';
import '../../helper/SharedPrefsHelper.dart';

import 'itemDetailsScreen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({Key? key}) : super(key: key);

  @override
  CatalogueScreenState createState() => CatalogueScreenState();
}

class CatalogueScreenState extends State<CatalogueScreen> {
  int currentPage = 0, size = 16, totalRecords = 0, pages = 0;

  Catalogue? catalogue;
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    scrollController.addListener(listenSrolling);
    loadData();
  }

  void listenSrolling() async {
    if (scrollController.position.maxScrollExtent - scrollController.offset ==
        0.0) {
      loadData(nextPageReload: true);
    }
  }

  void scrollDown() {
    final double end = scrollController.position.maxScrollExtent;
    print(end);
  }

  loadData({bool forcedReload = false, bool nextPageReload = false}) async {
    String catalogueResData = "";

    if (forcedReload) {
      print("forced Loaded");
      currentPage = 0;
      //skuList = [];
      catalogueResData = await SnapPeNetworks().getItemList(currentPage, size);
      if (catalogueResData == "") return;
      catalogue = catalogueFromJson(catalogueResData);
    } else if (nextPageReload) {
      print(
          "end currentPage - $currentPage Pages - $pages currentRecords -${catalogue!.skuList!.length}  TotalRecords - $totalRecords");
      if (currentPage != pages && catalogue!.skuList!.length != totalRecords) {
        print("ok");
        currentPage = currentPage + 1;
        catalogueResData =
            await SnapPeNetworks().getItemList(currentPage, size);
        if (catalogueResData == "") return;

        var nextCatalogue = catalogueFromJson(catalogueResData);
        print("old skuList size - ${catalogue!.skuList!.length}");
        print("new sku add  - ${nextCatalogue.skuList!.length}");

        nextCatalogue.skuList!.forEach((e) => catalogue!.skuList!.add(e));

        print("After skuList size - ${catalogue!.skuList!.length}");
      } else {
        SnapPeUI().toastWarning(message: "There's no data.");
      }
    } else {
      print("load form Db.");
      catalogueResData = await SharedPrefsHelper().getCatalogue() ??
          await SnapPeNetworks().getItemList(currentPage, size);

      catalogue = catalogueFromJson(catalogueResData);
    }
    if (mounted) {
      setState(() {
        totalRecords = catalogue!.totalRecords!;
        pages = catalogue!.pages!;

        SharedPrefsHelper().setCatalogue(catalogueToJson(catalogue!));

        //catalogue!.skuList.map((e) => skuList!.add(e));
      });
    }
  }

  _serachProduct(String keyword) async {
    String catalogueResData = "";

    catalogueResData = await SnapPeNetworks()
        .getItemList(currentPage, size, serachKeyword: keyword);
    if (catalogueResData == "") return;

    setState(() {
      catalogue = catalogueFromJson(catalogueResData);
    });
  }

  _buildCatalogue() {
    if (catalogue == null) {
      return SnapPeUI().loading();
    } else if (catalogue!.skuList!.length == 0) {
      return SnapPeUI().noDataFoundImage();
    }
    return Expanded(
      child: GridView.builder(
        controller: scrollController,
        itemCount: catalogue!.skuList!.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return ItemWidget(
            item: catalogue!.skuList![index],
            catalogueScreenState: this,
          );
        },
      ),
    );
  }

  _fab(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            label: Text("Share"),
            icon: Icon(Icons.share),
            onPressed: () {
              SnapPeNetworks().downloadCatalogue();
            },
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            label: Text("Create Item"),
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ItemDetailsScreen(catalogueScreenState: this),
                ),
              );
            },
          )
        ]);
  }

  _buildBody() {
    return RefreshIndicator(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: "Search Product",
              decoration: SnapPeUI().searchBoxDecoration(),
              onChanged: (value) {
                _serachProduct(value);
              },
            ),
            SizedBox(height: 5),
            _buildCatalogue()
          ],
        ),
      ),
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
          () {
            loadData(forcedReload: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildBody(),
      floatingActionButton: _fab(context),
    );
  }
}
