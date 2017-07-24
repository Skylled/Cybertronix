import 'package:flutter/material.dart';
import 'agenda.dart';
import 'browser.dart';
import 'category.dart';
import 'firebase.dart' as firebase;

// Upcoming features
// TODO: ImagePicker and FirebaseStorage support.
// TODO: Push notifications (Firebase Cloud Messaging)
// TODO: Add copy support to all Category cards on long-press

/// Cybertronix is a job management software; a work in progress.
class CybertronixApp extends StatefulWidget {
  @override
  _CybertronixAppState createState() => new _CybertronixAppState();
}

class _CybertronixAppState extends State<CybertronixApp> {
  final List<String> _classes = <String>[
    'annuals',
    'contacts',
    'customers',
    'jobs',
    'locations',
    'monthlies',
    'packages'
  ];

  @override
  void initState() {
    super.initState();
    firebase.initDatabase();
  }

  Route<Null> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');
    if (path[0] != '') return null;
    if (path[1] == "browse") {
      return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new CategoryPage(path[2]));
    }
    if (_classes.contains(path[1])) {
      /*return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new DataPage(class: path[1], id: path[2])
      );*/
      return null;
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
      home: new AgendaPage(),
      routes: <String, WidgetBuilder>{
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
