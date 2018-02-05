import 'package:flutter/material.dart';
import '../tools.dart';

List<String> _manufacturers = <String>[
  "Tornatech", "Metron", "Firetrol",
  "Master Controls", "Cutler-Hammer",
  "Joselyn Clark", "Patterson", "Hubbell",
  "Sylvania",
];

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
      new CreatorItem<String>( // Manufacturer
        name: "Manufacturer",
        value: currentData["manufacturer"] ?? '',
        hint: "Grunfos",
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
                        widget.changeData('jockeypump', currentData);
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
        value: currentData["model"] ?? '',
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
                        widget.changeData('jockeypump', currentData);
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
        value: currentData["serial"] ?? '',
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
                        widget.changeData('jockeypump', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      new CreatorItem<num>( // Horsepower
        name: "Horsepower",
        value: currentData["hp"],
        hint: "(e.g. 1.5 or 10)",
        valueToString: (num value) => value != null ? value.toString() : '',
        builder: (CreatorItem<num> item){
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
                        num hp = num.parse(value, (String input) => null);
                        item.value = hp;
                        currentData['hp'] = hp;
                        widget.changeData('jockeypump', currentData);
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
      new CreatorItem<String>( // Manufacturer
        name: "Manufacturer",
        value: currentData["manufacturer"],
        hint: "Tornatech",
        valueToString: (String value) => value ?? "Select a manufacturer",
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
                    child: new FormField<String>(
                      onSaved: (String value){
                        item.value = value;
                        currentData['manufacturer'] = value;
                        widget.changeData('jockeypanel', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: _manufacturers.map((String manufacturer){
                            return new DropdownMenuItem<String>(
                              value: manufacturer,
                              child: new Text(manufacturer),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.onChanged(value);
                          },
                        );
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
        value: currentData["model"] ?? '',
        hint: "(JP3-460/3/2/2)",
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
                        widget.changeData('jockeypanel', currentData);
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
        value: currentData["serial"] ?? '',
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
                        widget.changeData('jockeypanel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      new CreatorItem<num>( // Horsepower
        name: "Horsepower",
        value: currentData["hp"],
        hint: "(e.g. 1.5 or 10)",
        valueToString: (num value) => value != null ? value.toString() : '',
        builder: (CreatorItem<num> item){
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
                        num hp = num.parse(value, (String input) => null);
                        item.value = hp;
                        currentData['hp'] = hp;
                        widget.changeData('jockeypanel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<int>( // AC Volts
        name: "AC Voltage",
        value: currentData["volts"],
        hint: "(e.g. 120 or 208)",
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
                        int volts = int.parse(value, onError: (String input) => null);
                        item.value = volts;
                        currentData["volts"] = volts;
                        widget.changeData('jockeypanel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<String>( // Phase [Single, Three]
        name: "Phase",
        value: currentData['phase'] ?? "Three",
        hint: "Three/Single",
        valueToString: (String phase) => "$phase phase",
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
                    child: new FormField<String>(
                      onSaved: (String value){
                        item.value = value;
                        currentData['phase'] = value;
                        widget.changeData('jockeypanel', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: <String>["Three", "Single"].map((String phase){
                            return new DropdownMenuItem<String>(
                              value: phase,
                              child: new Text(phase),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.onChanged(value);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<int>( // Start pressure
        name: "Start pressure",
        value: currentData["start"],
        hint: "In PSI",
        valueToString: (int value) => value != null ? value.toString() : "Enter start pressure",
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
                        int pressure = int.parse(value, onError: (String input) => null);
                        item.value = pressure;
                        currentData['start'] = pressure;
                        widget.changeData('jockeypanel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<int>( // Stop pressure
        name: "Stop pressure",
        value: currentData["stop"],
        hint: "In PSI",
        valueToString: (int value) => value != null ? value.toString() : "Enter stop pressure",
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
                        int pressure = int.parse(value, onError: (String input) => null);
                        item.value = pressure;
                        currentData['stop'] = pressure;
                        widget.changeData('jockeypanel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<String>( // Enclosure
        name: "Enclosure",
        hint: "NEMA 4X",
        value: currentData["enclosure"] ?? '',
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
                        currentData["enclosure"] = value;
                        widget.changeData('jockeypanel', currentData);
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