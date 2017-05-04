
import 'package:flutter/material.dart';
import '../firebase.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({
    Key key,
    this.initialLocation,
  }) : super(key: key);

  final String initialLocation;

  @override
  _LocationSelectorState createState() => new _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  String _selectedLocation;
  List<ListTile> locationList;
  final GlobalKey _selectorKey = new GlobalKey();

  @override
  void initState(){
    super.initState();
    _selectedLocation = widget.initialLocation;
    getCategory("location").then((locations){
      locations.forEach((String id, Map data){
        setState((){
          locationList.add(new ListTile(
            title: new Text(data["name"]),
            onTap: (){
              Navigator.pop(context, id);
            },
            selected: (id == _selectedLocation)
          ));
        });
      });
    });
  }

  void _onAdd(){
    // TODO:
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
              new ListView(
                children: new List.from(locationList)
              ),
              actions
            ]
          )
        )
      )
    );
  }
}