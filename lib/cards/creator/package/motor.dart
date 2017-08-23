import 'package:flutter/material.dart';
import '../components.dart';

class DieselMotorCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  DieselMotorCreatorCard(this.initialData, this.changeData);

  @override
  _DieselMotorCreatorCardState createState() => new _DieselMotorCreatorCardState();
}

class _DieselMotorCreatorCardState extends State<DieselMotorCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getMotorItems();
  }

  List<CreatorItem<dynamic>> getMotorItems(){
    return <CreatorItem<dynamic>>[
      
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

class ElectricMotorCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  ElectricMotorCreatorCard(this.initialData, this.changeData);

  @override
  _ElectricMotorCreatorCardState createState() => new _ElectricMotorCreatorCardState();
}

class _ElectricMotorCreatorCardState extends State<ElectricMotorCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getMotorItems();
  }

  List<CreatorItem<dynamic>> getMotorItems(){
    return <CreatorItem<dynamic>>[
      
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