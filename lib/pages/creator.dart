import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;
import '../cards/creatorCards.dart';

class CreatorPage extends StatefulWidget {
  final String collection;
  final String objID;

  CreatorPage(this.collection, [this.objID]);

  @override
  _CreatorPageState createState() => new _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  List<Widget> children;
  Map<String, dynamic> currentData;

  void changeData(Map<String, dynamic> newData){
    List<Map<String, dynamic>> packages = currentData["packages"];
    currentData = newData;
    currentData["packages"] = packages;
  }

  @override
  void initState(){
    super.initState();
    currentData = <String, dynamic>{};
    if (widget.objID != null){
      children = <Widget>[
        new Center(
          child: new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: new CircularProgressIndicator(
              value: null,
            ),
          ),
        ),
      ];
      firebase.getObject(widget.collection, widget.objID).then((Map<String, dynamic> data){
        currentData = data;
        setState((){
          children.clear();
          children.add(getCreatorCard(widget.collection, changeData, objID: widget.objID, data: data));
          if (widget.collection == "locations"){
            if (data["packages"] != null){
              data["packages"].forEach((Map<String, Map<String, dynamic>> packageData){
                //children.add(null); // TODO MAJOR: I need a lot of cards!
              });
            }
          }
        });
      });
    } else {
      children = <Widget>[
        getCreatorCard(widget.collection, changeData),
        getCreatorCard("contacts", changeData)
      ];
      if (widget.collection == "locations"){
        children.add(
          new ListTile(
            title: new Text("Add a package"),
            trailing: new Icon(Icons.add),
            onTap: (){
              // TODO: Hook into power selection.
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${capitalize(widget.collection)} Creator")
      ),
      persistentFooterButtons: <Widget>[
        new FlatButton(
          child: new Text("Cancel"),
          onPressed: (){ Navigator.pop(context); },
        ),
        new FlatButton(
          child: new Text("Save & Finish"),
          textColor: Theme.of(context).accentColor,
          onPressed: (){
            firebase.sendObject("contacts", currentData, objID: widget.objID);
            Navigator.pop(context, currentData);
          },
        ),
      ],
      drawer: buildDrawer(context, 'creator'),
      body: new WillPopScope(
        onWillPop: () async {
          await showDialog<bool>(
            context: context,
            child: new SimpleDialog(
              title: new Text("Are you sure you'd like to close? Your changes will not be saved."),
              children: <Widget>[
                new SimpleDialogOption(
                  onPressed: (){ Navigator.pop(context, true); },
                  child: new Text("Yes"),
                ),
                new SimpleDialogOption(
                  onPressed: (){ Navigator.pop(context, false); },
                  child: new Text("No"),
                ),
              ],
            ),
          );
        },
        child: new ListView(
          children: new List<Widget>.from(children),
        ),
      ),
    );
  }
}