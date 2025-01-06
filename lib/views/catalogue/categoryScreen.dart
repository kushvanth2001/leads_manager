import 'package:flutter/material.dart';
import '../../models/model_catalogue.dart';
import '../../models/model_category.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'itemDetailsScreen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Category? category;
  @override
  void initState() {
    super.initState();
    _loaddata();
  }

  _loaddata() async {
    final resData = await SnapPeNetworks().getCategory();
    if (resData == null) {
      return;
    }
    category = categoryFromJson(resData);
  }

  Future<List<String>> getCategorySuggestion(String query) async {
    List<String> sku = category!.skuTypes.where((element) {
      final elementLower = element.toLowerCase();
      final queryLower = query.toLowerCase();
      return elementLower.contains(queryLower);
    }).toList();
    return sku;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SnapPeUI().nAppBar("Select Category"),
      body: TypeAheadField<String>(
        suggestionsCallback: (pattern) async =>
            await getCategorySuggestion(pattern),
        itemBuilder: (BuildContext context, itemData) {
          return ListTile(
            title: Text(itemData),
          );
        },
        onSuggestionSelected: (Object? suggestion) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(
                  skuItem: Sku(type: suggestion.toString()))));
        },
      ),
    );
  }
}
