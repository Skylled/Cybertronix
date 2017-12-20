import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../pages/data.dart';

import '../../firebase.dart' as firebase;
import '../../api.dart' as api;

/// A Material Card with a job's info
class JobInfoCard extends StatelessWidget {
  final DocumentSnapshot jobData;

  JobInfoCard(this.jobData);

  Future<Null> goPhotos() async {
    File imageFile = await ImagePicker.pickImage();
    firebase.uploadPhoto(imageFile).then((String url) async {
      DocumentReference location = jobData["location"];
      Map<String, dynamic> photoData = <String, dynamic>{"job": jobData.reference, "url": url};
      DocumentSnapshot locationSnapshot = await location.snapshots.first;
      Map<String, dynamic> locationData = locationSnapshot.data;
      if (locationData["photos"] == null)
        locationData["photos"] = <Map<String, dynamic>>[];
      locationData["photos"].add(photoData);
      await location.setData(locationData);
    });
  }

  List<Widget> buildChildren(BuildContext context){
    List<Widget> children = <Widget>[];
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
    children.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: jobData["location"] == null ?
                new Icon(Icons.album) :
                new StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.document(jobData["location"]).snapshots,
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (!snapshot.hasData)
                      return new Icon(Icons.photo_album);
                    DocumentSnapshot location = snapshot.data;
                    if (location["photos"] != null){
                      // Future: Consider reorganization of photos
                      // Photo{"url": String, "job": DocumentReference}
                      return new ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: snapshot.data["photos"].map((String url){
                          return new GestureDetector(
                            child: new Image.network(url, fit: BoxFit.fitHeight),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                child: new ZoomableImage(
                                  new NetworkImage(url),
                                  scale: 10.0,
                                  onTap:(){
                                    Navigator.pop(context);
                                  }
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    } else if ((location["address"] != null) &&
                               (location["city"] != null) &&
                               (location["state"] != null)){
                      return new Image.network(
                        'https://maps.googleapis.com/maps/api/streetview?size=600x600&location=${location["address"]}, ${location["city"]}, ${location["state"]}&key=${api.gmaps}'
                      );
                    } else {
                      return new Icon(Icons.photo_album);
                    }
                  }
                ),
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

    if (jobData["datetime"] != null){
      children.add(
        new ListTile(
          leading: new Icon(Icons.access_time),
          title: new Text(formatter.format(jobData["datetime"])),
        ),
      );
    }
    if (jobData["location"] != null){
      children.add(
        new StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.document(jobData["location"]).snapshots,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
            if (!snapshot.hasData){
              return new Divider(); // Future: Consider other widgets.
            }
            DocumentSnapshot location = snapshot.data;
            String fullAddress =
              '${location["address"]}, ${location["city"]}, ${location["state"]}';
            return new ListTile(
              title: new Text(location["name"]),
              subtitle: new Text(fullAddress),
              trailing: new IconButton(
                icon: new Icon(Icons.navigation),
                onPressed: () {
                  url_launcher.launch('google.navigation:q=$fullAddress');
                },
              ),
              onTap: (){
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                    builder: (BuildContext context) => new DataPage('locations', location.reference)
                  )
                );
              }
            );
          },
        ),
      );
    }
    children.add(new Divider());
    if (jobData["contacts"] != null){
      // TODO: Find any other collections that aren't collections.
      List<DocumentReference> contactList = jobData["contacts"];
      contactList.forEach((DocumentReference contactRef){
        children.add(
          new StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.document(contactRef.path).snapshots,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
              if (!snapshot.hasData)
                return new Divider();
              DocumentSnapshot contact = snapshot.data;
              Widget trailing = (contact["phone"] != null) ?
                  new IconButton(
                    icon: new Icon(Icons.phone),
                    onPressed: (){
                      url_launcher.launch('tel:${contact["phone"]}');
                    })
                  : null;
              return new ListTile(
                title: new Text(contact["name"]),
                trailing: trailing,
                onTap: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new DataPage('contacts', contact.reference),
                    ),
                  );
                },
              );
            },
          ),
        );
      });
    }

    /* if (jobData["users"] != null){
      children.add(
        new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection(jobData["users"]).snapshots,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData)
              return new Divider();
            return new ExpansionTile(
              title: new Text("Employees assigned"),
              children: snapshot.data.documents.map((DocumentSnapshot user){
                return new ListTile(
                  title: new Text(user["name"]),
                  onTap: (){
                    // Push a user card
                  }
                );
              }).toList()
            );
          }
        ),
      );
    } */
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: buildChildren(context),
      ),
    );
  }
}