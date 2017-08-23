import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../firebase.dart' as firebase;

/// This [Dialog] loads a list of objects from a
/// category in Firebase, with the [initialObjects]
/// indicating which objects are currently selected.
/// 
/// [Navigator.pop]s with the newly selected data.
class SelectorDialog extends StatefulWidget {
  /// Opens a dialog to select an object from a category
  SelectorDialog({
    Key key,
    this.category,
    List<String> initialObjects,
  }) : this.initialObjects = initialObjects ?? <String>[],
       super(key: key);

  /// The category in Firebase to select from
  final String category;
  /// The object to show as currently selected
  final List<String> initialObjects;

  @override
  _SelectorDialogState createState() => new _SelectorDialogState();
}

class _SelectorDialogState extends State<SelectorDialog> {
  bool returned;
  List<Map<String, dynamic>> objList = <Map<String, dynamic>>[];

  @override
  void initState(){
    super.initState();
    returned = false;
    firebase.getCategory(widget.category).then((Map<String, Map<String, dynamic>> objects){
      setState((){
        returned = true;
        objects.forEach((String id, Map<String, dynamic> data){
          Map<String, dynamic> obj = new Map<String, dynamic>.from(data);
          objList.add(obj);
        });
      });
    });
  }

  Future<Null> _onAdd() async {
    Map<String, dynamic> res = await Navigator.of(context).pushNamed('/create/${widget.category}');
    // If the Creator Card popped with data,
    if (res != null){
      debugPrint("Got data from showCreatorCard");
      debugPrint(res.toString());
      // Pop that data further up the chain.
      Navigator.pop(context, res);
    }
  }

  void _onCancel(){
    Navigator.pop(context);
  }

  // TODO: Pin `actions` to the bottom.

  Widget build(BuildContext context){
    final Widget actions = new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: const Text('Cancel'),
            onPressed: _onCancel,
          ),
          new FlatButton(
            child: const Text("Add new"),
            onPressed: _onAdd,
          )
        ]
      )
    );
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new Column(
          children: (){
            List<Widget> items = <Widget>[];
            if (objList.length < 1){
              if (returned){
                items.add(new ListTile(
                  title: new Text("No results found.")
                ));
              } else {
                items.add(new ListTile(
                  title: new Text("Loading...")
                ));
              }
            } else {
              items.add(new ListView.builder(
                shrinkWrap: true,
                itemCount: objList.length,
                itemBuilder: (BuildContext context, int index){
                  return new ListTile(
                    title: new Text(objList[index]["name"]),
                    onTap: (){
                      Navigator.pop(context, objList[index]);
                    },
                    selected: (widget.initialObjects.contains(objList[index]["id"]))
                  );
                },
              ));
            }
            items.add(actions);
            return items;
          }(),
        )
      )
    );
  }
}