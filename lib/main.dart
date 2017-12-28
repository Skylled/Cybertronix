import 'package:flutter/material.dart';
import 'pages/agenda.dart';
import 'pages/browser.dart';
import 'pages/collection.dart';
import 'pages/creator.dart';
import 'pages/login.dart';

// Upcoming features
// TODO: Make a pretty looking "Today" page
// TODO: Job names are redundant.
// New format: $date $action $location
// TODO: I want a photo manager window.
// TODO: I need to make sure I verify required fields.

// Wishlist
// Future: Use assertions anywhere that I receive data from Firestore.
// Future: I'd like CollectionCards to pop up from the bottom, maybe.
// Future: Generate CreatorCard boilerplate from a JSON or something.

/// Cybertronix is a job management software; a work in progress.
class CybertronixApp extends StatefulWidget {
  @override
  _CybertronixAppState createState() => new _CybertronixAppState();
}

class _CybertronixAppState extends State<CybertronixApp> {

  Route<dynamic> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');
    if (path[0] != '') return null;
    if (path[1] == "browse") {
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new CollectionPage(path[2])
      );
    } else if (path[1] == "create") {
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new CreatorPage(path[2]),
        fullscreenDialog: true,
      );
    }
    return null;
  }

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cybertronix',
      theme: new ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
      ),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        '/agenda': (BuildContext context) => new AgendaPage(),
        '/browse': (BuildContext context) => new BrowserPage()
        /*  '/reports': (BuildContext context) => new ReportsPage(),
            '/search': (BuildContext context) => new SearchPage(), // Maybe have a search menu in the AppBar
        */
      },
      onGenerateRoute: _getRoute,
    );
  }
}

void main() {
  runApp(new CybertronixApp());
}
