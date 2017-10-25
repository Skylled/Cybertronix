import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import '../drawer.dart';

/// This is a page that lists all items in a collection,
/// for selection purposes.
class SelectorPage extends StatefulWidget{
  /// A page that lists all items in a collection.
  SelectorPage(this.collection, [List<DocumentReference> initialObjects]):
    this.initialObjects = initialObjects ?? <DocumentReference>[];
  
  /// The collection to load objects from.
  final String collection;

  /// A list of objects already selected from this list.
  final List<DocumentReference> initialObjects;

  @override
  _SelectorPageState createState() => new _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage>{
  List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

  Widget buildAppBar(){
    return new AppBar(
      title: new Text("Select from ${capitalize(widget.collection)}"),
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
        Navigator.of(context).pushNamed('/create/${widget.collection}}').then((Map<String, dynamic> res){
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
    String sort;
    switch (widget.collection){
      case "jobs":
        sort = "datetime";
        break;
      default:
        sort = "name";
        break;
    }

    return new Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'selector'),
      floatingActionButton: buildFAB(),
      body: new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(widget.collection).orderBy(sort).snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (!snapshot.hasData) return new Text("Loading...");
          return new ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new ListTile(
                leading: (){
                  switch (widget.collection){
                    case 'jobs':
                      return new _JobLeadIcon(document);
                    default:
                      return null;
                  }
                }(),
                title: new Text(document["name"]),
                onTap: (){
                  Navigator.of(context).pop(document);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}