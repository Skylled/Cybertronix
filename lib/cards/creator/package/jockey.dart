import 'package:flutter/material.dart';
import '../tools.dart';

class JockeyPumpCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  JockeyPumpCreatorCard(this.initialData, this.changeData);

  @override
  _JockeyPumpCreatorCardState createState() => new _JockeyPumpCreatorCardState();
}

class _JockeyPumpCreatorCardState extends State<JockeyPumpCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPumpItems();
  }

  List<CreatorItem<dynamic>> getPumpItems(){
    return <CreatorItem<dynamic>>[
      // TODO: Fill in!
    ];
  }

  @override
  Widget build(BuildContext context) {
    return(new Card(
      child: new Column(
        children: <Widget>[
          new ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded){
              setState((){
                _items[index].isExpanded = !isExpanded;
              });
            },
            children: _items.map((CreatorItem<dynamic> item){
              return new ExpansionPanel(
                isExpanded: item.isExpanded,
                headerBuilder: item.headerBuilder,
                body: item.builder(item)
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }
}

class JockeyPanelCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  JockeyPanelCreatorCard(this.initialData, this.changeData);

  @override
  _JockeyPanelCreatorCardState createState() => new _JockeyPanelCreatorCardState();
}

class _JockeyPanelCreatorCardState extends State<JockeyPanelCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPanelItems();
  }

  List<CreatorItem<dynamic>> getPanelItems(){
    return <CreatorItem<dynamic>>[
      // TODO: There's nothing here!
    ];
  }

  @override
  Widget build(BuildContext context) {
    return(new Card(
      child: new Column(
        children: <Widget>[
          new ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded){
              setState((){
                _items[index].isExpanded = !isExpanded;
              });
            },
            children: _items.map((CreatorItem<dynamic> item){
              return new ExpansionPanel(
                isExpanded: item.isExpanded,
                headerBuilder: item.headerBuilder,
                body: item.builder(item)
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }
}