import 'package:flutter/material.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import '../drawer.dart';
import '../cards/documentCards.dart';
import '../cards/document/package.dart';
import 'creator.dart';

class DataPage extends StatefulWidget {
  final String collection;
  final DocumentSnapshot document;

  DataPage(this.collection, this.document);

  @override
  _DataPageState createState() => new _DataPageState();
}

class _DataPageState extends State<DataPage> {
  DocumentSnapshot document;
  List<Widget> children;

  void buildChildren(){
    children.clear();
    children.add(getDocumentCard(widget.collection, document));
    if (widget.collection == "locations"){
      if (document["packages"] != null){
        document["packages"].forEach((DocumentReference packageRef){
          // TODO: FutureBuilder
          packageRef.snapshots.single.then((DocumentSnapshot packageData){
            setState((){
              // TODO: Consider using the summary card here.
              children.add(new PackageInfoCard(packageData));
            });
          });
        });
      }
    }
  }

  @override
  void initState(){
    super.initState();
    document = widget.document;
    children = <Widget>[];
    buildChildren();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Data Browser")
      ),
      drawer: buildDrawer(context, 'collection'),
      persistentFooterButtons: (){
        List<Widget> footer = <Widget>[];
        footer.add(
          new FlatButton(
            child: new Text("Add a photo"),
            onPressed: (){
              // TODO: Hook into photo window.
            },
          )
        );
        footer.add(
          new FlatButton(
            child: new Text("Edit info"),
            onPressed: (){
              Navigator.of(context).push(
                new MaterialPageRoute<DocumentSnapshot>(
                  builder: (BuildContext context) => new CreatorPage(widget.collection)
                ),
              ).then((DocumentSnapshot newSnapshot){
                setState((){
                  buildChildren();
                });
              });
            },
          )
        );
        if (widget.collection == "jobs"){
          footer.add(
            new FlatButton(
              child: new Text("Reports"),
              onPressed: (){},
            )
          );
        }
        return footer;
      }(),
      body: new ListView(
        children: new List<Widget>.from(children),
      ),
    );
  }
}