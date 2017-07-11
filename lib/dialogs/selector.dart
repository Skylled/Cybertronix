import 'package:flutter/material.dart';
import '../firebase.dart' as firebase;
import '../cards/creatorCards.dart';

/// This [Dialog] loads a list of objects from a
/// category in Firebase, with the [initialObject]
/// indicating which object is currently selected.
/// 
/// [Navigator.pop]s with the newly selected data.
class SelectorDialog extends StatefulWidget {
  /// Opens a dialog to select an object from a category
  const SelectorDialog({
    Key key,
    this.category,
    this.initialObject,
  }) : super(key: key);

  /// The category in Firebase to select from
  final String category;
  /// The object to show as currently selected
  final String initialObject;

  @override
  _SelectorDialogState createState() => new _SelectorDialogState();
}

class _SelectorDialogState extends State<SelectorDialog> {
  String _selectedID;
  List<ListTile> objectList = <ListTile>[];
  List<Map<String, dynamic>> objList = <Map<String, dynamic>>[];

  @override
  void initState(){
    super.initState();
    _selectedID = widget.initialObject;
    firebase.getCategory(widget.category).then((Map<String, Map<String, dynamic>> objects){
      objects.forEach((String id, Map<String, dynamic> data){
        Map<String, dynamic> obj = new Map<String, dynamic>.from(data);
        obj["id"] = id;
        objList.add(obj);
      });
    });
  }

  void _onAdd(){
    showCreatorCard(context, widget.category);
  }

  void _onCancel(){
    Navigator.pop(context);
  }

  Widget build(BuildContext context){
    // TODO: I removed `actions` from this widget, for debugging.
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
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
                  return new ListTile(
                    title: new Text(objList[index]["name"]),
                    onTap: (){
                      Navigator.pop(context, objList[index]);
                    },
                    selected: (objList[index]["id"] == _selectedID)
                  );
                },
              ),
              actions
            ],
          ),
        ),
      ),
    );
  }
}