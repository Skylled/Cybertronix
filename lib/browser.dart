import 'package:flutter/material.dart';
import 'drawer.dart';

/// A page showing the different categories available to browse
/// 
/// Currently: Jobs, Locations, Customers, Contacts, Annual tests, and Monthly tests
class BrowserPage extends StatefulWidget {
  @override
  _BrowserPageState createState() => new _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage>{
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
            },
            iconSize: 64.0
          ),
          new Text(category)
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
      key: _scaffoldKey,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'browse'),
      body: buildBody()
    );
  }
}