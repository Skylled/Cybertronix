import 'package:flutter/material.dart';
import '../tools.dart';

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
    if (currentData["ground"] == null) {
      currentData["ground"] = "Negative";
      widget.changeData('motor', currentData);
    }
    _items = getMotorItems();
  }

  List<CreatorItem<dynamic>> getMotorItems(){
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Manufacturer
        name: "Manufacturer",
        value: currentData["manufacturer"] ?? '',
        hint: "Clarke",
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
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
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
        value: currentData["rpm"],
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
                        widget.changeData('motor', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<num>( // Horsepower
        name: "Horsepower",
        value: currentData["hp"],
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
                        widget.changeData('motor', currentData);
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
        name: "Battery Voltage",
        value: currentData['volts'],
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
                        currentData['volts'] = value;
                        widget.changeData('motor', currentData);
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
      new CreatorItem<String>( // Grounding
        name: "Grounding",
        value: currentData['ground'] ?? "Negative",
        hint: "Negative/Positive",
        valueToString: (String ground) => "$ground ground",
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
                        currentData['ground'] = value;
                        widget.changeData('motor', currentData);
                      },
                      builder: (FormFieldState<String> field){
                        return new DropdownButton<String>(
                          value: item.value,
                          items: <String>["Negative", "Positive"].map((String ground){
                            return new DropdownMenuItem<String>(
                              value: ground,
                              child: new Text(ground),
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
    if (currentData["phase"] == null) {
      currentData["phase"] = "Three";
      widget.changeData('motor', currentData);
    }
    _items = getMotorItems();
  }

  List<CreatorItem<dynamic>> getMotorItems(){
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Manufacturer
        name: "Manufacturer",
        value: currentData["manufacturer"] ?? '',
        hint: "Weg",
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
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
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
        value: currentData["rpm"],
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
                        widget.changeData('motor', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<num>( // Horsepower
        name: "Horsepower",
        value: currentData["hp"],
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
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<int>( // Amps
        name: "Amperage",
        value: currentData["amps"],
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
                        int amps = int.parse(value, onError: (String input) => null);
                        item.value = amps;
                        currentData["amps"] = amps;
                        widget.changeData('motor', currentData);
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
                        widget.changeData('motor', currentData);
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