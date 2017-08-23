import 'package:flutter/material.dart';
import '../components.dart';

class PumpCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  PumpCreatorCard(this.initialData, this.changeData);

  @override
  _PumpCreatorCardState createState() => new _PumpCreatorCardState();
}

class _PumpCreatorCardState extends State<PumpCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPumpItems();
  }

  List<CreatorItem<dynamic>> getPumpItems(){
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