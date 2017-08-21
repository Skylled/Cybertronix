import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';

import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../../api.dart' as api;

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

  // TODO MAJOR: The dialog does not refresh well.
  // Also, the image does not seem to show up in the view unless exited and re-opened.
  // Could have something to do with the upload speed. Will test in release build on wifi.
  Future<Null> goPhotos() async {
    File imageFile = await ImagePicker.pickImage();
    String uploadCategory;
    if (locationData != null){
      uploadCategory = await showDialog<String>(
        context: context,
        child: new SimpleDialog(
          title: new Text("Is this picture job-specific or about the location in general?"),
          children: <Widget>[
            new SimpleDialogOption(
              onPressed: (){ Navigator.pop(context, "jobs"); },
              child: new Text("Job"),
            ),
            new SimpleDialogOption(
              onPressed: (){ Navigator.pop(context, "locations"); },
              child: new Text("Location"),
            ),
          ],
        ),
      );
    } else {
      uploadCategory = "jobs";
    }
    firebase.uploadPhoto(imageFile).then((String url){
      setState((){
        Map<String, dynamic> finish(Map<String, dynamic> input){
          Map<String, dynamic> newData = new Map<String, dynamic>.from(input);
          if (newData["photos"] != null){
            newData["photos"].add(url);
          } else {
            newData["photos"] = <String>[url];
          }
          return newData;
        }

        if (uploadCategory == "jobs"){
          jobData = finish(jobData);
          firebase.sendObject("jobs", jobData, objID: widget.jobID);
        } else {
          locationData = finish(locationData);
          firebase.sendObject("locations", locationData, objID: jobData["location"]);
        }
        populateLines();
      });
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
              child: (){
                List<String> photos = <String>[];
                
                if (jobData["photos"] != null) {
                  photos.addAll(jobData["photos"]);
                }
                if (locationData != null && locationData["photos"] != null) {
                  photos.addAll(locationData["photos"]);
                }
                
                if (photos.length < 1) {
                  if (locationData != null &&
                       (locationData["address"] != null &&
                        locationData["city"] != null &&
                        locationData["state"] != null)
                      ){
                        return new Image.network(
                          'https://maps.googleapis.com/maps/api/streetview?size=600x600&location=${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}&key=${api.gmaps}',
                          fit: BoxFit.fitWidth,
                        );
                      }
                  return new GestureDetector(
                    child: new Image.asset('assets/placeholder.jpg', fit: BoxFit.fitWidth),
                    onTap: goPhotos
                  );
                } else if (photos.length == 1) {
                  return new GestureDetector(
                    child: new Image.network(photos[0], fit: BoxFit.fitWidth),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        child: new ZoomableImage(
                          new NetworkImage(photos[0]),
                          scale: 10.0,
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  );
                } else {
                  return new ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: photos.map((String url){
                      return new GestureDetector(
                        child: new Image.network(url, fit: BoxFit.fitHeight),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            child: new ZoomableImage(
                              new NetworkImage(url),
                              scale: 10.0,
                              onTap: (){
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }
                      );
                    }).toList(),
                  );
                }
              }(),
            ),
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
            Navigator.of(context).pushNamed('/browse/locations/${jobData["location"]}');
          },
        ),
      );
    }

    if (contactData != null) {
      cardLines.add(new Divider());
      contactData.forEach((String contactID, Map<String, dynamic> contact){
        Widget trailing = (contact["phoneNumbers"] != null) ?
                            new IconButton(
                              icon: new Icon(Icons.phone),
                              onPressed: (){
                                url_launcher.launch('tel:${contact["phoneNumbers"][0]["number"]}');
                              })
                            : null;
        cardLines.add(
          new ListTile(
            title: new Text(contact["name"]),
            trailing: trailing,
            onTap: (){
              Navigator.of(context).pushNamed('/browse/contacts/$contactID');
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
      for (String userID in jobData["users"].keys){
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
            new Column(
              children: new List<Widget>.from(cardLines),
            ),
            new ButtonTheme.bar(
              child: new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: new Text("Add a photo"),
                    onPressed: goPhotos
                  ),
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
