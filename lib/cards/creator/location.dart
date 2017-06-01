import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import 'components.dart';
import '../creatorCards.dart';

class LocationCreatorCard extends StatefulWidget {
  final Map<String, dynamic> locationData;
  final String locationID;

  LocationCreatorCard({Map<String, dynamic> locationData: null, String locationID: null}):
    this.locationData = (locationData == null && locationID != null) ? firebase.getObject("locations", locationID) : locationData,
    this.locationID = locationID;
  
  @override
  _LocationCreatorCardState createState() => new _LocationCreatorCardState();
}

class _LocationCreatorCardState extends State<LocationCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;
  List<String> contactList;

  void initState(){
    super.initState();
    currentData = widget.locationData != null ? new Map<String, dynamic>.from(widget.locationData) : <String, dynamic> {};
    _items = getLocationItems();
  }

  List<CreatorItem<dynamic>> getLocationItems(){
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Name
        name: "Name",
        value: widget.locationData != null ? widget.locationData["name"] : '',
        hint: "(i.e. Cargill Avery Island)",
        valueToString: (String value) => value == '' ? "Please enter a name" : value,
        builder: (CreatorItem<String> item){
          void close() {
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
                        currentData['name'] = value;
                      },
                    )
                  ),
                );
              }
            )
          );
        }
      ),
      new CreatorItem<Map<String, String>>( // Street Address
        name: "Street Address",
        value: widget.locationData != null ? {"address": widget.locationData["address"],
                                              "city": widget.locationData['city'],
                                              "state": widget.locationData['state']}
                                           : <String, String>{},
        hint: "The street address for the location",
        valueToString: (Map<String, String> addressInfo){
          if (addressInfo["address"] == null || addressInfo["city"] == null || addressInfo["state"] == null){
            return "Please enter a complete address";
          } else {
            return "${addressInfo["address"]}, ${addressInfo["city"]}, ${addressInfo["state"]}";
          }
        },
        builder: (CreatorItem<Map<String, String>> item){
          void close(){
            setState((){
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context){
                return new CollapsibleBody(
                  onSave: (){ Form.of(context).save(); close(); },
                  onCancel: (){ Form.of(context).save(); close(); },
                  child: new FormField<Map<String, String>>(
                    initialValue: item.value,
                    onSaved: (Map<String, String> value){
                      item.value = value;
                      currentData["address"] = value["address"];
                      currentData["city"] = value["city"];
                      currentData["state"] = value["state"];
                    },
                    builder: (FormFieldState<Map<String, String>> field){
                      List<DropdownMenuItem<String>> states;
                      <String>["LA", "MS", "AL", "TX", "FL", "AK", "TN"].forEach((String st){
                        states.add(new DropdownMenuItem<String>(value: st, child: new Text(st)));
                      });

                      Map<String, String> _changeAddress(String key, String value){
                        Map<String, String> result = new Map<String, String>.from(field.value);
                        result[key] = value;
                        return result;
                      }

                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new TextField(
                            controller: new TextEditingController(text: field.value["address"]),
                            decoration: new InputDecoration(
                              hintText: "(e.g. 1515 Poydras St)",
                              labelText: "Street address"
                            ),
                            onChanged: (String value) {
                              field.onChanged(_changeAddress("address", value));
                            },
                          ),
                          new TextField(
                            controller: new TextEditingController(text: field.value["city"]),
                            decoration: new InputDecoration(
                              hintText: "(e.g. New Orleans)",
                              labelText: "City"
                            ),
                            onChanged: (String value){
                              field.onChanged(_changeAddress("city", value));
                            },
                          ),
                          new DropdownButton<String>(items: states,
                          onChanged: (String value){
                            field.onChanged(_changeAddress("state", value));
                          })
                        ],
                      );
                    },
                  )
                );
              },
            )
          );
        }
      ),
      new CreatorItem<List<String>>( // Packages
        name: "Packages",
        value: widget.locationData != null ? widget.locationData["packages"] : <String>[],
        hint: "What kind of equipment is on-site?",
        valueToString: (List<String> value) {
          if (value.length == 1) {
            Map<String, dynamic> packageData = firebase.getObject("packages", value.first);
            Map<String, dynamic> panelData = firebase.getObject("panels", packageData["panel"]);
            return "${panelData["manufacturer"]} ${packageData["power"]}";
          } else if (value.length > 1) {
            return value.length.toString();
          } else {
            return "Add a package";
          }
        },
        builder: (CreatorItem<List<String>> item){
          void close(){
            setState((){
              item.isExpanded = false;
            });
          }
          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<List<String>>(
                    initialValue: item.value,
                    onSaved: (List<String> value) {
                      item.value = value;
                      currentData["packages"] = value;
                    },
                    builder: (FormFieldState<List<String>> field){
                      List<String> addPackage(String packageID){
                        List<String> updated = new List<String>.from(field.value);
                        updated.add(packageID);
                        return updated;
                      }

                      List<String> removePackage(String packageID){
                        List<String> updated = new List<String>.from(field.value);
                        updated.remove(packageID);
                        return updated;
                      }

                      Column x = new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: field.value.map((String packageID){
                          Map<String, dynamic> packageData = firebase.getObject("packages", packageID);
                          Map<String, dynamic> panelData = firebase.getObject("panels", packageData["panel"]);
                          return new ListTile(
                            title: new Text("${panelData["manufacturer"]} ${packageData["power"]}"),
                            onTap: (){
                              showCreatorCard(context, "packages", data: packageData, objID: packageID);
                            },
                            trailing: new IconButton(
                              icon: new Icon(Icons.remove),
                              onPressed: (){
                                field.onChanged(removePackage(packageID));
                              },
                            ),
                          );
                        }).toList(),
                      );
                      x.children.insert(0, new ListTile(
                        title: new Text("Add a package"),
                        trailing: new Icon(Icons.add),
                        onTap: () async {
                          final String newPackageID = await awaitNewPackage(context);
                          if (newPackageID != null){
                            field.onChanged(addPackage(newPackageID));
                          }
                        }
                      ));
                    }
                  )
                );
              }
            )
          );
        }
      ),
      new CreatorItem<List<String>>( // Contacts
        name: "Contacts",
        value: widget.locationData != null ? widget.locationData['contacts'] : <String>[],
        hint: "Who is involved with this job?",
        valueToString: (List<String> value) => value.length.toString(),
        builder: (CreatorItem<List<String>> item){
          void close() {
            setState((){
              item.isExpanded = false;
            });
          }
          List<String> removeContact(List<String> conList, String contactID){
            List<String> updated = new List<String>.from(conList);
            updated.remove(contactID);
            return updated;
          }
          
          List<String> addContact(List<String> conList, String contactID){
            List<String> updated = new List<String>.from(conList);
            updated.add(contactID);
            return updated;
          }
          
          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<List<String>>(
                    initialValue: item.value,
                    onSaved: (List<String> value) {
                      item.value = value;
                      currentData["contacts"] = value;
                    },
                    builder: (FormFieldState<List<String>> field){
                      Column x =  new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: field.value.map((String contactID){
                          Map<String, dynamic> conData = firebase.getObject("contacts", contactID);
                          return new Chip(
                            label: new Text(conData["name"]),
                            onDeleted: () {
                              field.onChanged(removeContact(field.value, contactID));
                            }
                          );
                        }).toList()
                      );
                      x.children.insert(0, new ListTile(
                        title: new Text("Add a contact"),
                        trailing: new Icon(Icons.add),
                        onTap: () async {
                          final String chosen = await pickFromCategory(
                            context: context,
                            category: "contacts",
                          );
                          if (chosen != null && !field.value.contains(chosen)){
                            field.onChanged(addContact(field.value, chosen));
                          }
                        }
                      ));
                      return x;
                    }
                  ),
                );
              }
            ),
          );
        }
      )
    ];
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
              }).toList()
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
                  onPressed: () async {
                    await firebase.sendObject("locations", currentData);
                    Navigator.pop(context);
                  },
                )
              ],
            )
          ]
        )
      )
    ));
  }
}