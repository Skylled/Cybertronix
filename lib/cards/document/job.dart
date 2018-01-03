import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:zoomable_image/zoomable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../pages/data.dart';

import '../../api.dart' as api;

/// A Material Card with a job's info
class JobInfoCard extends StatelessWidget {
  final DocumentSnapshot jobData;

  JobInfoCard(this.jobData);

  List<Widget> _buildChildren(BuildContext context){
    List<Widget> children = <Widget>[];
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
    children.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                if (jobData["location"] == null) {
                  if (jobData["photos"] == null || jobData["photos"].length == 0) {
                    return new Icon(Icons.add_a_photo, size: 64.0);
                  }
                  if (jobData["photos"].length == 1) {
                    return new InkWell(
                      child: new Image.network(jobData["photos"][0]["url"], fit: BoxFit.cover),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          child: new ZoomableImage(
                            new NetworkImage(jobData["photos"][0]["url"]),
                            scale: 10.0,
                            onTap:(){
                              Navigator.pop(context);
                            }
                          ),
                        );
                      },
                    );
                  } else {
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: jobData["photos"].map((Map<String, dynamic> photoData){
                        return new InkWell(
                          child: new Image.network(photoData["url"], fit: BoxFit.fitHeight),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              child: new ZoomableImage(
                                new NetworkImage(photoData["url"]),
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
                  }
                } else {
                  return new StreamBuilder<DocumentSnapshot>(
                    stream: jobData["location"].snapshots,
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                      if (!snapshot.hasData){
                        return new Icon(Icons.add_a_photo, size: 64.0);
                      }
                      DocumentSnapshot location = snapshot.data;
                      List<String> photoUrls = <String>[];
                      if (location["photos"] != null){
                        location["photos"].forEach((Map<String, dynamic> photoData){
                          photoUrls.add(photoData["url"]);
                        });
                      }
                      if ((location["address"] != null) &&
                          (location["city"] != null) &&
                          (location["state"] != null)) {
                        photoUrls.add('https://maps.googleapis.com/maps/api/streetview?size=600x600&location=${location["address"]}, ${location["city"]}, ${location["state"]}&key=${api.gmaps}');
                      }
                      if (photoUrls.isEmpty) {
                        return new Icon(Icons.add_a_photo, size: 64.0);
                      } else if (photoUrls.length == 1) {
                        return new InkWell(
                          child: new Image.network(photoUrls[0], fit: BoxFit.cover),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              child: new ZoomableImage(
                                new NetworkImage(photoUrls[0]),
                                scale: 10.0,
                                onTap:(){
                                  Navigator.pop(context);
                                }
                              ),
                            );
                          },
                        );
                      } else {
                        return new ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: photoUrls.map((String url){
                            return new InkWell(
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
                      }
                    },
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
          stream: jobData["location"].snapshots,
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
      List<DocumentReference> contactList = jobData["contacts"];
      contactList.forEach((DocumentReference contactRef){
        children.add(
          new StreamBuilder<DocumentSnapshot>(
            stream: contactRef.snapshots,
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
    // Future: Users
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: _buildChildren(context),
      ),
    );
  }
}