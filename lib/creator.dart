import 'package:flutter/material.dart';
import 'drawer.dart';
import 'cards/creatorCards.dart';



class CreatorPage extends StatefulWidget {
  const CreatorPage();

  @override
  CreatorPageState createState() => new CreatorPageState();
}

class CreatorPageState extends State<CreatorPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget buildAppBar(){
    return new AppBar(
      title: new Text("Creator")
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
      drawer: buildDrawer(context, 'creator'),
      floatingActionButton: buildFAB(),
      body: new Center()
    );
  }
}