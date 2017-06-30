import 'package:flutter/material.dart';
import '../firebase.dart' as firebase;
import '../cards/creatorCards.dart';

class SelectorDialog extends StatefulWidget {
  const SelectorDialog({
    Key key,
    this.category,
    this.initialObject,
  }) : super(key: key);

  final String category;
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
    Map<String, Map<String, dynamic>> objects = firebase.getCategory(widget.category);
    objects.forEach((String id, Map<String, dynamic> data){
      Map<String, dynamic> obj = new Map<String, dynamic>.from(data);
      obj["id"] = id;
      objList.add(obj);
    });
    // Sort this eventually.
  }

  void _onAdd(){
    showCreatorCard(context, widget.category);
  }

  void _onCancel(){
    Navigator.pop(context);
  }

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
                      Navigator.pop(context, objList[index]["id"]);
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