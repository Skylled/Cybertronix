import 'package:flutter/material.dart';
import 'drawer.dart';
import 'cards/creatorCards.dart';
import 'cards/categoryCards.dart';
import 'firebase.dart';

class CategoryPage extends StatefulWidget{
  const CategoryPage(this.category);

  final String category;

  @override
  _CategoryPageState createState() => new _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>{
  _CategoryPageState();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> objectList = <Widget>[];

  @override
  void initState() {
    super.initState();
    generateList();
  }
  
  void generateList(){
    Map<String, Map<String, dynamic>> objects = getCategory(widget.category);
    objects.forEach((String id, Map<String, dynamic> data){
      setState((){
        objectList.add(new ListTile(
          title: new Text(data["name"]),
          onTap: (){
            showCategoryCard(context, widget.category, id, data: data);
          }
        ));
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
            // TODO: How the hell do I search?
          }
        )
      ]
    );
  }

  Widget buildFAB(){
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: (){
        showCreatorCard(context, widget.category);
      }
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      drawer: buildDrawer(context, 'browse'),
      floatingActionButton: buildFAB(),
      body: new ListView(
        children: new List<Widget>.from(objectList)
      )
    );
  }
}