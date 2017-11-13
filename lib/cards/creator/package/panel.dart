import 'package:flutter/material.dart';
import '../tools.dart';

class DieselPanelCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  DieselPanelCreatorCard(this.initialData, this.changeData);

  @override
  _DieselPanelCreatorCardState createState() => new _DieselPanelCreatorCardState();
}

class _DieselPanelCreatorCardState extends State<DieselPanelCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPanelItems();
  }

  List<CreatorItem<dynamic>> getPanelItems(){
    return <CreatorItem<dynamic>>[
      // TODO: Fill in!
      // Manufacturer
      new CreatorItem<String>( // Model #
        name: "Model #",
        value: widget.initialData["model"] ?? '',
        hint: "(FD4-J)",
        valueToString: (String value) => value,
        builder: (CreatorItem<String> item){
          void close(){
            setState((){
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context){
                return new CollapsibleBody(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: new TextFormField(
                      controller: item.textController,
                      decoration: new InputDecoration(
                        hintText: item.hint,
                        labelText: item.name,
                      ),
                      onSaved: (String value){
                        item.value = value;
                        currentData['model'] = value;
                        widget.changeData('panel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      new CreatorItem<String>( // Serial #
        name: "Serial #",
        value: widget.initialData["serial"] ?? '',
        valueToString: (String value) => value,
        builder: (CreatorItem<String> item){
          void close(){
            setState((){
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context){
                return new CollapsibleBody(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: new TextFormField(
                      controller: item.textController,
                      decoration: new InputDecoration(
                        hintText: item.hint,
                        labelText: item.name,
                      ),
                      onSaved: (String value){
                        item.value = value;
                        currentData['serial'] = value;
                        widget.changeData('panel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // Charger AC voltage
      // Engine DC voltage
      // Start pressure
      // Stop pressure
      // Enclosure
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

class ElectricPanelCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  ElectricPanelCreatorCard(this.initialData, this.changeData);

  @override
  _ElectricPanelCreatorCardState createState() => new _ElectricPanelCreatorCardState();
}

class _ElectricPanelCreatorCardState extends State<ElectricPanelCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPanelItems();
  }

  List<CreatorItem<dynamic>> getPanelItems(){
    return <CreatorItem<dynamic>>[
      // TODO: Fill in!
      // Manufacturer
      // Model #
      // Serial #
      // AC Voltage
      // Starting type
      // Phase
      // Start pressure
      // Stop pressure
      // Enclosure
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

class TransferSwitchCreatorCard extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(String, Map<String, dynamic>) changeData;

  TransferSwitchCreatorCard(this.initialData, this.changeData);

  @override
  _TransferSwitchCreatorCardState createState() => new _TransferSwitchCreatorCardState();
}

class _TransferSwitchCreatorCardState extends State<TransferSwitchCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.initialData != null ? new Map<String, dynamic>.from(widget.initialData) : <String, dynamic>{};
    _items = getPanelItems();
  }

  List<CreatorItem<dynamic>> getPanelItems(){
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