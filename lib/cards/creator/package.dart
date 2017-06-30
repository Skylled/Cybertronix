import 'package:flutter/material.dart';
import 'components.dart';

// Fun: Make coresponding fields read from each other, as default if blank.

class PackageCreatorCard extends StatefulWidget {
  final Map<String, dynamic> packageData;

  PackageCreatorCard({Map<String, dynamic> packageData: null}):
    this.packageData = packageData;
  
  @override
  _PackageCreatorCardState createState() => new _PackageCreatorCardState();
}

class _PackageCreatorCardState extends State<PackageCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.packageData != null ? new Map<String, dynamic>.from(widget.packageData) : <String, dynamic>{"power": "Diesel"};
    _items = getPackageItems();
  }

  List<CreatorItem<dynamic>> getPackageItems(){
    List<CreatorItem<dynamic>> packageItems = <CreatorItem<dynamic>>[];
    packageItems.add(new CreatorItem<Map<String, dynamic>>( // Panel
        name: "Panel",
        value: widget.packageData["panel"] != null ? widget.packageData["panel"] : new Map<String, dynamic>(),
        hint: "What kind of panel is in use?",
        valueToString: (Map<String, dynamic> value) => (value["manufacturer"] == null) && (value["model"] == null) ?
                                                       "Enter panel data" :
                                                       "${value["manufacturer"]} ${value["model"]}",
        builder: (CreatorItem<Map<String, dynamic>> item){
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
                  child: new FormField<Map<String, dynamic>>(
                    initialValue: item.value,
                    onSaved: (Map<String, dynamic> value){
                      item.value = value;
                      currentData["panel"] = value;
                    },
                    builder: (FormFieldState<Map<String, dynamic>> field){
                      List<Widget> getPanelItems(){
                        Map<String, dynamic> replace(String key, dynamic value){
                          Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                          replaced[key] = value;
                          return replaced;
                        }

                        List<Widget> items = <Widget>[];
                        items.add(new DropdownButton<String>( // Manufacturer
                          items: <String>["Metron", "Tornatech", "Firetrol", "Master",
                                          "Hubbell", "Cutler-Hammer", "Joselyn-Clark"].map((String mfg){
                                            return new DropdownMenuItem<String>(value: mfg, child: new Text(mfg));
                                          }).toList(),
                          onChanged: (String input){
                            field.onChanged(replace("Manufacturer", input));
                          },
                          value: field.value["manufacturer"] != null ? field.value["manufacturer"] : "Metron",
                          hint: new Text("Manufacturer")
                        ));
                        items.add(new TextField( // Model #
                          controller: new TextEditingController(text: field.value["model"]),
                          decoration: new InputDecoration(
                            labelText: "Model #",
                            hintText: "(i.e. JPX-480-75)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("model", input));
                          },
                        ));
                        items.add(new TextField( // Serial #
                          controller: new TextEditingController(text: field.value["serial"]),
                          decoration: new InputDecoration(labelText: "Serial #"),
                          onChanged: (String input){
                            field.onChanged(replace("serial", input));
                          },
                        ));
                        items.add(new Divider());
                        if (currentData["power"] == "Electric"){
                          items.add(new DropdownButton<int>( // AC Voltage
                            items: <int>[120, 208, 240, 480, 0].map((int volt){
                              return new DropdownMenuItem<int>(value: volt, child: new Text("${volt != 0 ? volt : "Other"} Volt"));
                            }).toList(),
                            onChanged: (int input){
                              field.onChanged(replace("volts", input));
                            },
                            value: field.value["volts"],
                            hint: new Text("AC voltage"),
                          ));
                          items.add(new DropdownButton<String>( // Starting type
                            items: <String>["Across the line", "Soft start", "Wye delta closed",
                                            "Wye delta open", "Part winding", "Auto transformer",
                                            "Primary Resistor"].map((String startType){
                              return new DropdownMenuItem<String>(value: startType, child: new Text(startType));
                            }).toList(),
                            onChanged: (String input){
                              field.onChanged(replace("starting", input));
                            },
                            hint: new Text("Starting type"),
                            value: field.value["starting"] != null ? field.value["starting"] : "Across the line"
                          ));
                          items.add(new DropdownButton<String>( // Phase
                            items: <String>["Three", "Single"].map((String phase){
                              return new DropdownMenuItem<String>(value: phase, child: new Text("$phase Phase"));
                            }).toList(),
                            onChanged: (String input){
                              field.onChanged(replace("phase", input));
                            },
                            value: field.value["phase"] != null ? field.value["phase"] : "Three"
                          ));
                          items.add(new TextField( // Horsepower
                            controller: new TextEditingController(text: field.value["hp"] != null ? field.value["hp"].toString() : null),
                            decoration: new InputDecoration(
                              labelText: "Horsepower",
                              hintText: "(i.e. 10 / 1.5)",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("hp", num.parse(input, (String input) => null)));
                            },
                          ));
                        } else { // Diesel
                          items.add(new DropdownButton<int>( // Charger voltage
                            // Add "Other" option
                            items: <int>[120, 240].map((int volt){
                              return new DropdownMenuItem<int>(value: volt, child: new Text(volt.toString()));
                            }).toList(),
                            onChanged: (int input){
                              field.onChanged(replace("chargervolts", input));
                            },
                            value: field.value["chargervolts"],
                            hint: new Text("Charger voltage")
                          ));
                          items.add(new DropdownButton<int>( // Engine voltage
                            items: <int>[12, 24].map((int volt){
                              return new DropdownMenuItem<int>(value: volt, child: new Text(volt.toString()));
                            }).toList(),
                            onChanged: (int input){
                              field.onChanged(replace("enginevolts", input));
                            },
                            value: field.value["enginevolts"],
                            hint: new Text("Engine voltage")
                          ));
                        }
                        items.add(new TextField( // Start pressure
                          controller: new TextEditingController(text: field.value["start"] != null ? field.value["start"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Start Pressure",
                            hintText: "(i.e. 100)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("start", int.parse(input, onError: (String input) => 0)));
                          },
                        ));
                        items.add(new TextField( // Stop pressure
                          controller: new TextEditingController(text: field.value["stop"] != null ? field.value["stop"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Stop Pressure",
                            hintText: "(i.e. 115)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("stop", int.parse(input, onError: (String input) => 0)));
                          },
                        ));
                        items.add(new TextField( // Enclosure
                          controller: new TextEditingController(text: field.value["enclosure"]),
                          decoration: new InputDecoration(
                            labelText: "Enclosure",
                            hintText: "(i.e. NEMA 3R)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("enclosure", input));
                          },
                        ));
                        return items;
                      }
                      List<Widget> panelItems = getPanelItems();
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: panelItems,
                      );
                    },
                  ),
                );
              },
            )
          );
        }
      ));
    if (widget.packageData["power"] == "Electric"){
      packageItems.add(new CreatorItem<Map<String, dynamic>>( // Transfer Switch
        name: "Transfer Switch",
        value: widget.packageData["tswitch"] != null ? widget.packageData["tswitch"] : new Map<String, dynamic>(),
        hint: "Is there a transfer switch in place?",
        valueToString: (Map<String, dynamic> value) => value["manufacturer"] != null ? value["manufacturer"] : "No transfer switch",
        builder: (CreatorItem<Map<String, dynamic>> item){
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
                  child: new FormField<Map<String, dynamic>>(
                    initialValue: item.value,
                    onSaved: (Map<String, dynamic> value){
                      item.value = value;
                      currentData["pump"] = value;
                    },
                    builder: (FormFieldState<Map<String, dynamic>> field){
                      Map<String, dynamic> replace(String key, dynamic value){
                        Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                        replaced[key] = value;
                        return replaced;
                      }
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new DropdownButton<String>( // Manufacturer
                            items: <String>["Metron", "Tornatech", "Firetrol", "Master",
                                            "Hubbell", "Cutler-Hammer", "Joselyn-Clark"].map((String mfg){
                                              return new DropdownMenuItem<String>(value: mfg, child: new Text(mfg));
                                            }).toList(),
                            onChanged: (String input){
                              field.onChanged(replace("Manufacturer", input));
                            },
                            value: field.value["manufacturer"],
                            hint: new Text("Manufacturer")
                          ),
                          new TextField( // Model #
                            controller: new TextEditingController(text: field.value["model"]),
                            decoration: new InputDecoration(
                              labelText: "Model #",
                            ),
                            onChanged: (String input){
                              field.onChanged(replace("model", input));
                            },
                          ),
                          new TextField( // Serial #
                            controller: new TextEditingController(text: field.value["serial"]),
                            decoration: new InputDecoration(labelText: "Serial #"),
                            onChanged: (String input){
                              field.onChanged(replace("serial", input));
                            },
                          )
                        ]
                      );
                    }
                  ),
                );
              },
            ),
          );
        }
      ));
    }
    packageItems.add(new CreatorItem<Map<String, dynamic>>( // Pump
        name: "Pump",
        value: widget.packageData["pump"] != null ? widget.packageData["pump"] : new Map<String, dynamic>(),
        hint: "What kind of pump is in use?",
        valueToString: (Map<String, dynamic> value) => value["manufacturer"] != null ? value["manufacturer"] : "Enter pump data",
        builder: (CreatorItem<Map<String, dynamic>> item){
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
                  child: new FormField<Map<String, dynamic>>(
                    initialValue: item.value,
                    onSaved: (Map<String, dynamic> value){
                      item.value = value;
                      currentData["pump"] = value;
                    },
                    builder: (FormFieldState<Map<String, dynamic>> field){
                      Map<String, dynamic> replace(String key, dynamic value){
                        Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                        replaced[key] = value;
                        return replaced;
                      }

                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new TextField( // Manufacturer
                            controller: new TextEditingController(text: field.value["manufacturer"]),
                            decoration: new InputDecoration(
                              labelText: "Manufacturer",
                              hintText: "(i.e. Aurora)",
                            ),
                            onChanged: (String input){
                              field.onChanged(replace("manufacturer", input));
                            },
                          ),
                          new TextField( // Model
                            controller: new TextEditingController(text: field.value["model"]),
                            decoration: new InputDecoration(labelText: "Model #"),
                            onChanged: (String input){
                              field.onChanged(replace("model", input));
                            },
                          ),
                          new TextField( // Serial
                            controller: new TextEditingController(text: field.value["serial"]),
                            decoration: new InputDecoration(labelText: "Serial #"),
                            onChanged: (String input){
                              field.onChanged(replace("serial", input));
                            },
                          ),
                          new TextField( // RPM
                            controller: new TextEditingController(text: field.value["rpm"] != null ? field.value["rpm"].toString() : null),
                            decoration: new InputDecoration(labelText: "RPM"),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("rpm", int.parse(input, onError: (String input) => null)));
                            },
                          ),
                          new TextField( // Shutoff pressure
                            controller: new TextEditingController(text: field.value["shutoff"] != null ? field.value["shutoff"].toString(): null),
                            decoration: new InputDecoration(labelText: "Shutoff Pressure"),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("shutoff", int.parse(input, onError: (String input) => null)));
                            }
                          ),
                          new TextField( // Rated
                            controller: new TextEditingController(text: field.value["rated"] != null ? field.value["rated"].toString() : null),
                            decoration: new InputDecoration(labelText: "Rated Pressure"),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("rated", int.parse(input, onError: (String input) => null)));
                            },
                          ),
                          new TextField( // Over capacity
                            controller: new TextEditingController(text: field.value["over"] != null ? field.value["over"].toString() : null),
                            decoration: new InputDecoration(labelText: "Over Capacity Pressure"),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("over", int.parse(input, onError: (String input) => null)));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      ));
    packageItems.add(new CreatorItem<Map<String, dynamic>>( // Motor
        name: "Motor",
        value: widget.packageData["motor"] != null ? widget.packageData["motor"] : new Map<String, dynamic>(),
        hint: "What motor is on-site?",
        valueToString: (Map<String, dynamic> value) => value["manufacturer"] != null ? value["manufacturer"] : "Enter motor data",
        builder: (CreatorItem<Map<String, dynamic>> item){
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
                  child: new FormField<Map<String, dynamic>>(
                    initialValue: item.value,
                    onSaved: (Map<String, dynamic> value){
                      item.value = value;
                      currentData["motor"] = value;
                    },
                    builder: (FormFieldState<Map<String, dynamic>> field){
                      List<Widget> getMotorItems(){
                        Map<String, dynamic> replace(String key, dynamic value){
                          Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                          replaced[key] = value;
                          return replaced;
                        }

                        List<Widget> items = <Widget>[];
                        items.add(new TextField( // Manufacturer
                          controller: new TextEditingController(text: field.value["manufacturer"]),
                          decoration: new InputDecoration(
                            labelText: "Manufacturer",
                            hintText: "(i.e. Clarke / Weg)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("manufacturer", input));
                          }
                        ));
                        items.add(new TextField( // Model #
                          controller: new TextEditingController(text: field.value["model"]),
                          decoration: new InputDecoration(labelText: "Model #"),
                          onChanged: (String input){
                            field.onChanged(replace("model", input));
                          },
                        ));
                        items.add(new TextField( // Serial #
                          controller: new TextEditingController(text: field.value["serial"]),
                          decoration: new InputDecoration(labelText: "Serial #"),
                          onChanged: (String input){
                            field.onChanged(replace("serial", input));
                          },
                        ));
                        items.add(new TextField( // RPM
                          controller: new TextEditingController(text: field.value["rpm"] != null ? field.value["rpm"].toString() : null),
                          decoration: new InputDecoration(labelText: "RPM"),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("rpm", int.parse(input, onError: (String input) => null)));
                          },
                        ));
                        items.add(new TextField( // Horsepower
                          controller: new TextEditingController(text: field.value["hp"] != null ? field.value["hp"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Horsepower",
                            hintText: "(i.e. 10 / 1.5)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("hp", num.parse(input, (String input) => null)));
                          },
                        ));
                        if (currentData["power"] == "Electric"){
                          items.add(new DropdownButton<int>( // Volts
                            items: <int>[120, 208, 240, 480, 0].map((int volt){
                              return new DropdownMenuItem<int>(value: volt, child: new Text("${volt != 0 ? volt : "Other"} Volt"));
                            }).toList(),
                            onChanged: (int input){
                              field.onChanged(replace("volts", input));
                            },
                            value: field.value["volts"],
                            hint: new Text("AC Voltage"),
                          ));
                          items.add(new TextField( // Amps
                            controller: new TextEditingController(text: field.value["amps"] != null ? field.value["rpm"].toString() : null),
                            decoration: new InputDecoration(labelText: "amps"),
                            keyboardType: TextInputType.number,
                            onChanged: (String input){
                              field.onChanged(replace("amps", num.parse(input, (String input) => null)));
                            },
                          ));
                          items.add(new DropdownButton<String>( // Phase
                            items: <String>["Three", "Single"].map((String phase){
                              return new DropdownMenuItem<String>(value: phase, child: new Text("$phase Phase"));
                            }).toList(),
                            onChanged: (String input){
                              field.onChanged(replace("phase", input));
                            },
                            value: field.value["phase"] != null ? field.value["phase"] : "Three"
                          ));
                        } else { // Diesel
                          items.add(new DropdownButton<int>( // Battery voltage
                            items: <int>[12, 24].map((int volt){
                              return new DropdownMenuItem<int>(value: volt, child: new Text(volt.toString()));
                            }).toList(),
                            onChanged: (int input){
                              field.onChanged(replace("volts", input));
                            },
                            value: field.value["volts"],
                            hint: new Text("Battery Voltage")
                          ));
                          items.add(new DropdownButton<String>( // Grounding type
                            items: <String>["Negative", "Positive"].map((String ground){
                              return new DropdownMenuItem<String>(value: ground, child: new Text("$ground Ground"));
                            }).toList(),
                            onChanged: (String input){
                              field.onChanged(replace("ground", input));
                            },
                            value: field.value["ground"] != null ? field.value["ground"] : "Negative",
                            hint: new Text("Grounding type")
                          ));
                        }
                        return items;
                      }
                      List<Widget> motorItems = getMotorItems();
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: motorItems,
                      );
                    },
                  )
                );
              }
            )
          );
        }
      ));
    packageItems.add(new CreatorItem<Map<String, dynamic>>( // Jockey Panel
      name: "Jockey Panel",
      value: widget.packageData["jockeypanel"] != null ? widget.packageData["jockeypanel"] : new Map<String, dynamic>(),
      hint: "What kind of jockey panel is installed?",
      valueToString: (Map<String, dynamic> value) => (value["manufacturer"] == null) && (value["model"] == null) ?
                                                     "Enter jockey panel data" :
                                                     "${value["manufacturer"]} ${value["model"]}",
      builder: (CreatorItem<Map<String, dynamic>> item){
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
                child: new FormField<Map<String, dynamic>>(
                  initialValue: item.value,
                  onSaved: (Map<String, dynamic> value){
                    item.value = value;
                    currentData["jockeypanel"] = value;
                  },
                  builder: (FormFieldState<Map<String, dynamic>> field){
                    Map<String, dynamic> replace(String key, dynamic value){
                      Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                      replaced[key] = value;
                      return replaced;
                    }

                    return new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new DropdownButton<String>( // Manufacturer
                          items: <String>["Metron", "Tornatech", "Firetrol", "Master",
                                          "Hubbell", "Cutler-Hammer", "Joselyn-Clark"].map((String mfg){
                                            return new DropdownMenuItem<String>(value: mfg, child: new Text(mfg));
                                          }).toList(),
                          onChanged: (String input){
                            field.onChanged(replace("Manufacturer", input));
                          },
                          value: field.value["manufacturer"] != null ? field.value["manufacturer"] : "Metron",
                          hint: new Text("Manufacturer")
                        ),
                        new TextField( // Model #
                          controller: new TextEditingController(text: field.value["model"]),
                          decoration: new InputDecoration(
                            labelText: "Model #",
                            hintText: "(i.e. JP3-120-4)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("model", input));
                          },
                        ),
                        new TextField( // Serial #
                          controller: new TextEditingController(text: field.value["serial"]),
                          decoration: new InputDecoration(labelText: "Serial #"),
                          onChanged: (String input){
                            field.onChanged(replace("serial", input));
                          },
                        ),
                        new TextField( // Horsepower
                          controller: new TextEditingController(text: field.value["hp"] != null ? field.value["hp"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Horsepower",
                            hintText: "(i.e. 10 / 1.5)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("hp", num.parse(input, (String input) => null)));
                          },
                        ),
                        new DropdownButton<int>( // AC Voltage
                          items: <int>[120, 208, 240, 480, 0].map((int volt){
                            return new DropdownMenuItem<int>(value: volt, child: new Text("${volt != 0 ? volt : "Other"} Volt"));
                          }).toList(),
                          onChanged: (int input){
                            field.onChanged(replace("volts", input));
                          },
                          value: field.value["volts"],
                          hint: new Text("AC voltage"),
                        ),
                        new DropdownButton<String>( // Phase
                          items: <String>["Three", "Single"].map((String phase){
                            return new DropdownMenuItem<String>(value: phase, child: new Text("$phase Phase"));
                          }).toList(),
                          onChanged: (String input){
                            field.onChanged(replace("phase", input));
                          },
                          value: field.value["phase"] != null ? field.value["phase"] : "Three"
                        ),
                        new TextField( // Start pressure
                          controller: new TextEditingController(text: field.value["start"] != null ? field.value["start"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Start Pressure",
                            hintText: "(i.e. 100)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("start", int.parse(input, onError: (String input) => 0)));
                          },
                        ),
                        new TextField( // Stop pressure
                          controller: new TextEditingController(text: field.value["stop"] != null ? field.value["stop"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Stop Pressure",
                            hintText: "(i.e. 115)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("stop", int.parse(input, onError: (String input) => 0)));
                          },
                        ),
                        new TextField( // Enclosure
                          controller: new TextEditingController(text: field.value["enclosure"]),
                          decoration: new InputDecoration(
                            labelText: "Enclosure",
                            hintText: "(i.e. NEMA 3R)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("enclosure", input));
                          },
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      ));
    packageItems.add(new CreatorItem<Map<String, dynamic>>( // Jockey Pump
      name: "Jockey Pump",
      value: widget.packageData["jockeypump"] != null ? widget.packageData["jockeypump"] : new Map<String, dynamic>(),
      hint: "What kind of jockey pump is in use?",
      valueToString: (Map<String, dynamic> value) => value["manufacturer"] != null ? value["manufacturer"] : "Enter jockey pump data",
      builder: (CreatorItem<Map<String, dynamic>> item){
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
                child: new FormField<Map<String, dynamic>>(
                  initialValue: item.value,
                  onSaved: (Map<String, dynamic> value){
                    item.value = value;
                    currentData["jockeypump"] = value;
                  },
                  builder: (FormFieldState<Map<String, dynamic>> field){
                    Map<String, dynamic> replace(String key, dynamic value){
                      Map<String, dynamic> replaced = new Map<String, dynamic>.from(field.value);
                      replaced[key] = value;
                      return replaced;
                    }

                    return new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new TextField( // Manufacturer
                          controller: new TextEditingController(text: field.value["manufacturer"]),
                          decoration: new InputDecoration(
                            labelText: "Manufacturer",
                            hintText: "(i.e. Grunfos)",
                          ),
                          onChanged: (String input){
                            field.onChanged(replace("manufacturer", input));
                          },
                        ),
                        new TextField( // Model
                          controller: new TextEditingController(text: field.value["model"]),
                          decoration: new InputDecoration(labelText: "Model #"),
                          onChanged: (String input){
                            field.onChanged(replace("model", input));
                          },
                        ),
                        new TextField( // Serial
                          controller: new TextEditingController(text: field.value["serial"]),
                          decoration: new InputDecoration(labelText: "Serial #"),
                          onChanged: (String input){
                            field.onChanged(replace("serial", input));
                          },
                        ),
                        new TextField( // Horsepower
                          controller: new TextEditingController(text: field.value["hp"] != null ? field.value["hp"].toString() : null),
                          decoration: new InputDecoration(
                            labelText: "Horsepower",
                            hintText: "(i.e. 10 / 1.5)",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (String input){
                            field.onChanged(replace("hp", num.parse(input, (String input) => null)));
                          },
                        ),
                        new DropdownButton<int>( // AC Voltage
                          items: <int>[120, 208, 240, 480, 0].map((int volt){
                            return new DropdownMenuItem<int>(value: volt, child: new Text("${volt != 0 ? volt : "Other"} Volt"));
                          }).toList(),
                          onChanged: (int input){
                            field.onChanged(replace("volts", input));
                          },
                          value: field.value["volts"],
                          hint: new Text("AC voltage"),
                        ),
                        new DropdownButton<String>( // Phase
                          items: <String>["Three", "Single"].map((String phase){
                            return new DropdownMenuItem<String>(value: phase, child: new Text("$phase Phase"));
                          }).toList(),
                          onChanged: (String input){
                            field.onChanged(replace("phase", input));
                          },
                          value: field.value["phase"] != null ? field.value["phase"] : "Three"
                        ),
                      ],
                    );
                  }
                )
              );
            },
          ),
        );
      },
      ));
    return packageItems;
  }

  Widget build(BuildContext build){
    return(new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ListView(
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
            new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: (){ Navigator.pop(context); },
                ),
                new FlatButton(
                  child: new Text("Save & Finish"),
                  textColor: Theme.of(context).accentColor,
                  onPressed: () {
                    Navigator.pop(context, currentData);
                  },
                )
              ],
            )
          ],
        )
      )
    ));
  }
}