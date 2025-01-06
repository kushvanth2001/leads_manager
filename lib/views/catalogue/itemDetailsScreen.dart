import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_catalogue.dart' as i_Catalogue;
import '../../models/model_category.dart' as i_Category;
import '../../models/model_unit.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import '../../helper/SharedPrefsHelper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:image_cropper/image_cropper.dart';

import 'catalogueScreen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final i_Catalogue.Sku? skuItem;
  final CatalogueScreenState? catalogueScreenState;
  const ItemDetailsScreen({Key? key, this.skuItem, this.catalogueScreenState})
      : super(key: key);

  @override
  _ItemDetailsScreenState createState() =>
      _ItemDetailsScreenState(catalogueScreenState);
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  CatalogueScreenState? catalogueScreenState;
  _ItemDetailsScreenState(CatalogueScreenState? catalogueScreenState) {
    this.catalogueScreenState = catalogueScreenState;
  }
  final titleController = TextEditingController();
  final brandController = TextEditingController();
  final mrpController = TextEditingController();
  final sellingPriceController = TextEditingController();
  //final unitController = TextEditingController();
  final measurementController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  bool isNewItem = true;
  List<String> imageUrlList = [];
  late i_Catalogue.Sku sku = new i_Catalogue.Sku();

  Unit? selectedUnit;
  List<Unit> units = [
    Unit(id: 1, name: "Kgs"),
    Unit(id: 1, name: "Gms"),
    Unit(id: 1, name: "Mgs")
  ];

  @override
  void initState() {
    super.initState();
    _setDropDown();
    populateValue();
  }

  _setDropDown({bool forcedReload = false}) async {
    late String? categoriesData = SharedPrefsHelper().getCategories();
    if (categoriesData == null || forcedReload) {
      categoriesData = await SnapPeNetworks().getCategory();
      if (categoriesData == null) {
        return;
      }
      SharedPrefsHelper().setCategories(categoriesData);
    }
    category = i_Category.categoryFromJson(categoriesData);

    late String? unitData = SharedPrefsHelper().getUnit();
    if (unitData == null || forcedReload) {
      unitData = await SnapPeNetworks().getUnit();
      if (unitData == null) {
        return;
      }
      SharedPrefsHelper().setUnit(unitData);
    }
    units = unitFromJson(unitData).units;
    //selectedUnit = sku.unit;
  }

  populateValue() {
    if (widget.skuItem == null) {
      print("creating new item");
      return;
    }

    sku = widget.skuItem!;
    selectedUnit = sku.unit;
    //print("selected Unit : ${selectedUnit!.name}");

    if (sku.id != null) {
      isNewItem = false;
      if (sku.images != null && sku.images!.length != 0) {
        imageUrlList = sku.images!.map((e) => e.imageUrl ?? "").toList();
      }

      titleController.text = sku.displayName ?? "";
      brandController.text = sku.brand ?? "";
      mrpController.text = sku.mrp!.round().toString();
      sellingPriceController.text = sku.sellingPrice!.round().toString();
      //unitController.text = sku.unit!.name;
      measurementController.text = sku.measurement!;
      descriptionController.text = sku.description ?? "";
      categoryController.text = sku.type ?? "";
    }
  }

  imageSlider() {
    return CarouselSlider.builder(
      itemCount: imageUrlList.length,
      itemBuilder: (context, index, realIndex) {
        return Hero(
          tag: "c-${sku.id}",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrlList[index]),
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
          height: 200,
          enableInfiniteScroll: false,
          viewportFraction: 0.7,
          autoPlay: true,
          enlargeCenterPage: true),
    );
  }

  btnImage() async {
    final file = await SharedPrefsHelper.pickMedia(cropSquareImage);
    print("final image -  $file");
    if (file == null) {
      return;
    }

    var result = await SnapPeNetworks().uploadImage(sku.id, file);
    if (result != "") {
      SnapPeUI().toastSuccess(message: "Image Successfully Uploaded.");

      setState(() {
        i_Catalogue.ImageC i = i_Catalogue.ImageC();
        i.id = result["id"];
        i.status = result["status"];
        i.messages = result["messages"];
        i.imageUrl = result["imageUrl"];
        i.imageText = result["imageText"];
        List<i_Catalogue.ImageC> list = [i];

        sku.images = list;

        imageUrlList.add(i.imageUrl.toString());
      });
    } else {
      SnapPeUI().toastError();
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ImageScreen(_imageList)),
    // );
  }

  Future<File?> cropSquareImage(File imageFile) async {
    return null;
    // return await ImageCropper.cropImage(
    //     sourcePath: imageFile.path,
    //     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
  }

  _imagePreview() {
    return Stack(
      children: [
        imageSlider(),
        Positioned(
            bottom: 5,
            right: 0,
            child: InkWell(
              onTap: () => btnImage(),
              child: Icon(
                Icons.camera_alt_rounded,
                color: kSecondayTextcolor,
                size: 50,
              ),
            ))
      ],
    );
  }

  i_Category.Category? category;

  Future<List<String>> getCategorySuggestion(String query) async {
    List<String> sku = category!.skuTypes.where((element) {
      final elementLower = element.toLowerCase();
      final queryLower = query.toLowerCase();
      return elementLower.contains(queryLower);
    }).toList();
    return sku;
  }

  // Future<List<i_Catalogue.Unit>> getUnitSuggestion(String query) async {
  //   List<i_Catalogue.Unit> sku = unitModel!.units.where((element) {
  //     final elementLower = element.name.toLowerCase();
  //     final queryLower = query.toLowerCase();
  //     return elementLower.contains(queryLower);
  //   }).toList();
  //   return sku;
  // }

  _formFields() {
    return Column(
      children: [
        TextFormField(
          controller: brandController,
          keyboardType: TextInputType.name,
          maxLength: 200,
          decoration:
              InputDecoration(hintText: "Enter Brand", labelText: "Brand"),
        ),
        TextFormField(
          controller: titleController,
          keyboardType: TextInputType.name,
          maxLength: 200,
          decoration:
              InputDecoration(hintText: "Enter Title", labelText: "Title"),
        ),
        TypeAheadField<String>(
          textFieldConfiguration: TextFieldConfiguration(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Catagory')),
          suggestionsCallback: (pattern) async =>
              await getCategorySuggestion(pattern),
          itemBuilder: (BuildContext context, itemData) {
            return ListTile(
              title: Text(itemData),
            );
          },
          onSuggestionSelected: (Object? suggestion) {
            categoryController.text = suggestion.toString();
          },
        ),

        // DropdownButton<Unit>(
        //   value: selectedUnit,
        //   onChanged: (Unit? newValue) {
        //     setState(() {
        //       selectedUnit = newValue!;
        //       sku.unit = selectedUnit;
        //     });
        //   },
        //   items: units!.map((Unit unit) {
        //     return DropdownMenuItem<Unit>(
        //       value: unit,
        //       child: Text(
        //         unit.name,
        //         style: TextStyle(color: Colors.black),
        //       ),
        //     );
        //   }).toList(),
        // ),

        // TypeAheadField<String>(
        //   textFieldConfiguration: TextFieldConfiguration(
        //       controller: unitController,
        //       decoration: InputDecoration(labelText: 'Unit')),
        //   suggestionsCallback: (pattern) async =>
        //       await getUnitSuggestion(pattern),
        //   itemBuilder: (BuildContext context, itemData) {
        //     return ListTile(
        //       title: Text(itemData),
        //     );
        //   },
        //   onSuggestionSelected: (Object? suggestion) {
        //     unitController.text = suggestion.toString();
        //   },
        // ),
        TextFormField(
          controller: mrpController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
              hintText: "Enter MRP Price", labelText: "MRP Price"),
        ),
        TextFormField(
          controller: sellingPriceController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
              hintText: "Enter Selling Price", labelText: "Selling Price"),
        ),
        TextFormField(
          controller: measurementController,
          keyboardType: TextInputType.number,
          maxLength: 50,
          decoration: InputDecoration(
              hintText: "Enter Measurement", labelText: "Measurement"),
        ),
        TextFormField(
          controller: descriptionController,
          keyboardType: TextInputType.name,
          maxLength: 500,
          decoration: InputDecoration(
              hintText: "Enter Description", labelText: "Description"),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  _saveButton() {
    return ElevatedButton(
        style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(250, 40))),
        onPressed: () async {
          sku.brand = brandController.text;
          sku.displayName = titleController.text;
          sku.mrp = double.parse(mrpController.text);
          sku.sellingPrice = double.parse(sellingPriceController.text);
          //sku.unit = unitController.text;
          sku.unit = sku.unit ?? Unit(id: 9, name: "No");
          sku.measurement = measurementController.text == ""
              ? "1"
              : measurementController.text;
          sku.description = descriptionController.text;
          sku.type = categoryController.text;

          bool result = await SnapPeNetworks().saveItem(sku, isNewItem);
          if (!result) {
            return;
          }

          Navigator.pop(context);
          if (isNewItem) {
            Navigator.pop(context);
          }

          //need to be reload screen after save item
          //catalogueScreenState!.loadData(forcedReload: true);
        },
        child: Text(
          "Save",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: kPrimaryTextColor),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SnapPeUI()
            .nAppBar(isNewItem == true ? "New Product" : "Edit Product"),
        body: Container(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
            child: Column(
              children: [_imagePreview(), _formFields(), _saveButton()],
            ),
          ),
        ));
  }
}
