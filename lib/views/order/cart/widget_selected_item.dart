import 'package:flutter/material.dart';
import '../../../models/model_catalogue.dart';

class WidgetSelectedItem extends StatefulWidget {
  final Sku sku;
  const WidgetSelectedItem({Key? key, required this.sku}) : super(key: key);

  @override
  _WidgetSelectedItemState createState() => _WidgetSelectedItemState();
}

class _WidgetSelectedItemState extends State<WidgetSelectedItem> {
  @override
  Widget build(BuildContext context) {
    int _itemCount = 1;

    return ListTile(
      leading: Image.network("${widget.sku.images![0].imageUrl}"),
      title: Text("${widget.sku.displayName!}"),
      subtitle: Text(
        "Price : ₹${widget.sku.sellingPrice!}",
        style: TextStyle(color: Colors.lightGreen),
      ),
      trailing: SizedBox(
        width: 106,
        child: Row(
          children: <Widget>[
            _itemCount != 0
                ? _itemCount == 1
                    ? new IconButton(
                        icon: new Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(() {
                          //skuList.remove(sku);
                        }),
                      )
                    : new IconButton(
                        icon: new Icon(Icons.remove),
                        onPressed: () => setState(() {
                          _itemCount--;
                          print(_itemCount);
                        }),
                      )
                : new Container(),
            new Text(_itemCount.toString()),
            new IconButton(
                icon: new Icon(Icons.add),
                onPressed: () => setState(() {
                      _itemCount++;
                      print(_itemCount);
                    }))
          ],
        ),
      ),
    );
  }
}
