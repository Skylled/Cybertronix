import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:intl/intl.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../api.dart' as api;
import '../../pages/data.dart';


class PreviousJobsTile extends StatefulWidget {
  final DocumentReference locationRef;

  PreviousJobsTile(this.locationRef);

  @override
  _PreviousJobsTileState createState() => new _PreviousJobsTileState();
}

class _PreviousJobsTileState extends State<PreviousJobsTile> {
  
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("jobs")
                       .where("location", isEqualTo: widget.locationRef)
                       .orderBy("datetime", descending: true)
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
                    builder: (BuildContext context) => new DataPage('jobs', document.reference)
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
class LocationInfoCard extends StatelessWidget {
  final DocumentSnapshot locationData;

  LocationInfoCard(this.locationData);

  void _goShare(){
    String shareString = "${locationData["name"]}\n${locationData["address"]}";
    shareString += "\n${locationData["city"]}, ${locationData["state"]}";
    share.share(shareString);
  }

  List<Widget> _buildChildren(BuildContext context){
    List<Widget> children = <Widget>[];
    children.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                List<String> photoUrls = <String>[];
                if ((locationData["photos"] != null) &&
                    (locationData["photos"].isNotEmpty)) {
                  locationData["photos"].forEach((Map<String, dynamic> photoData){
                    photoUrls.add(photoData["url"]);
                  });
                }
                if ((locationData["address"] != null) &&
                    (locationData["city"] != null) &&
                    (locationData["state"] != null)) {
                  photoUrls.add('https://maps.googleapis.com/maps/api/streetview?size=600x600&location=${locationData["address"]}, ${locationData["city"]}, ${locationData["state"]}&key=${api.gmaps}');
                }
                if (photoUrls.isEmpty) {
                  return new Icon(Icons.add_a_photo);
                } else if (photoUrls.length == 1) {
                  return new InkWell(
                    child: new Image.network(photoUrls[0], fit: BoxFit.cover),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        child: new ZoomableImage(
                          new NetworkImage(photoUrls[0]),
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
                    children: photoUrls.map((String url){
                      return new InkWell(
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
                        },
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
                onPressed: _goShare,
              ),
            ),
          ],
        ),
      ),
    );
    String cityState = "${locationData["city"]}, ${locationData["state"]}";
    children.add(
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
      children.add(new Divider());
      locationData["contacts"].forEach((DocumentReference contact) {
        children.add(
          new StreamBuilder<DocumentSnapshot>(
            stream: contact.snapshots,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
              if (!snapshot.hasData)
                return new ListTile(title: new Text("Loading contact..."));
              DocumentSnapshot contactData = snapshot.data;
              Widget trailing = (contactData["phone"] != null) ?
                  new IconButton(icon: new Icon(Icons.phone),
                    onPressed: (){ url_launcher.launch('tel:${contactData["phone"]}'); })
                  : null;
              return new ListTile(
                title: new Text(contactData["name"]),
                trailing: trailing,
                onTap: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new DataPage("contacts", contact),
                    ),
                  );
                },
              );
            },
          ),
        );
      });
    }

    children.add(new Divider());
    children.add(new PreviousJobsTile(locationData.reference));
    return children;
  }

  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: _buildChildren(context),
      ),
    );
  }
}