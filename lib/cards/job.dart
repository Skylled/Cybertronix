import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../firebase.dart';

// TODO: Use actual data, not filler data.
Widget buildJobCard(String id, Map<String, dynamic> jobData){
  DateFormat formatter = new DateFormat('jm EEEE, MMMM d');
  Map<String, dynamic> locationData;
  getLocation(jobData["location"]).then((loc) {
    locationData = loc;
  });
  String address = '${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}';
  List<Widget> cardLines = [
    new Image( // TODO: Text over image, maybe from Contacts demo
      image: new AssetImage('assets/face-bradon.jpg')
    ),
    new ListTile(
      leading: new Icon(Icons.access_time),
      title: new Text(formatter.format(jobData["datetime"]))
    ),
    new ListTile(
      title: new Text(address),
      trailing: new IconButton(
        icon: new Icon(Icons.navigation),
        onPressed: () {
          url_launcher.launch('google.navigation:q=$address');
        }
      )
    ),
    new Divider()
  ];
  jobData["contacts"].forEach((contactId) {
    Map<String, dynamic> contactData;
    getContact(contactId).then((con) {
      contactData = con;
    });
    cardLines.add(new ListTile(
      title: new Text(contactData["name"]),
      trailing: new IconButton(
        icon: new Icon(Icons.phone),
        onPressed: (){
          url_launcher.launch('tel:${contactData["phone"]}');
        }
      ),
      onTap: () {} // TODO: Launch a contact details card.
    ));
  });
  cardLines.add(new ButtonTheme.bar(
    child: new ButtonBar(
      children: <Widget>[
        new FlatButton(
          child: new Text('Reports'),
          onPressed: () {}
        ),
        new FlatButton(
          child: new Text('More info'),
          onPressed: () {}
        ),
      ]
    )
  ));

  return new Container(
    padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
    child: new Card(
      child: new ListView(
        children: cardLines
      )
    )
  );
}