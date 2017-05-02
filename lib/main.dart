import 'package:flutter/material.dart';
import 'agenda.dart';
import 'browser.dart';

class CybertronixApp extends StatefulWidget {
  @override
  CybertronixAppState createState() => new CybertronixAppState();
}

class CybertronixAppState extends State<CybertronixApp>{
  List _classes = ['annuals', 'contacts', 'customers', 'jobs',
  'locations', 'monthlies', 'packages'];

  Route<Null> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');
    if (path[0] != '')
      return null;
    if (_classes.contains(path[1])){
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
        primarySwatch: Colors.red
      ),
      routes: <String, WidgetBuilder>{
        '/':       (BuildContext context) => new AgendaPage(), // Agenda
        '/browser': (BuildContext context) => new BrowserPage()
        /*  '/reports': (BuildContext context) => new ReportsPage(),
            '/search': (BuildContext context) => new SearchPage(), // Maybe have a search menu in the AppBar
        */
      },
      onGenerateRoute: _getRoute,
    );
  }
}

void main(){
  runApp(new CybertronixApp());
}