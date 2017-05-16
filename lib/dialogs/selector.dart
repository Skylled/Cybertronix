
import 'package:flutter/material.dart';
import '../firebase.dart';
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

  @override
  void initState(){
    super.initState();
    _selectedID = widget.initialObject;
    getCategory(widget.category).then((Map<String, Map<String, dynamic>> objects){
      objects.forEach((String id, Map<String, dynamic> data){
        setState((){
          objectList.add(new ListTile(
            title: new Text(data["name"]),
            onTap: (){
              Navigator.pop(context, id);
            },
            selected: (id == _selectedID)
          ));
        });
      });
    });
  }

  void _onAdd(){
    showDialog(
      context: context,
      child: new CreatorCard(widget.category)
    );
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
              new Column(
                children: new List<Widget>.from(objectList)
              ),
              actions
            ]
          )
        )
      )
    );
  }
}