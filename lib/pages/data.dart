import 'package:flutter/material.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;
import '../cards/categoryCards.dart';
import '../cards/category/package.dart';

class DataPage extends StatefulWidget {
  final String category;
  final String objID;

  DataPage(this.category, this.objID);

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
        child: new CircularProgressIndicator(
          value: null,
        ),
      ),
    ];
    firebase.getObject(widget.category, widget.objID).then((Map<String, dynamic> data){
      setState((){
        children.clear();
        children.add(getCategoryCard(widget.category, widget.objID, data: data));
        if (widget.category == "locations"){
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
      drawer: buildDrawer(context, 'category'),
      body: new ListView(
        children: children,
      )
    );
  }
}