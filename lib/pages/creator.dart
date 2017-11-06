import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import '../cards/creatorCards.dart';

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
  bool saved = false;

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
            children.add(
              new PackageSummaryCard(
                packageData,
                changeData,
                (){ currentData["packages"].remove(packageData); },
              ),
            );
          });
        }
        // TODO: "Add a package" option here.
      }
    } else {
      children = <Widget>[
        getCreatorCard(widget.collection, changeData)
      ];
      if (widget.collection == "locations"){
        children.add(
          new ListTile(
            title: new Text("Add a package"),
            trailing: new Icon(Icons.add),
            onTap: (){
              // TODO: Hook into power selection.
              // TODO: MAJOR: I need to refresh this page to add a summary card, to reflect the change made.
              // setState((){ children.add( new PackageSummaryCard() ); });
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
                widget.snapshot.reference :
                Firestore.instance.collection(widget.collection).document();
            await docRef.setData(currentData);
            DocumentSnapshot newSnapshot = await docRef.snapshots.first;
            saved = true;
            Navigator.pop(context, newSnapshot);
          },
        )
      ],
      drawer: buildDrawer(context, 'creator'),
      body: new WillPopScope(
        onWillPop: () async {
          if (saved) return true; // Don't show the dialog on Save & Quit
          return await showDialog<bool>(
            context: context,
            child: new SimpleDialog(
              // TODO: This dialog is kinda uggo. Adjust text sizes maybe?
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

class PackageSummaryCard extends StatefulWidget{
  final Map<String, dynamic> packageData;
  final Function(Map<String, dynamic>) changeData;
  final Function() removeCallback;

  PackageSummaryCard(this.packageData, this.changeData, this.removeCallback);

  @override
  _PackageSummaryCardState createState() => new _PackageSummaryCardState();
}

class _PackageSummaryCardState extends State<PackageSummaryCard>{
  Map<String, dynamic> packageData;

  @override
  void initState(){
    super.initState();
    packageData = widget.packageData;
  }

  List<Widget> _getLines(){
    List<Widget> lines = <Widget>[];
    if (packageData["panel"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["panel"]["manufacturer"]} ${packageData["power"]}")
      ));
      if (packageData["power"] == "Electric" && packageData["tswitch" != null]){
        lines.add(new ListTile(
          title: new Text("with Transfer Switch")
        ));
      }
    }
    if (packageData["motor"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["motor"]["manufacturer"]} ${packageData["power"] == "Diesel" ? "Engine" : "Motor"}"),
      ));
    }
    if (packageData["pump"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["pump"]["manufacturer"]}")
      ));
    }
    if (packageData["jockeypanel"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["jockeypanel"]["manufacturer"]} Jockey")
      ));
    }
    if (packageData["jockeypump"] != null){
      lines.add(new ListTile(
        title: new Text("${packageData["jockeypump"]["manufacturer"]} Jockey Pump")
      ));
    }
    lines.add(new ButtonBar(
      children: <Widget>[
        new FlatButton(
          child: new Text("Remove"),
          onPressed: () {
            // TODO: Popup Confirmation
            // TODO: Dismiss the card
            // Future: Animation to dismiss would be cool!
            // TODO: Remove the package from the location.
          },
        ),
        new FlatButton(
          child: new Text("Edit"),
          onPressed: () async {
            // TODO: Navigator.Push a package editor route
            //await Navigator.push(context, new MaterialPageRoute());
          },
        )
      ],
    ));
    return lines;
  }

  @override
  Widget build(BuildContext build){
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: new Card(
        child: new Column(
          children: _getLines()
        ),
      ),
    );
  }
}