import 'package:flutter/material.dart';

Drawer buildDrawer(BuildContext context, String currentPage) {
  void goAgenda(){
    if (currentPage == "agenda"){
      Navigator.pop(context);
    } else {
      Navigator.popAndPushNamed(context, '/');
    }
  }

  void goCreator(){
    if (currentPage == "creator"){
      Navigator.pop(context);
    } else {
      Navigator.popAndPushNamed(context, '/creator');
    }
  }

  return new Drawer(
    child: new ListView(
      children: <Widget>[
        new DrawerHeader(
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: new Center(
            child: new Text('TO-DO')
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.calendar_today),
          selected: (currentPage == 'agenda'),
          title: new Text('Agenda'),
          onTap: goAgenda,
        ),
        new ListTile(
          leading: new Icon(Icons.add_a_photo), // TODO: Verify this icon
          selected: (currentPage == "creator"),
          title: new Text("Creator"),
          onTap: goCreator
        )
      ],
    ),
  );
}