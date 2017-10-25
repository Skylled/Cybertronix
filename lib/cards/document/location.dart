import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import '../../firebase.dart' as firebase;
import '../../api.dart' as api;
import '../../pages/data.dart';


class NPreviousJobsTile extends StatefulWidget {
  final DocumentReference locationRef;

  NPreviousJobsTile(this.locationRef);

  @override
  _NPreviousJobsTileState createState() => new _NPreviousJobsTileState();
}

class _NPreviousJobsTileState extends State<NPreviousJobsTile> {
  
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("jobs")
                       .where("location", "==", widget.locationRef)
                       .orderBy("datetime")
                       .snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (!snapshot.hasData){
          return new ExpansionTile(
             title: new Text("Jobs"),
            children: <Widget>[new ListTile(title: new Text("Loading..."))],
          );
        }
        List<Widget> tiles = <Widget>[];
        DateFormat datefmt = new DateFormat("M/d/y");
        snapshot.data.documents.forEach((DocumentSnapshot document){
          tiles.add(
            new ListTile(
              title: new Text("${datefmt.format(document["datetime"])} - ${document["name"]}"),
              onTap: (){
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                    builder: (BuildContext context) => new DataPage('jobs', document)
                  ),
                );
              },
            ),
          );
        });
        return new ExpansionTile(
          title: new Text("Jobs"),
          children: tiles,
        );
      },
    );
  }
}

/// This card shows all the basic info about a location
class LocationInfoCard extends StatefulWidget {
  final DocumentSnapshot locationData;

  LocationInfoCard(this.locationData);

  @override
  _LocationInfoCardState createState() => new _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard> {
  DocumentSnapshot locationData;
  List<Widget> cardLines = <Widget>[];

  Future<Null> goPhotos() async {
    // TODO: Document this, it's the most complicated one.
    File imageFile = await ImagePicker.pickImage();
    firebase.uploadPhoto(imageFile).then((String url) async {
      Map<String, dynamic> newData = new Map<String, dynamic>.from(locationData.data);
      if (newData["photos"] == null)
        newData["photos"] = <Map<String, dynamic>>[];
      newData["photos"].add(<String, dynamic>{"url": url});
      DocumentReference reference = Firestore.instance.document(locationData.path);
      await reference.setData(newData);
      locationData = await reference.snapshots.first;
      setState((){
        populateLines();
      });
    });
  }

  void goShare(){
    String shareString = "${locationData["name"]}\n${locationData["address"]}";
    shareString += "\n${locationData["city"]}, ${locationData["state"]}";
    share.share(shareString);
  }

  void populateLines(){
    cardLines.clear();
    cardLines.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                List<Map<String, dynamic>> photos = locationData["photos"];
                if (photos != null){
                  if (photos.length == 1){
                    return new GestureDetector(
                      child: new Image.network(photos[0]["url"], fit: BoxFit.fitWidth),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          child: new ZoomableImage(
                            new NetworkImage(photos[0]["url"]),
                            scale: 10.0,
                            onTap: (){
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: photos.map((Map<String, dynamic> photo){
                        return new GestureDetector(
                          child: new Image.network(photo["url"], fit: BoxFit.fitHeight),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              child: new ZoomableImage(
                                new NetworkImage(photo["url"]),
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
                    fit: BoxFit.fitWidth
                  );
                }
              }(),
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                locationData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Positioned(
              right: 8.0,
              top: 8.0,
              child: new IconButton(
                icon: new Icon(Icons.share, color: Colors.white),
                iconSize: 36.0,
                onPressed: goShare,
              ),
            ),
          ],
        ),
      ),
    );
    String cityState = "${locationData["city"]}, ${locationData["state"]}";
    cardLines.add(
      new ListTile(
        title: new Text("${locationData["address"]}"),
        subtitle: new Text(cityState),
        trailing: new Icon(Icons.navigation),
        onTap: (){
          url_launcher.launch('google.navigation:q=${locationData["address"]}, $cityState');
        },
      ),
    );
    if (locationData["contacts"] != null) {
      cardLines.add(new Divider());
      locationData["contacts"].forEach((DocumentReference contact) {
        cardLines.add(
          new StreamBuilder<DocumentSnapshot>(
            stream: contact.snapshots,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
              if (!snapshot.hasData)
                return new ListTile(title: new Text("Loading contact..."));
              DocumentSnapshot contactData = snapshot.data;
              Widget trailing = (contactData["phoneNumbers"] != null) ?
                  new IconButton(icon: new Icon(Icons.phone),
                    onPressed: (){ url_launcher.launch('tel:${contactData["phoneNumbers"][0]["number"]}'); })
                  : null;
              return new ListTile(
                title: new Text(contactData["name"]),
                trailing: trailing,
                onTap: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new DataPage("contacts", contactData),
                    ),
                  );
                },
              );
            },
          ),
        );
      });
    }

    cardLines.add(new Divider());
    //cardLines.add(new PreviousJobsTile(Firestore.instance.document(locationData.path)));
  }

  @override
  void initState(){
    super.initState();
    locationData = widget.locationData;
    populateLines();
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: new List<Widget>.from(cardLines),
      ),
    );
  }
}