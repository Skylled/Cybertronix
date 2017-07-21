import 'dart:async';
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
  Map<String, dynamic> jobData;
  Map<String, dynamic> locationData;
  Map<String, Map<String, dynamic>> userData;
  Map<String, Map<String, dynamic>> contactData;

  void goEdit(BuildContext context) {
    showCreatorCard(context, "jobs", data: jobData, objID: widget.jobID).then((dynamic x){
      if (x is Map){
        jobData = x;
        List<Future<dynamic>> futures = <Future<dynamic>>[getLocationData(), getContactData(), getUserData()];
        Future.wait(futures).then((List<dynamic> results){
          locationData = results[0];
          contactData = results[1];
          userData = results[2];
          setState((){ populateLines(); });
        });
      }
    });
  }

  void populateLines (){
    cardLines.clear();
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
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
                jobData["name"],
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
    if (jobData["datetime"] != null ){
      cardLines.add(
        new ListTile(
            leading: new Icon(Icons.access_time),
            title:
                new Text(formatter.format(DateTime.parse(jobData["datetime"])))),
      );
    }

    if (locationData != null) {
      String address =
        '${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}';
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
            showCategoryCard(context, "locations", jobData["location"],
                data: locationData);
          },
        ),
      );
    }

    if (contactData != null) {
      cardLines.add(new Divider());
      contactData.forEach((String contactID, Map<String, dynamic> contact){
        Widget trailing = (contact["phone"] != null) ?
                            new IconButton(
                              icon: new Icon(Icons.phone),
                              onPressed: (){
                                url_launcher.launch('tel:${contact["phone"]}');
                              })
                            : null;
        cardLines.add(
          new ListTile(
            title: new Text(contact["name"]),
            trailing: trailing,
            onTap: (){
              showCategoryCard(context, "contacts", contactID, data: contact);
            },
          )
        );
      });
    }

    if (userData != null) {
      cardLines.add(new Divider());
      List<Widget> assigned = <Widget>[];
      userData.forEach(
        (String userID, Map<String, dynamic> user){
          assigned.add(
            new ListTile(
              title: new Text("${user["name"]}"),
              /*onTap: (){
                showCategoryCard(context, "users", userID);
              },*/
            )
          );
        }
      );
      cardLines.add(new ExpansionTile(
        title: new Text("Employees assigned"),
        children: assigned
      ));
    }
  }

  Future<Map<String, Map<String, dynamic>>> getUserData() async {
    if (jobData["users"] != null){
      Map<String, Map<String, dynamic>> users = new Map<String, Map<String, dynamic>>();
      for (String userID in jobData["users"]){
        users[userID] = await firebase.getObject("users", userID);
      }
      return users;
    } else {
      return null;
    }
  }
  // Map<contactID, <key, value>>
  Future<Map<String, Map<String, dynamic>>> getContactData() async {
    if (jobData["contacts"] != null) {
      Map<String, Map<String, dynamic>> contacts = new Map<String, Map<String, dynamic>>();
      for (String contactID in jobData["contacts"]){
        // Future: Thread better, using Future.wait
        contacts[contactID] = await firebase.getObject("contacts", contactID);
      }
      return contacts;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getLocationData() async {
    if (jobData["location"] != null){
      return await firebase.getObject("locations", jobData["location"]);
    } else {
      return null;
    }
  }

  @override
  void initState(){
    super.initState();
    jobData = widget.jobData;
    List<Future<dynamic>> futures = <Future<dynamic>>[getLocationData(), getContactData(), getUserData()];
    Future.wait(futures).then((List<dynamic> results){
      locationData = results[0];
      contactData = results[1];
      userData = results[2];
      setState((){ populateLines(); });
    });
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
