import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../categoryCards.dart';

class JobInfoCard extends StatefulWidget {
  final String jobID;
  final Map<String, dynamic> jobData;

  JobInfoCard(String jobID, {Map<String, dynamic> jobData}):
    this.jobID = jobID,
    this.jobData = (jobData == null && jobID != null) ? firebase.getObject("jobs", jobID) : jobData;
  
  @override
  _JobInfoCardState createState() => new _JobInfoCardState();
}

class _JobInfoCardState extends State<JobInfoCard> {

  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showCreatorCard(context, "jobs", data: widget.jobData);
  }

  void populateLines (){
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
    Map<String, dynamic> locationData = firebase.getObject("locations", widget.jobData["location"]);
    String address = '${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}';
    cardLines.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: new Image(
                image: new AssetImage('assets/placeholder.jpg')
              )
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                widget.jobData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                ))
            )
          ]
        )
      )
    );
    cardLines.add(
      new ListTile(
        leading: new Icon(Icons.access_time),
        title: new Text(formatter.format(DateTime.parse(widget.jobData["datetime"])))
      )
    );
    cardLines.add(
      new ListTile(
        title: new Text(address),
        trailing: new IconButton(
          icon: new Icon(Icons.navigation),
          onPressed: () {
            url_launcher.launch('google.navigation:q=$address');
          }
        ),
        onTap: (){
          showCategoryCard(context, "locations", widget.jobData["location"], data: locationData);
        }
      )
    );
    cardLines.add(new Divider());
    if (widget.jobData["contacts"] != null) {
      widget.jobData["contacts"].forEach((String contactID) {
        Map<String, dynamic> contactData = firebase.getObject("contacts", contactID);
        Widget trailing = (contactData["phone"] != null) ? new IconButton(icon: new Icon(Icons.phone),
                                                                          onPressed: (){ url_launcher.launch('tel:${contactData["phone"]}'); }) 
                                                         : null;
        cardLines.add(new ListTile(
          title: new Text(contactData["name"]),
          trailing: trailing,
          onTap: () {
            showCategoryCard(context, "contacts", contactID, data: contactData);
          }
        ));
      });
    }
    cardLines.add(new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: new Text('Edit info'),
            onPressed: () {
              goEdit(context);
            }
          ),
          new FlatButton(
            child: new Text('Reports'),
            onPressed: () {}
          ),
        ]
      )
    ));
  }

  @override
  void initState(){
    super.initState();
    populateLines();
  }

  @override
  Widget build(BuildContext context){
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ListView(
          children: new List<Widget>.from(cardLines)
        )
      )
    );
  }
}