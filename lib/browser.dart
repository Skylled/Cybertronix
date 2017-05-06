import 'package:flutter/material.dart';
import 'drawer.dart';

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

  GridTile buildIconTile(String category, IconData icon){
    return new GridTile(
      child: new Column( 
        children: <Widget>[
          new IconButton(
            icon: new Icon(icon),
            onPressed: () {
              Navigator.pushNamed(context, '/browse/${category.toLowerCase()}');
            }
          ),
          new Text(category)
        ]
      ),
    );
  }

  Widget buildBody(){
    return new GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      children: <GridTile>[
        buildIconTile("Jobs", Icons.work),
        buildIconTile("Locations", Icons.place),
        buildIconTile("Customers", Icons.assignment),
        buildIconTile("Contacts", Icons.contacts),
        buildIconTile("Annuals", Icons.event),
        buildIconTile("Monthlies", Icons.calendar_today)
      ]
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'browse'),
      body: buildBody()
    );
  }
}