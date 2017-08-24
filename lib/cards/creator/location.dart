import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import 'components.dart';

// TODO MAJOR: Something wrong when hitting Save and Finish on this when called from a JobCreatorCard.
// Path: JobCreatorCard -> SelectorDialog -> LocationCreatorCard

/// This [Card] opens in a dialog, and lets you create a 
/// new Location, or, if fed in data and an ID, edit an existing
/// Location.
class LocationCreatorCard extends StatefulWidget {
  /// The data of an existing Location to be edited (Optional)
  final Map<String, dynamic> locationData;
  /// The ID of an existing Location to edit (Optional)
  final String locationID;

  /// Creates a Location creator/editor in a Card
  LocationCreatorCard({Map<String, dynamic> locationData, String locationID}):
    this.locationID = locationID,
    this.locationData = locationData ?? <String, dynamic>{};
  
  @override
  _LocationCreatorCardState createState() => new _LocationCreatorCardState();
}

class _LocationCreatorCardState extends State<LocationCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.locationData != null ? new Map<String, dynamic>.from(widget.locationData) : <String, dynamic> {};
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
                String _address = widget.locationData["address"];
                String _city = widget.locationData["city"];
                String _state = widget.locationData["state"];
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
                            controller: new TextEditingController(text: field.value["address"]),
                            decoration: new InputDecoration(
                              hintText: "(e.g. 1515 Poydras St)",
                              labelText: "Street address"
                            ),
                            onChanged: (String value){
                              _address = value;
                            },
                          ),
                          new TextField(
                            controller: new TextEditingController(text: field.value["city"]),
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
                              items: states,
                              onChanged: (String value){
                                _state = value;
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
      new CreatorItem<List<String>>( // Contacts
        name: "Contacts",
        value: widget.locationData["contacts"] ?? <String>[],
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
                      Column col =  new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: field.value.map((String contactID){
                          return new AsyncChip(firebase.getObject("contacts", contactID), (){
                            field.onChanged(removeContact(field.value, contactID));
                          });
                        }).toList()
                      );
                      col.children.insert(0, new ListTile(
                        title: new Text("Add a contact"),
                        trailing: new Icon(Icons.add),
                        onTap: () async {
                          Map<String, dynamic> chosen = await pickFromCategory(
                            context: context,
                            category: "contacts",
                          );
                          if (chosen != null && !field.value.contains(chosen["id"])){
                            field.onChanged(addContact(field.value, chosen["id"]));
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
                      },
                    ),
                  ),
                );
              },
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
                    firebase.sendObject("locations", currentData, objID: widget.locationID);
                    Navigator.pop(context, currentData);
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