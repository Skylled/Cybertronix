import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import 'components.dart';

/// This [Card] opens in a dialog, and lets you create a 
/// new contact, or, if fed in data and an ID, edit an existing
/// contact.
class ContactCreatorCard extends StatefulWidget {
  /// The data of an existing contact to be edited (Optional)
  final Map<String, dynamic> contactData;
  /// The ID of an existing contact to edit (Optional)
  final String contactID;

  /// Creates a Contact creator/editor in a Card
  ContactCreatorCard({Map<String, dynamic> contactData, String contactID}):
    this.contactID = contactID,
    this.contactData = contactData ?? <String, dynamic>{};
  
  @override
  _ContactCreatorCardState createState() => new _ContactCreatorCardState();
}

class _ContactCreatorCardState extends State<ContactCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  void initState(){
    super.initState();
    currentData = widget.contactData != null ? new Map<String, dynamic>.from(widget.contactData) : <String, dynamic>{};
    _items = getContactItems();
  }

  List<CreatorItem<dynamic>> getContactItems(){
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Name
        name: "Name",
        value: widget.contactData["name"] ?? '',
        hint: "John Smith",
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
                  onCancel: (){ Form.of(context).reset(); close(); },
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
                      validator: (String value){
                        if (value.length > 0){
                          return null;
                        } else {
                          return "Name must be entered.";
                        }
                      },
                    ),
                  ),
                );
              },
            )
          );
        }
      ),
      new CreatorItem<String>( // Company
        name: "Company",
        value: widget.contactData["company"] ?? '',
        hint: "ex: Turner Industries",
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
                  onCancel: (){ Form.of(context).reset(); close(); },
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
                        currentData['company'] = value;
                      }
                    ),
                  ),
                );
              },
            )
          );
        }
      ),
      // [{"number": "555-555-5555", "type": "cell"},]
      new CreatorItem<List<Map<String, String>>>(
        name: "Phone numbers",
        value: widget.contactData["phoneNumbers"] ?? new List<Map<String, String>>(),
        hint: "Work: 555-555-5555",
        valueToString: (List<Map<String, String>> value){
          if (value != null) {
            if (value.length == 1){
              return "${value[0]["type"]}: ${value[0]["number"]}";
            } else if (value.length == 2){
              // Special circumstance, due to defaults
              return "${value[0]["type"]}, ${value[1]["type"]}";
            } else if (value.length == 3) {
              return "${value[0]["type"]}, ${value[1]["type"]}, ${value[2]["type"]}";
            }
          }
          return "Enter phone number(s)";
        },
        builder: (CreatorItem<List<Map<String, String>>> item){
          void close() {
            setState((){
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context){
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<List<Map<String, String>>>(
                    initialValue: item.value,
                    onSaved: (List<Map<String, String>> value){
                      value.removeWhere((Map<String, String> phone){
                        if (phone["number"] == null){
                          return true;
                        } else if (phone["number"].length < 7) {
                          return true;
                        } else {
                          return false;
                        }
                      });
                      item.value = value;
                      currentData["phoneNumbers"] = value;
                    },
                    builder: (FormFieldState<List<Map<String, String>>> field){
                      List<Map<String, String>> _changeNumber(int index, String key, String value){
                        List<Map<String, String>> result = new List<Map<String, String>>.from(field.value);
                        result[index][key] = value;
                        return result;
                      }

                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // TODO: Refactor smaller.
                          new ListTile(
                            trailing: new DropdownButton<String>(
                              items: <DropdownMenuItem<String>>[
                                new DropdownMenuItem<String>(
                                  value: "Cell",
                                  child: new Icon(Icons.phone_android)
                                ),
                                new DropdownMenuItem<String>(
                                  value: "Office",
                                  child: new Icon(Icons.work)
                                )
                              ],
                              onChanged: (String value){
                                field.onChanged(_changeNumber(0, "type", value));
                              },
                              value: (){
                                if (field.value.length > 0){
                                  if (field.value[0] != null) {
                                    return field.value[0]["type"];
                                  }
                                }
                                return "Cell";
                              }(),
                            ),
                            title: new TextField(
                              keyboardType: TextInputType.phone,
                              controller: new TextEditingController(
                                text: (){
                                  if (field.value.length > 0){
                                    if (field.value[0] != null) {
                                      return field.value[0]["number"];
                                    }
                                  }
                                  return null;
                                }(),
                              ),
                              decoration: new InputDecoration(
                                hintText: "(555-555-5555 or 8005551234)",
                                labelText: "Phone number"
                              ),
                              onChanged: (String value){
                                field.onChanged(_changeNumber(0, "number", value));
                              },
                            )
                          ),
                          new ListTile(
                            trailing: new DropdownButton<String>(
                              items: <DropdownMenuItem<String>>[
                                new DropdownMenuItem<String>(
                                  value: "Cell",
                                  child: new Icon(Icons.phone_android)
                                ),
                                new DropdownMenuItem<String>(
                                  value: "Office",
                                  child: new Icon(Icons.work)
                                )
                              ],
                              onChanged: (String value){
                                field.onChanged(_changeNumber(1, "type", value));
                              },
                              value: (){
                                if (field.value.length > 1){
                                  if (field.value[1] != null) {
                                    return field.value[1]["type"];
                                  }
                                }
                                return "Office";
                              }(),
                            ),
                            title: new TextField(
                              keyboardType: TextInputType.phone,
                              controller: new TextEditingController(
                                text: (){
                                  if (field.value.length > 1){
                                    if (field.value[1] != null) {
                                      return field.value[1]["number"];
                                    }
                                  }
                                  return null;
                                }(),
                              ),
                              decoration: new InputDecoration(
                                hintText: "(555-555-5555 or 8005551234)",
                                labelText: "Phone number"
                              ),
                              onChanged: (String value){
                                field.onChanged(_changeNumber(1, "number", value));
                              },
                            )
                          ),
                        ],
                      );
                    },
                  )
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<String>( // Email address
        name: "Email Address",
        value: widget.contactData["email"] ?? '',
        hint: "name@company.com",
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
                  onCancel: (){ Form.of(context).reset(); close(); },
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
                        currentData['email'] = value;
                      }
                    ),
                  ),
                );
              },
            )
          );
        }
      ),
      new CreatorItem<String>( // Notes
        name: "Notes",
        value: widget.contactData['notes'] ?? '',
        hint: "(Anything to note about this person?)",
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
                      // TODO: Check if "Done" or "Enter" is shown.
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
                  onPressed: (){
                    firebase.sendObject("contacts", currentData, objID: widget.contactID);
                    Navigator.pop(context, currentData);
                  },
                )
              ],
            )
          ],
        )
      ),
    ));
  }
}