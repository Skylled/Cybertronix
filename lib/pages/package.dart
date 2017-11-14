import 'package:flutter/material.dart';
import '../drawer.dart';
import '../cards/creatorCards.dart';

// Cheers to https://flutter.io/catalog/samples/tabbed-app-bar/

class PackageCreatorPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  PackageCreatorPage({Map<String, dynamic> initialData}):
    this.initialData = initialData ?? <String, dynamic>{};

  @override
  _PackageCreatorPageState createState() => new _PackageCreatorPageState();
}

class _PackageCreatorPageState extends State<PackageCreatorPage> {
  List<Widget> children;
  Map<String, dynamic> currentData;
  bool saved = false;

  // TODO: Find a way to add tswitch to the mix.
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
    return new DefaultTabController(
      length: components.length,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Package Creator"),
          bottom: new TabBar(
            isScrollable: true,
            tabs: components.map((String component) {
              return new Tab(text: component);
            }).toList(),
          ),
        ),
        persistentFooterButtons: <Widget>[
          new FlatButton(
            child: new Text("Cancel"),
            onPressed: (){ Navigator.pop(context); },
          ),
          new FlatButton(
            child: new Text("Finish"),
            textColor: Theme.of(context).accentColor,
            onPressed: (){
              saved = true;
              Navigator.pop(context, currentData);
            },
          ),
        ],
        drawer: buildDrawer(context, 'creator'),
        body: new WillPopScope(
          onWillPop: () async {
            if (saved) return true;
            return await showDialog<bool>(
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
          child: new TabBarView(
            children: components.map((String component){
              return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: getComponentCard(component, currentData["power"], changeData),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}