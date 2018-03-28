import 'package:flutter/material.dart';
import '../tools.dart';

// Future: Come back and check on the need for ?? ''

List<String> manufacturers = <String>[
  "Tornatech", "Metron", "Firetrol",
  "Master Controls", "Cutler-Hammer",
  "Joselyn Clark", "Patterson", "Hubbell",
  "Sylvania",
];

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
    currentData = widget.initialData != null ?
        new Map<String, dynamic>.from(widget.initialData) :
        <String, dynamic>{"hasSwitch": false};
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
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: manufacturers.map((String manufacturer){
                            return new DropdownMenuItem<String>(
                              value: manufacturer,
                              child: new Text(manufacturer),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.didChange(value);
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
      new CreatorItem<int>( // Charger AC voltage
        name: "Charger voltage",
        value: currentData['chargervolts'],
        hint: "120",
        valueToString: (int value) => value != null ? value.toString() : "Select voltage",
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
                    child: new FormField<int>(
                      onSaved: (int value){
                        item.value = value;
                        currentData['chargervolts'] = value;
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<int> field){
                        return new DropdownButton<int>(
                          value: item.value,
                          items: <int>[120, 208].map((int volt){
                            return new DropdownMenuItem<int>(
                              value: volt,
                              child: new Text(volt.toString()),
                            );
                          }).toList(),
                          onChanged: (int value){
                            field.didChange(value);
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
      new CreatorItem<int>( // Engine DC voltage
        name: "Engine voltage",
        value: currentData['enginevolts'],
        hint: "12/24",
        valueToString: (int value) => value != null ? value.toString() : "Select voltage",
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
                    child: new FormField<int>(
                      onSaved: (int value){
                        item.value = value;
                        currentData['enginevolts'] = value;
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<int> field){
                        return new DropdownButton<int>(
                          value: item.value,
                          items: <int>[12, 24].map((int volt){
                            return new DropdownMenuItem<int>(
                              value: volt,
                              child: new Text(volt.toString()),
                            );
                          }).toList(),
                          onChanged: (int value){
                            field.didChange(value);
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
                        widget.changeData('panel', currentData);
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
                        widget.changeData('panel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      // Automatic Stop
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
                        widget.changeData('panel', currentData);
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
      new CreatorItem<String>( // Manufacturer
        // TODO: Pull drop-down fix from other spots in code
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
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: manufacturers.map((String manufacturer){
                            return new DropdownMenuItem<String>(
                              value: manufacturer,
                              child: new Text(manufacturer),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.didChange(value);
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
      new CreatorItem<int>( // AC Volts
        name: "AC Voltage",
        value: currentData["volts"],
        hint: "(e.g. 208 or 480)",
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
                        widget.changeData('panel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      // Future: Consider an enum?
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
                        widget.changeData('panel', currentData);
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
                            field.didChange(value);
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
      new CreatorItem<bool>( // Has Transfer Switch
        name: "Has Transfer Switch?",
        value: currentData['hasSwitch'] ?? false,
        hint: "",
        valueToString: (bool hasSwitch) => hasSwitch ? "Yes" : "No",
        builder: (CreatorItem<bool> item){
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
                    child: new FormField<bool>(
                      onSaved: (bool value){
                        item.value = value;
                        currentData['hasSwitch'] = value;
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<bool> field){
                        return new DropdownButton<bool>(
                          value: item.value,
                          items: <DropdownMenuItem<bool>>[
                            new DropdownMenuItem<bool>(
                              value: false,
                              child: new Text("No"),
                            ),
                            new DropdownMenuItem<bool>(
                              value: true,
                              child: new Text("Yes"),
                            ),
                          ],
                          onChanged: (bool value){
                            field.didChange(value);
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
      new CreatorItem<String>( // Starting type
        // TODO: Pull drop-down fix from other spots in code
        name: "Starting type",
        value: currentData["starting"],
        hint: "Across the Line",
        valueToString: (String value) => value ?? "Select a starting type",
        builder: (CreatorItem<String> item){
          void close(){
            setState((){
              item.isExpanded = false;
            });
          }

          List<String> types = <String>["Across the Line", "Soft Start", "Wye Delta", "Part Winding"];

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
                        currentData['starting'] = value;
                        widget.changeData('panel', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: types.map((String type){
                            return new DropdownMenuItem<String>(
                              value: type,
                              child: new Text(type),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.didChange(value);
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
                        widget.changeData('panel', currentData);
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
                        widget.changeData('panel', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      // Automatic Stop
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
                        widget.changeData('panel', currentData);
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
                        widget.changeData('tswitch', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: manufacturers.map((String manufacturer){
                            return new DropdownMenuItem<String>(
                              value: manufacturer,
                              child: new Text(manufacturer),
                            );
                          }).toList(),
                          onChanged: (String value){
                            field.didChange(value);
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
                        widget.changeData('tswitch', currentData);
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
                        widget.changeData('tswitch', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
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