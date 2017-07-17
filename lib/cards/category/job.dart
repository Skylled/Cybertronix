import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../categoryCards.dart';

/// A Material Card with a job's info
/// 
/// Usually used with [showDialog]
class JobInfoCard extends StatefulWidget {
  /// The job's ID in Firebase
  final String jobID;
  /// The job data stored in Firebase
  final Map<String, dynamic> jobData;

  /// A Material Card with a job's info
  JobInfoCard(this.jobID, {this.jobData});

  @override
  _JobInfoCardState createState() => new _JobInfoCardState();
}

class _JobInfoCardState extends State<JobInfoCard> {
  List<Widget> cardLines = <Widget>[];
  Map<String, dynamic> locationData;

  // TODO: .then() instead of await
  void goEdit(BuildContext context) {
    showCreatorCard(context, "jobs", data: widget.jobData).then((dynamic x){
      setState((){
        populateLines();
      });
    });
  }

  void populateLines (){
    cardLines = <Widget>[];
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
    String address =
        '${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}';
    cardLines.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
                child: new Image.asset('assets/placeholder.jpg',
                    fit: BoxFit.fitWidth)),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                widget.jobData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    cardLines.add(
      new ListTile(
          leading: new Icon(Icons.access_time),
          title:
              new Text(formatter.format(DateTime.parse(widget.jobData["datetime"])))),
    );
    if (locationData != null) {
      cardLines.add(
        new ListTile(
          title: new Text(locationData["name"]),
          subtitle: new Text(address),
          trailing: new IconButton(
            icon: new Icon(Icons.navigation),
            onPressed: () {
              url_launcher.launch('google.navigation:q=$address');
            },
          ),
          onTap: () {
            showCategoryCard(context, "locations", widget.jobData["location"],
                data: locationData);
          },
        ),
      );
    }
    cardLines.add(new Divider());
    if (widget.jobData["contacts"] != null) {
      widget.jobData["contacts"].forEach((String contactID) {
        firebase
            .getObject("contacts", contactID)
            .then((Map<String, dynamic> contactData) {
          setState(() {
            Widget trailing = (contactData["phone"] != null)
                ? new IconButton(
                    icon: new Icon(Icons.phone),
                    onPressed: () {
                      url_launcher.launch('tel:${contactData["phone"]}');
                    })
                : null;
            cardLines.insert(
                cardLines.length - 1,
                new ListTile(
                  title: new Text(contactData["name"]),
                  trailing: trailing,
                  onTap: () {
                    showCategoryCard(context, "contacts", contactID,
                        data: contactData);
                  },
                ));
          });
        });
      });
    }
  }

  @override
  void initState(){
    super.initState();
    if (widget.jobData["location"] != null){
      firebase.getObject("locations", widget.jobData["location"]).then((Map<String, dynamic> data){
        locationData = data;
        populateLines();
      });
    } else {
      populateLines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new Column(
          children: <Widget>[
            new ListView(
              children: new List<Widget>.from(cardLines),
              shrinkWrap: true,
            ),
            new ButtonTheme.bar(
              child: new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: new Text('Edit info'),
                    onPressed: () {
                      goEdit(context);
                    },
                  ),
                  new FlatButton(
                    child: new Text('Reports'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
