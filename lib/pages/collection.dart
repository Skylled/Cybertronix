import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:intl/intl.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;

/// This is a page that lists all items in a collection.
/// 
/// It pulls the data using [firebase.getCategory] and
/// slaps it in a [ListView]
class CollectionPage extends StatefulWidget{
  /// A page that lists all items in a collection.
  CollectionPage(this.collection);
  
  /// The collection to load objects from.
  final String collection;

  @override
  _CollectionPageState createState() => new _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>{
  List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    generateObjects();
  }

  void generateObjects(){
    firebase.getCategory(widget.collection, sortBy: widget.collection == "jobs" ? "datetime" : "name").then((Map<String, Map<String, dynamic>> objs){
      setState((){
        objects = <Map<String, dynamic>>[];
        objs.forEach((String id, Map<String, dynamic> data){
          objects.add(data);
        });
      });
    });
  }

  Widget buildAppBar(){
    return new AppBar(
      title: new Text(capitalize(widget.collection)),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: (){
            // Future: Implement Elastic Search?
          },
        ),
      ],
    );
  }

  Widget buildFAB(){
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: (){
        Navigator.of(context).pushNamed('/create/${widget.collection}}').then((dynamic x){
          generateObjects();
        });
      }
    );
  }

  Widget build(BuildContext context){
    // TODO: Make sure this object has the correct length upon regeneration
    // See: buildFAB
    List<Map<String, dynamic>> buildObjs = new List<Map<String, dynamic>>.from(objects);
    return new Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'collection'),
      floatingActionButton: buildFAB(),
      body: new ListView.builder(
        itemCount: buildObjs.length,
        itemBuilder: (BuildContext context, int index){
          return new ListTile(
            leading: (){
              switch(widget.collection){
                case 'jobs':
                  return new JobLeadIcon(buildObjs[index]);
                case 'contacts':
                  // Future: Load contact images into a CircleAvatar?
                default:
                  return null;
              }
            }(),
            title: new Text(buildObjs[index]["name"]),
            onTap: (){
              Navigator.of(context).pushNamed('/browse/${widget.collection}/${buildObjs[index]["id"]}');
            },
          );
        },
      ),
    );
  }
}

class JobLeadIcon extends StatelessWidget{
  final Map<String, dynamic> jobData;

  JobLeadIcon(this.jobData);

  Widget build(BuildContext context){
    DateFormat month = new DateFormat.MMMM();
    DateFormat day = new DateFormat.d();
    DateTime dt = DateTime.parse(jobData["datetime"]);
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