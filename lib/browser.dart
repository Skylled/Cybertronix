import 'package:flutter/material.dart';
import 'drawer.dart';
import 'cards/creatorCards.dart';

// TODO: This page will be contain a Grid of categories

class BrowserPage extends StatefulWidget {
  const BrowserPage();

  @override
  BrowserPageState createState() => new BrowserPageState();
}

class BrowserPageState extends State<BrowserPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget buildAppBar(){
    return new AppBar(
      title: new Text("Browser")
    );
  }

  Widget buildFAB(){
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          child: new CreatorCard("job")
        );
      }
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'browser'),
      floatingActionButton: buildFAB(),
      body: new Center()
    );
  }
}