import 'package:flutter/material.dart';
import '../drawer.dart';

/// A page showing the different collections available to browse
/// 
/// Currently: Jobs, Locations, Customers, Contacts, Annual tests, and Monthly tests
class BrowserPage extends StatefulWidget {
  @override
  _BrowserPageState createState() => new _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage>{

  @override
  void initState() {
    super.initState();
  }

  Widget buildAppBar(){
    return new AppBar(
      title: new Text("Data Browser")
    );
  }

  GridTile buildIconTile(String collection, IconData icon){
    return new GridTile(
      child: new Column( 
        children: <Widget>[
          new IconButton(
            icon: new Icon(icon),
            onPressed: () {
              Navigator.pushNamed(context, '/browse/${collection.toLowerCase()}');
            },
            iconSize: 60.0
          ),
          new Text(collection)
        ]
      ),
    );
  }

  Widget buildBody(){
    return new GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      padding: const EdgeInsets.all(4.0),
      children: <GridTile>[
        buildIconTile("Jobs", Icons.business_center),
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
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'browse'),
      body: buildBody()
    );
  }
}