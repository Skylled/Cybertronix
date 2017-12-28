import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package.dart';
import '../drawer.dart';
import '../cards/creatorCards.dart';

// TODO: MAJOR: Default field values do not get saved!
// Option A: Move default values to currentData.
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
    Map<String, dynamic> package = currentData["package"];
    currentData = newData;
    currentData["package"] = package;
  }

  void changePackage(Map<String, dynamic> newPackage){
    currentData["package"] = newPackage;
  }

  void buildBody(){
    if (widget.snapshot != null) {
      currentData = widget.snapshot.data;
      children = <Widget>[getCreatorCard(widget.collection, changeData)];
      if (widget.collection == "locations"){
        if (currentData["package"] != null){
            Widget packageCard;
            packageCard = new PackageSummaryCard(
              currentData["package"],
              changePackage,
              (){
                currentData["package"] = null;
                children.remove(packageCard);
              },
            );
            children.add(packageCard);
        }
      }
    } else {
      children = <Widget>[
        getCreatorCard(widget.collection, changeData)
      ];
      if (widget.collection == "locations"){
        Widget newPackageTile;
        newPackageTile = new ListTile(
          title: new Text("Add a package"),
          trailing: new Icon(Icons.add),
          onTap: (){
            // TODO: MAJOR: Hook into power selection.
            Navigator.of(context).push(
              new MaterialPageRoute<Map<String, dynamic>>(
                builder: (BuildContext context) => new PackageCreatorPage()
              ),
            ).then((Map<String, dynamic> packageData) {
              currentData["package"] = packageData;
              setState(() {
                Widget card;
                card = new PackageSummaryCard(
                  packageData,
                  changePackage,
                  (){
                    setState((){
                      currentData["package"] = null;
                      children.remove(card);
                    });
                  }
                );
                children.insert(1, card);
                children.remove(newPackageTile);
              });
            });
          },
        );
        children.add(newPackageTile);
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
            widget.removeCallback();
            // Future: Animation to dismiss would be cool!
            // Remember your training, Luke.
          },
        ),
        new FlatButton(
          child: new Text("Edit"),
          onPressed: () {
            setState(() async {
              packageData = await Navigator.push(context, new MaterialPageRoute<Map<String, dynamic>>(
                builder: (BuildContext context) => new PackageCreatorPage(initialData: packageData),
              ));
              widget.changeData(packageData);
              _getLines();
            });
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