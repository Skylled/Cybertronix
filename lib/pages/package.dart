import 'package:flutter/material.dart';
import '../drawer.dart';
import '../cards/creatorCards.dart';

class PackageCreatorPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  PackageCreatorPage(this.initialData);

  @override
  _PackageCreatorPageState createState() => new _PackageCreatorPageState();
}

class _PackageCreatorPageState extends State<PackageCreatorPage> {
  List<Widget> children;
  Map<String, dynamic> currentData;

  List<String> components = <String>["panel", "pump", "motor", "jockeypanel", "jockeypump"];

  void changeData(String component, Map<String, dynamic> newData){
    currentData[component] = newData;
  }

  @override
  void initState(){
    super.initState();
    children = <Widget>[];
    currentData = widget.initialData;
    components.forEach((String component){
      children.add(getComponentCard(component, currentData["power"], changeData, componentData: currentData[component]));
    });
    if (currentData["power"] == "Electric"){
      children.add(getComponentCard("tswitch", "Electric", changeData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Package Creator")
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
            Navigator.pop(context, currentData);
          },
        ),
      ],
      drawer: buildDrawer(context, 'creator'),
      body: new ListView(
        // TODO: WillPopScope
        children: new List<Widget>.from(children),
      ),
    );
  }
}