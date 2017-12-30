import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;
import '../cards/documentCards.dart';
import '../cards/document/package.dart';
import 'creator.dart';

class DataPage extends StatefulWidget {
  final String collection;
  final DocumentReference reference;

  DataPage(this.collection, this.reference);

  @override
  _DataPageState createState() => new _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<DocumentSnapshot>(
      stream: widget.reference.snapshots,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if (!snapshot.hasData) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Data Viewer"),
            ),
            drawer: buildDrawer(context, 'document'),
            body: new Card(
              child: new Center(
                child: new Text("Loading..."),
              ),
            ),
          );
        }
        DocumentSnapshot document = snapshot.data;
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Data Viewer"),
          ),
          drawer: buildDrawer(context, 'document'),
          persistentFooterButtons: (){
            List<Widget> footer = <Widget>[];
            if (<String>["jobs", "locations", "contacts"].contains(widget.collection)){
              footer.add(
                new FlatButton(
                  child: new Text("Add a photo"),
                  onPressed: () async {
                    File imageFile = await ImagePicker.pickImage();
                    firebase.uploadPhoto(imageFile).then((String url) async {
                      CollectionReference photos = Firestore.instance.collection("photos");
                      Map<String, dynamic> photoData = <String, dynamic>{"url": url, "uploaded": new DateTime.now()};
                      switch (widget.collection){
                        case "jobs":
                          photoData["job"] = document.reference;
                          if (document["location"] == null){
                            List<Map<String, dynamic>> jobPhotos = document["photos"] ?? <Map<String, dynamic>>[];
                            jobPhotos.add(photoData);
                            await photos.document().setData(photoData);
                            await document.reference.updateData(<String, dynamic>{"photos": jobPhotos});
                          } else {
                            DocumentReference location = document["location"];
                            photoData["location"] = location;
                            DocumentSnapshot locationSnapshot = await location.snapshots.first;
                            List<Map<String, dynamic>> locationPhotos = locationSnapshot["photos"] ?? <Map<String, dynamic>>[];
                            locationPhotos.add(photoData);
                            await photos.document().setData(photoData);
                            await location.updateData(<String, dynamic>{"photos": locationPhotos});
                          }
                          break;
                        case "locations":
                          photoData["location"] = document.reference;
                          List<Map<String, dynamic>> locationPhotos = document["photos"] ?? <Map<String, dynamic>>[];
                          locationPhotos.add(photoData);
                          await photos.document().setData(photoData);
                          await document.reference.updateData(<String, dynamic>{"photos": locationPhotos});
                          break;
                        case "contacts":
                          photoData["contact"] = document.reference;
                          await photos.document().setData(photoData);
                          await document.reference.updateData(<String, dynamic>{"photo": photoData});
                          break;
                      }
                    });
                  },
                ),
              );
            }
            footer.add(
              new FlatButton(
                child: new Text("Edit info"),
                onPressed: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new CreatorPage(widget.collection, document),
                    ),
                  );
                },
              ),
            );
            if (widget.collection == "jobs"){
              footer.add(
                new FlatButton(
                  child: new Text("Reports"),
                  onPressed: (){},
                ),
              );
            }
            return footer;
          }(),
          body: new ListView(
            children: (){
              List<Widget> children = <Widget>[];
              children.add(getDocumentCard(widget.collection, document));
              if (widget.collection == "locations"){
                if (document["package"] != null){
                  children.add(new PackageInfoCard(document["package"]));
                }
              }
              return children;
            }(),
          )
        );
      },
    );
  }
}