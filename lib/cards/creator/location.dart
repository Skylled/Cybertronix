import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tools.dart';

/// This [Card] opens in a dialog, and lets you create a 
/// new Location, or, if fed in data and an ID, edit an existing
/// Location.
class LocationCreatorCard extends StatefulWidget {
  /// The data of an existing Location to be edited (Optional)
  final Map<String, dynamic> locationData;
  /// The containing page's callback to change data
  final Function(Map<String, dynamic>) changeData;

  /// Creates a Location creator/editor in a Card
  LocationCreatorCard(this.changeData, {Map<String, dynamic> locationData}):
    this.locationData = locationData ?? <String, dynamic>{};
  
  @override
  _LocationCreatorCardState createState() => new _LocationCreatorCardState();
}

class _LocationCreatorCardState extends State<LocationCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;
  String _address;
  String _city;
  String _state;

  @override
  void initState(){
    super.initState();
    currentData = widget.locationData != null ? new Map<String, dynamic>.from(widget.locationData) : <String, dynamic> {};
    _address = widget.locationData["address"];
    _city = widget.locationData["city"];
    _state = widget.locationData["state"];
    _items = getLocationItems();
  }

  List<CreatorItem<dynamic>> getLocationItems(){
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Name
        name: "Name",
        value: widget.locationData["name"] ?? '',
        hint: "(i.e. Cargill Avery Island)",
        valueToString: (String value) => value,
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
                        widget.changeData(currentData);
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
        value: <String, String>{"address": widget.locationData["address"],
                                "city": widget.locationData['city'],
                                "state": widget.locationData['state']},
        hint: "The street address for the location",
        valueToString: (Map<String, String> addressInfo){
          String addressString = "";
          if (addressInfo["address"] != null)
            addressString += (addressInfo["address"] + ", ");
          if (addressInfo["city"] != null)
            addressString += (addressInfo["city"] + ", ");
          if (addressInfo["state"] != null)
            addressString += addressInfo["state"];
          if (addressString == "")
            return "";
          return addressString;
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
                  onSave: (){
                    Form.of(context).save();
                    close();
                  },
                  onCancel: (){
                    Form.of(context).reset();
                    close();
                  },
                  child: new FormField<Map<String, String>>(
                    initialValue: item.value,
                    onSaved: (Map<String, String> value){
                      value["address"] = _address;
                      value["city"] = _city;
                      value["state"] = _state;
                      item.value = value;
                      currentData["address"] = value["address"];
                      currentData["city"] = value["city"];
                      currentData["state"] = value["state"];
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<Map<String, String>> field){
                      List<DropdownMenuItem<String>> states = <DropdownMenuItem<String>>[];
                      <String>["LA", "MS", "AL", "TX", "FL", "AK", "TN"].forEach((String st){
                        states.add(new DropdownMenuItem<String>(value: st, child: new Text(st)));
                      });

                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new TextField(
                            controller: new TextEditingController(text: _address),
                            decoration: new InputDecoration(
                              hintText: "(e.g. 1515 Poydras St)",
                              labelText: "Street address"
                            ),
                            onChanged: (String value){
                              _address = value;
                            },
                          ),
                          new TextField(
                            controller: new TextEditingController(text: _city),
                            decoration: new InputDecoration(
                              hintText: "(e.g. New Orleans)",
                              labelText: "City"
                            ),
                            onChanged: (String value){
                              _city = value;
                            },
                          ),
                          new Align(
                            alignment: FractionalOffset.centerRight,
                            child: new DropdownButton<String>(
                              hint: new Text("State"),
                              value: _state,
                              items: states,
                              onChanged: (String value){
                                setState((){
                                  _state = value;
                                });
                              },
                            ),
                          ),
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
      new CreatorItem<List<DocumentReference>>( // Contacts
        name: "Contacts",
        value: widget.locationData["contacts"] ?? <DocumentReference>[],
        hint: "Who is involved with this job?",
        valueToString: (List<DocumentReference> value) => value.length.toString(),
        builder: (CreatorItem<List<DocumentReference>> item){
          void close() {
            setState((){
              item.isExpanded = false;
            });
          }
          List<DocumentReference> removeContact(List<DocumentReference> conList, DocumentReference contactID){
            List<DocumentReference> updated = new List<DocumentReference>.from(conList);
            updated.remove(contactID);
            return updated;
          }
          
          List<DocumentReference> addContact(List<DocumentReference> conList, DocumentReference contactID){
            List<DocumentReference> updated = new List<DocumentReference>.from(conList);
            updated.add(contactID);
            return updated;
          }
          
          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<List<DocumentReference>>(
                    initialValue: item.value,
                    onSaved: (List<DocumentReference> value) {
                      item.value = value;
                      currentData["contacts"] = value;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<List<DocumentReference>> field){
                      Column col =  new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: field.value.map((DocumentReference contactID){
                          void onDeleted(){
                            field.onChanged(removeContact(field.value, contactID));
                          }
                          return new StreamBuilder<DocumentSnapshot>(
                            stream: contactID.snapshots,
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                              if (!snapshot.hasData){
                                return new Chip(
                                  label: new Text("Loading..."),
                                  onDeleted: onDeleted,
                                );
                              }

                              return new Chip(
                                label: new Text(snapshot.data["name"]),
                                onDeleted: onDeleted,
                              );
                            },
                          );
                        }).toList()
                      );
                      col.children.insert(0, new ListTile(
                        title: new Text("Add a contact"),
                        trailing: new Icon(Icons.add),
                        onTap: () async {
                          DocumentSnapshot chosen = await pickFromCollection(
                            context: context,
                            collection: "contacts",
                          );
                          if (chosen != null && !field.value.contains(chosen.reference)){
                            field.onChanged(addContact(field.value, chosen.reference));
                          }
                        }
                      ));
                      return col;
                    }
                  ),
                );
              }
            ),
          );
        }
      ),
      new CreatorItem<String>( // Notes
        name: "Notes",
        value: widget.locationData["notes"] ?? '',
        hint: "(Anything special about this place?)",
        valueToString: (String value) => value,
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
                  onSave: (){ Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: new TextFormField(
                      maxLines: null,
                      controller: item.textController,
                      decoration: new InputDecoration(
                        hintText: item.hint,
                        labelText: item.name,
                      ),
                      onSaved: (String value){
                        item.value = value;
                        currentData['notes'] = value;
                        widget.changeData(currentData);
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

  Widget build(BuildContext build){
    return(new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ExpansionPanelList(
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
      ),
    ));
  }
}