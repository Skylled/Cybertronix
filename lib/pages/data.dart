import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import '../cards/documentCards.dart';
import '../cards/document/package.dart';
import 'creator.dart';

class DataPage extends StatefulWidget {
  final String collection;
  final DocumentReference reference;

  DataPage(this.collection, this.reference);

  @override
  _DataPageState createState() => new _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<DocumentSnapshot>(
      stream: widget.reference.snapshots,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if (!snapshot.hasData) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Data Viewer"),
            ),
            drawer: buildDrawer(context, 'document'),
            body: new Card(
              child: new Center(
                child: new Text("Loading..."),
              ),
            ),
          );
        }
        DocumentSnapshot document = snapshot.data;
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Data Viewer"),
          ),
          drawer: buildDrawer(context, 'document'),
          persistentFooterButtons: (){
            List<Widget> footer = <Widget>[];
            footer.add(
              new FlatButton(
                child: new Text("Add a photo"),
                onPressed: (){
                  // TODO: Hook into photo window.
                },
              ),
            );
            footer.add(
              new FlatButton(
                child: new Text("Edit info"),
                onPressed: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new CreatorPage(widget.collection, document),
                    ),
                  );
                },
              ),
            );
            if (widget.collection == "jobs"){
              footer.add(
                new FlatButton(
                  child: new Text("Reports"),
                  onPressed: (){},
                ),
              );
            }
            return footer;
          }(),
          body: new ListView(
            children: (){
              List<Widget> children = <Widget>[];
              children.add(getDocumentCard(widget.collection, document));
              if (widget.collection == "locations"){
                if (document["package"] != null){
                  children.add(new PackageInfoCard(document["package"]));
                }
              }
              return children;
            }(),
          )
        );
      },
    );
  }
}