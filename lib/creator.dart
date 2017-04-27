import 'package:flutter/material.dart';
import 'drawer.dart';



class CreatorPage extends StatefulWidget {
  const CreatorPage();

  @override
  CreatorPageState createState() => new CreatorPageState();
}

class CreatorPageState extends State<CreatorPage> with SingleTickerProviderStateMixin {
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

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'creator'),
      body: new Center()
    );
  }
}