import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:intl/intl.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import '../drawer.dart';
import '../pages/data.dart';

/// This is a page that lists all items in a collection.
class CollectionPage extends StatefulWidget {
  CollectionPage(this.collection);

  final String collection;

  @override
  _CollectionPageState createState() => new _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  Widget buildAppBar(){
    return new AppBar(
      title: new Text(capitalize(widget.collection)),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: (){
            // Future: Elastic Search?
            // TODO: See if FireStore can do a basic name search
          },
        ),
      ],
    );
  }

  Widget buildFAB(){
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).pushNamed('/create/${widget.collection}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'collection'),
      floatingActionButton: buildFAB(),
      body: new DocumentListView(widget.collection)
    );
  }
}

class DocumentListView extends StatelessWidget {
  DocumentListView(this.collection);

  final String collection;

  @override
  Widget build(BuildContext context){
    String sort;
    switch (collection){
      case "jobs":
        sort = "datetime";
        break;
      default:
        sort = "name";
        break;
    }

    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(collection).orderBy(sort).snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text("Loading...");
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return new ListTile(
              leading: (){
                switch (collection){
                  case 'jobs':
                    return new _JobLeadIcon(document);
                  default:
                    return null;
                }
              }(),
              title: new Text(document["name"]),
              onTap: (){
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                    builder: (BuildContext context) => new DataPage(collection, document)
                  )
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _JobLeadIcon extends StatelessWidget{
  final DocumentSnapshot jobData;

  _JobLeadIcon(this.jobData);

  Widget build(BuildContext context){
    DateFormat month = new DateFormat.MMMM();
    DateFormat day = new DateFormat.d();
    DateTime dt = jobData["datetime"];
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: new Column(
        children: <Widget>[
          new Text(month.format(dt).substring(0, 3)),
          new Text(day.format(dt)),
        ],
      ),
    );
  }
}