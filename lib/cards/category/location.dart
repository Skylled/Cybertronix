import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../categoryCards.dart';
import '../../api.dart' as api;

class PreviousJobsTile extends StatefulWidget {
  final String locationID;

  PreviousJobsTile(this.locationID);

  @override
  _PreviousJobsTileState createState() => new _PreviousJobsTileState();
}

class _PreviousJobsTileState extends State<PreviousJobsTile> {
  List<ListTile> tiles = <ListTile>[new ListTile(title: new Text("Loading..."))];

  @override
  void initState(){
    super.initState();
    firebase.findJobs("location", widget.locationID)
      .then((Map<String, Map<String, dynamic>> results){
        setState((){
          tiles.clear();
          DateFormat datefmt = new DateFormat("M/d/y");
          results.forEach((String jobID, Map<String, dynamic> jobData){
            DateTime date = DateTime.parse(jobData["datetime"]);
            tiles.add(new ListTile(
              title: new Text("${datefmt.format(date)} - ${jobData['name']}"),
              onTap: (){
                showCategoryCard(context, "jobs", jobID, data: jobData);
              },
            ));
          });
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return new ExpansionTile(
      title: new Text("Jobs"),
      children: new List<ListTile>.from(tiles),
    );
  }
}

/// This card shows all the basic info about a location
class LocationInfoCard extends StatefulWidget {
  /// The Firebase ID of the location loaded
  final String locationID;
  /// The data loaded from Firebase
  final Map<String, dynamic> locationData;

  /// This card shows all the basic info about a location
  LocationInfoCard(this.locationID, {this.locationData});
  
  @override
  _LocationInfoCardState createState() => new _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard> {
  
  Map<String, dynamic> locationData;
  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showCreatorCard(context, "locations", data: locationData, objID: widget.locationID).then((dynamic x){
      if (x is Map){
        setState((){
          locationData = x;
          populateLines();
        });
      }
    });
  }

  Future<Null> goPhotos() async {
    // Future: This need to be a full popup with add/remove support
    File imageFile = await ImagePicker.pickImage();
    firebase.uploadPhoto(imageFile).then((String url){
      setState((){
        Map<String, dynamic> newData = new Map<String, dynamic>.from(locationData);
        if (newData["photos"] != null){
          newData["photos"].add(url);
        } else {
          newData["photos"] = <String>[url];
        }
        firebase.sendObject("locations", newData, objID: widget.locationID);
        locationData = newData;
        populateLines();
      });
    });
  }

  void goShare(){
    String shareString = "${locationData['name']}\n${locationData['address']}";
    shareString += "\n${locationData['city']}, ${locationData['state']}";
    share.share(shareString);
  }

  void populateLines(){
    cardLines.clear();
    cardLines.add(
      new Container( // Future: Make this a shrinking title?
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                List<String> photoList = locationData["photos"];
                if (photoList != null){
                  if (photoList.length == 1){
                    return new GestureDetector(
                      child: new Image.network(photoList[0], fit: BoxFit.fitWidth),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          child: new ZoomableImage(
                            new NetworkImage(photoList[0]),
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
                      children: photoList.map((String url){
                        return new GestureDetector(
                          child: new Image.network(url, fit: BoxFit.fitHeight),
                          onTap: () async {
                            print("Why doesn't this work?");
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
                          },
                        );
                      }).toList(),
                    );
                  }
                } else {
                  return new Image.network(
                    'https://maps.googleapis.com/maps/api/streetview?size=600x600&location=${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}&key=${api.gmaps}',
                    fit: BoxFit.fitWidth,
                  );
                }
              }(),
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                // Future: Text wrapping.
                locationData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            new Positioned(
              right: 8.0,
              top: 8.0,
              child: new IconButton(
                icon: new Icon(Icons.share, color: Colors.white),
                iconSize: 36.0,
                onPressed: goShare,
              ),
            )
          ]
        )
      )
    );
    String subtitle = "${locationData['city']}, ${locationData['state']}";
    cardLines.add(
      new ListTile(
        title: new Text(locationData["address"]),
        subtitle: new Text(subtitle),
        trailing: new Icon(Icons.navigation),
        onTap: () {
          url_launcher.launch('google.navigation:q=${locationData["address"]}, $subtitle');
        }
      )
    );
    if (locationData["contacts"] != null) {
      cardLines.add(new Divider());
      // `offset` essentially marks where the divider is, and thus, where to insert
      int offset = cardLines.length;
      locationData["contacts"].forEach((String contactID) {
        firebase.getObject("contacts", contactID).then((Map<String, dynamic> contactData){
          setState((){
            Widget trailing = (contactData["phoneNumbers"] != null)
                ? new IconButton(icon: new Icon(Icons.phone),
                    onPressed: (){ url_launcher.launch('tel:${contactData["phoneNumbers"][0]["number"]}'); })
                : null;
            cardLines.insert(offset, new ListTile(
              title: new Text(contactData["name"]),
              trailing: trailing,
              onTap: () {
                showCategoryCard(context, "contacts", contactID, data: contactData);
              }
            ));
          });
        });
      });
    }
    if (locationData["packages"] != null){
      // Firebase lists cannot be length 0
      cardLines.add(new Divider());
      List<Widget> packageLines = <Widget>[];

      locationData["packages"].forEach((Map<String, dynamic> package){
        Map<String, dynamic> panel = package["panel"];
        String title = "${panel != null ? panel['manufacturer'] : ''} ${package['power']}";
        packageLines.add(new ListTile(
          title: new Text(title),
          onTap: (){ showPackageCard(context, package); },
        ));
      });

      cardLines.add(new ExpansionTile(
        title: new Text("Packages"),
        children: packageLines,
      ));
    }
    cardLines.add(new Divider());
    cardLines.add(new PreviousJobsTile(widget.locationID));
    cardLines.add(new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: new Text("Add a photo"),
            onPressed: goPhotos,
          ),
          new FlatButton(
            child: new Text("Edit info"),
            onPressed: (){
              goEdit(context);
            }
          )
        ]
      )
    ));
  }

  @override
  void initState() {
    super.initState();
    locationData = widget.locationData;
    populateLines();
  }

  @override
  Widget build(BuildContext context){
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ListView(
          children: new List<Widget>.from(cardLines),
        ),
      ),
    );
  }
}