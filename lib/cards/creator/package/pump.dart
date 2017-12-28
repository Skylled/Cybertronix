import 'package:flutter/material.dart';
import '../tools.dart';

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
      new CreatorItem<String>( // Manufacturer
        name: "Manufacturer",
        value: widget.initialData["manufacturer"] ?? '',
        hint: "Aurora",
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
                        currentData['manufacturer'] = value;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<String>( // Model #
        name: "Model #",
        value: widget.initialData["model"] ?? '',
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
                        widget.changeData('pump', currentData);
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
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      new CreatorItem<int>( // RPM
        name: "RPM",
        value: widget.initialData["rpm"],
        hint: "(e.g. 3400)",
        valueToString: (int value) => value != null ? value.toString() : '',
        builder: (CreatorItem<int> item){
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
                      keyboardType: TextInputType.number,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        hintText: item.hint,
                        labelText: item.name,
                      ),
                      onSaved: (String value){
                        int rpm = int.parse(value, onError: (String input) => null);
                        item.value = rpm;
                        currentData["rpm"] = rpm;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<num>( // Shutoff pressure
        name: "Shutoff pressure",
        value: widget.initialData["shutoff"],
        valueToString: (num value) => value != null ? value.toString() : '',
        builder: (CreatorItem<num> item) {
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
                      keyboardType: TextInputType.number,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        labelText: item.name
                      ),
                      onSaved: (String value){
                        num psi = num.parse(value, (String input) => null);
                        item.value = psi;
                        currentData['shutoff'] = psi;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      // These next few are a GPM int at a PSI int.
      new CreatorItem<int>( // Capacity GPM
        name: "GPM Capacity",
        hint: "500, 750, 1500, etc",
        value: widget.initialData["capacityGPM"],
        valueToString: (int value) => value != null ? value.toString() : '',
        builder: (CreatorItem<int> item) {
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
                      keyboardType: TextInputType.number,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        labelText: item.name
                      ),
                      onSaved: (String value){
                        num gpm = int.parse(value, onError: (String input) => null);
                        item.value = gpm;
                        currentData['capacityGPM'] = gpm;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<num>( // Pressure at capacity
        name: "Pressure at capacity",
        value: widget.initialData["capacityPSI"],
        valueToString: (num value) => value != null ? value.toString() : '',
        builder: (CreatorItem<num> item) {
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
                      keyboardType: TextInputType.number,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        labelText: item.name
                      ),
                      onSaved: (String value){
                        num psi = num.parse(value, (String input) => null);
                        item.value = psi;
                        currentData['capacityPSI'] = psi;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<num>( // Pressure at 150%
        name: "Pressure at 150%",
        value: widget.initialData["150PSI"],
        valueToString: (num value) => value != null ? value.toString() : '',
        builder: (CreatorItem<num> item) {
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
                      keyboardType: TextInputType.number,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        labelText: item.name
                      ),
                      onSaved: (String value){
                        num psi = num.parse(value, (String input) => null);
                        item.value = psi;
                        currentData['150PSI'] = psi;
                        widget.changeData('pump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
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