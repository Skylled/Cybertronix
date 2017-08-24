import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;

/// This is a page that lists all items in a category.
/// 
/// It pulls the data using [firebase.getCategory] and
/// slaps it in a [ListView]
class SelectorPage extends StatefulWidget{
  /// A page that lists all items in a category.
  SelectorPage(this.category, [List<String> initialObjects]):
    this.initialObjects = initialObjects ?? <String>[];
  
  /// The category to load objects from.
  final String category;
  final List<String> initialObjects;

  @override
  _SelectorPageState createState() => new _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage>{
  List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    generateObjects();
  }

  void generateObjects(){
    firebase.getCategory(widget.category).then((Map<String, Map<String, dynamic>> objs){
      setState((){
        objects = <Map<String, dynamic>>[];
        objs.forEach((String id, Map<String, dynamic> data){
          objects.add(data);
        });
      });
    });
  }

  Widget buildAppBar(){
    return new AppBar(
      title: new Text("Select a ${capitalize(widget.category).substring(0, widget.category.length - 2)}"),
      // locations -> Locations -> Location
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: (){
            // Future: Implement Elastic Search?
          },
        ),
      ],
    );
  }

  Widget buildFAB(){
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: (){
        Navigator.of(context).pushNamed('/create/${widget.category}}').then((Map<String, dynamic> res){
          if (res != null) { // If CreatorPage popped with data
            debugPrint("Got data from CreatorPage");
            debugPrint(res.toString());
            // Pop that data further up the chain.
            Navigator.of(context).pop(res);
          }
        });
      }
    );
  }

  Widget build(BuildContext context){
    // TODO: Make sure this object has the correct length upon regeneration
    // See: buildFAB
    List<Map<String, dynamic>> buildObjs = new List<Map<String, dynamic>>.from(objects);
    return new Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'selector'),
      floatingActionButton: buildFAB(),
      body: new ListView.builder(
        itemCount: buildObjs.length,
        itemBuilder: (BuildContext context, int index){
          return new ListTile(
            title: new Text(buildObjs[index]["name"]),
            onTap: (){
              Navigator.of(context).pop(buildObjs[index]);
            },
            selected: widget.initialObjects.contains(buildObjs[index]["id"]),
          );
        },
      ),
    );
  }
}