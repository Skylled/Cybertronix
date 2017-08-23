import 'package:flutter/material.dart';
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
  _CategoryPageState();

  List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    generateObjects();
  }

  void generateObjects(){
    firebase.getCategory(widget.category).then((Map<String, Map<String, dynamic>> objs){
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
      title: new Text(widget.category.substring(0, 1).toUpperCase() + widget.category.substring(1)),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: (){
            // Future: Implement Elastic Search?
          }
        )
      ]
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