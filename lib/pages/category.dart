import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:intl/intl.dart';
import '../drawer.dart';
import '../firebase.dart' as firebase;

/// This is a page that lists all items in a category.
/// 
/// It pulls the data using [firebase.getCategory] and
/// slaps it in a [ListView]
class CategoryPage extends StatefulWidget{
  /// A page that lists all items in a category.
  CategoryPage(this.category);
  
  /// The category to load objects from.
  final String category;

  @override
  _CategoryPageState createState() => new _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>{
  List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    generateObjects();
  }

  void generateObjects(){
    firebase.getCategory(widget.category, sortBy: widget.category == "jobs" ? "datetime" : "name").then((Map<String, Map<String, dynamic>> objs){
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
      title: new Text(capitalize(widget.category)),
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
        Navigator.of(context).pushNamed('/create/${widget.category}}').then((dynamic x){
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
      drawer: buildDrawer(context, 'category'),
      floatingActionButton: buildFAB(),
      body: new ListView.builder(
        itemCount: buildObjs.length,
        itemBuilder: (BuildContext context, int index){
          return new ListTile(
            leading: (){
              switch(widget.category){
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
              Navigator.of(context).pushNamed('/browse/${widget.category}/${buildObjs[index]["id"]}');
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