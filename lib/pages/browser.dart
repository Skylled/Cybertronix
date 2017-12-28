import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
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
              Navigator.pushNamed(context, '/browse/$collection');
            },
            iconSize: 60.0
          ),
          new Text(capitalize(collection))
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
        buildIconTile("jobs", Icons.business_center),
        buildIconTile("locations", Icons.place),
        buildIconTile("customers", Icons.assignment),
        buildIconTile("contacts", Icons.contacts),
        buildIconTile("annuals", Icons.event),
        buildIconTile("monthlies", Icons.calendar_today)
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