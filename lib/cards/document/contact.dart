import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:image_picker/image_picker.dart';
import 'package:zoomable_image/zoomable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase.dart' as firebase;

/// A Material Card with a contact's info
class ContactInfoCard extends StatefulWidget {
  final DocumentSnapshot contactData;

  ContactInfoCard(this.contactData);

  @override
  _ContactInfoCardState createState() => new _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {
  List<Widget> cardLines = <Widget>[];
  DocumentSnapshot contactData;

  Future<Null> goPhotos() async {
    File imageFile = await ImagePicker.pickImage();
    firebase.uploadPhoto(imageFile).then((String url) async {
      Map<String, dynamic> newData = new Map<String, dynamic>.from(contactData.data);
      newData["photo"] = url;
      await contactData.reference.setData(newData);
      contactData = await contactData.reference.snapshots.first;
      setState((){
        populateLines();
      });
    });
  }

  void goShare(){
    String shareString = "${contactData["name"]}";
    if (contactData["phoneNumbers"] != null){
      contactData["phoneNumbers"].forEach((Map<String, String> phone){
        shareString += "\n${phone["type"]}: ${phone["number"]}";
      });
    }
    if (contactData["email"] != null)
      shareString += "\n${contactData["email"]}";
    share.share(shareString);
  }

  void populateLines(){
    Color color;
    cardLines.clear();
    cardLines.add(
      new Container( // Future: Make this a sliver
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: (){
                if (contactData["photo"] != null){
                  color = Colors.white;
                  return new GestureDetector(
                    child: new Image.network(contactData["photo"], fit: BoxFit.fitWidth),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        child: new ZoomableImage(
                          new NetworkImage(contactData["photo"]),
                          scale: 10.0,
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                } else {
                  color = Colors.black;
                  return new IconButton(
                    icon: new Icon(Icons.add_a_photo),
                    onPressed: goPhotos,
                  );
                }
              }()
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                contactData["name"],
                style: new TextStyle(
                  color: color,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Positioned(
              right: 8.0,
              top: 8.0,
              child: new IconButton(
                icon: new Icon(Icons.share, color: color),
                iconSize: 36.0,
                onPressed: goShare,
              ),
            ),
          ],
        )
      ),
    );
    if (contactData["company"] != null){
      cardLines.add(
        new ListTile(
          leading: new Icon(Icons.business),
          title: new Text(contactData["company"]),
        ),
      );
    }
    cardLines.add(new Divider());
    if (contactData["phoneNumbers"] != null){
      contactData["phoneNumbers"].forEach((Map<String, String> phone){
        cardLines.add(
          new ListTile(
            leading: (){
              if (phone["type"] == "Cell")
                return new Icon(Icons.phone_android);
              if (phone["type"] == "Office")
                return new Icon(Icons.work);
              return null;
            }(),
            title: new Text(phone["number"]),
            trailing: new Row(
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.message),
                  onPressed: (){
                    url_launcher.launch('sms:${phone["number"]}');
                  },
                ),
                new IconButton(
                  icon: new Icon(Icons.call),
                  onPressed: (){
                    url_launcher.launch('tel:${phone["number"]}');
                  },
                ),
              ],
            ),
          ),
        );
      });
    }
    if (contactData["email"] != null){
      cardLines.add(
        new ListTile(
          title: new Text(contactData["email"]),
          trailing: new IconButton(
            icon: new Icon(Icons.mail),
            onPressed: (){
              url_launcher.launch('mailto:${contactData["email"]}');
            },
          ),
        ),
      );
    }
  }

  @override
  void initState(){
    super.initState();
    contactData = widget.contactData;
    populateLines();
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: new List<Widget>.from(cardLines)
      ),
    );
  }
}