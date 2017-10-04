import 'package:flutter/material.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;
import '../cards/documentCards.dart';
import '../cards/document/package.dart';

class DataPage extends StatefulWidget {
  final String collection;
  final String objID;

  DataPage(this.collection, this.objID);

  @override
  _DataPageState createState() => new _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<Widget> children;

  @override
  void initState(){
    super.initState();
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
      setState((){
        children.clear();
        children.add(getDocumentCard(widget.collection, widget.objID, data: data));
        if (widget.collection == "locations"){
          if (data["packages"] != null){
            data["packages"].forEach((Map<String, dynamic> packageData){
              children.add(new PackageInfoCard(packageData));
            });
          }
        }
      });
    });
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
              Navigator.of(context).pushNamed('/create/${widget.collection}/${widget.objID}');
              // TODO: Refresh.
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