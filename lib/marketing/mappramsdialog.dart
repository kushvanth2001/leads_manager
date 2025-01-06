import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'addpromotionsfunctions.dart';

class MapPramsDialog extends StatefulWidget {
 final   List<String> matchedPatterns ;
  final  String msgstring ;
 final Function(Map<String,dynamic>,List<String>) setprams;
 final Function(String) setmsgstring;
 final dynamic dynamicparams;

  MapPramsDialog( {Key? key,required this.msgstring, required this.matchedPatterns, required this.setprams,required this.dynamicparams, required this.setmsgstring}) : super(key: key);

  @override
  State<MapPramsDialog> createState() => _MapPramsDialogState();
}

                    
class _MapPramsDialogState extends State<MapPramsDialog> {
  List<bool> _isdropdownType = [];
  List<DropDownValueModel> _dynamicdropdown = [];
  Map<String, dynamic> _constmap = {};
  Map<String, dynamic> _dynamicmap = {};
  Map<String, dynamic> _finalmap = {};
 final List<String> types=[];
  @override
  void initState() {
    super.initState();
    _isdropdownType =
        List.generate(widget.matchedPatterns.length, (index) => true);
    print(widget.dynamicparams);
    for (int i = 0; i < widget.dynamicparams.length; i++) {
      _dynamicdropdown.add(
        DropDownValueModel(
          name: widget.dynamicparams[i],
          value: widget.dynamicparams[i],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Matched Patterns'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.matchedPatterns.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 4,
              child: ExpansionTile(
                title: Text(widget.matchedPatterns[index]),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: SizedBox(
                      width: 200,
                      height: 100,
                      child: DropDownTextField(
                        clearOption: false,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Select a const value"),
                        ),
                        dropDownList: [
                          DropDownValueModel(
                            name: "Select a const value",
                            value: true,
                          ),
                          DropDownValueModel(
                            name: "Select from headers",
                            value: false,
                          ),
                        ],
                        onChanged: (value) {
                          if (value.value != null) {
                            setState(() {
                              _isdropdownType[index] = value.value;
                              print(value.value);
                              print(_isdropdownType[index]);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  _isdropdownType[index] == false
                      ? SizedBox(
                          width: 200,
                          height: 80,
                          child: DropDownTextField(
                              clearOption: false,
                            textFieldDecoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text("Select value from Column"),
                            ),
                            dropDownList: _dynamicdropdown,
                            onChanged: (value) {
                              setState(() {
                                _dynamicmap[widget.matchedPatterns[index]] =
                                    value.value;
                              });
                            },
                          ),
                        )
                      : SizedBox(
                          width: 200,
                          height: 80,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _constmap[widget.matchedPatterns[index]] = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Select value From list",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // Call a function to process the data after all setState operations are completed
            processFinalData();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  // Function to process the data after all setState operations are completed
  void processFinalData() {
    setState(() {
      _finalmap.clear();

      for (int i = 0; i < widget.matchedPatterns.length; i++) {
        if (_isdropdownType[i] == true) {
          _finalmap[widget.matchedPatterns[i]] = _constmap[widget.matchedPatterns[i]];
          types.add("constantValue");
          
        } else {
          _finalmap[widget.matchedPatterns[i]] = _dynamicmap[widget.matchedPatterns[i]];
          types.add('columnValue');
        }
      }

      // Send the gathered data back to the parent widget
      widget.setprams(_finalmap,types);
   String s= AddPromotionsFunctions.replaceMapPatterns(_finalmap ,widget.msgstring);
   print(s);
   widget.setmsgstring(s);

      Navigator.of(context).pop();
    });
  }

}

class ParamsModel {
  String label;
  String value;

  ParamsModel({required this.label, required this.value});
}
