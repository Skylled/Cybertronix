import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import '../drawer.dart';
import '../cards/creatorCards.dart';
import 'package:firebase_firestore/firebase_firestore.dart';

class CreatorPage extends StatefulWidget {
  final String collection;
  final DocumentSnapshot snapshot;

  CreatorPage(this.collection, [this.snapshot]);

  @override
  _CreatorPageState createState() => new _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  List<Widget> children;
  Map<String, dynamic> currentData;

  /// This is a callback, passed to cards to affect this widget's state
  void changeData(Map<String, dynamic> newData){
    List<Map<String, dynamic>> packages = currentData["packages"];
    currentData = newData;
    currentData["packages"] = packages;
  }

  void buildBody(){
    if (widget.snapshot != null) {
      currentData = widget.snapshot.data;
      children = <Widget>[getCreatorCard(widget.collection, changeData)];
      if (widget.collection == "locations"){
        if (currentData["packages"] != null){
          currentData["packages"].forEach((Map<String, Map<String, dynamic>> packageData){
            //children.add(); // MAJOR: I need a lot of cards here.
          });
        }
      }
    } else {
      children = <Widget>[
        getCreatorCard(widget.collection, changeData),
        getCreatorCard("contacts", changeData), // This is a debug line
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
  void initState(){
    super.initState();
    currentData = <String, dynamic>{};
    buildBody();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${capitalize(widget.collection)} Creator"),
      ),
      persistentFooterButtons: <Widget>[
        new FlatButton(
          child: new Text("Cancel"),
          onPressed: (){ Navigator.pop(context); },
        ),
        new FlatButton(
          child: new Text("Save & Finish"),
          textColor: Theme.of(context).accentColor,
          onPressed: () async {
            DocumentReference docRef = widget.snapshot != null ?
                Firestore.instance.document(widget.snapshot.path) :
                Firestore.instance.collection(widget.collection).document();
            await docRef.setData(currentData);
            DocumentSnapshot newSnapshot = await docRef.snapshots.first;
            Navigator.pop(context, newSnapshot);
          },
        )
      ],
      drawer: buildDrawer(context, 'creator'),
      body: new WillPopScope(
        // MAJOR: Don't show the onWillPop if popping from Save & Finish
        onWillPop: () async {
          await showDialog<bool>(
            context: context,
            child: new SimpleDialog(
              title: new Text("Your changes have not been saved.\nAre you sure you'd like to leave this page?"),
              children: <Widget>[
                new SimpleDialogOption(
                  onPressed: () { Navigator.pop(context, true); },
                  child: new Text("Yes"),
                ),
                new SimpleDialogOption(
                  onPressed: (){ Navigator.pop(context, false); },
                  child: new Text("No"),
                ),
              ],
            )
          );
        },
        child: new ListView(
          children: new List<Widget>.from(children),
        ),
      ),
    );
  }
}