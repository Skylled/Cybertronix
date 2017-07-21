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
  ContactCreatorCard({this.contactData, this.contactID});
  
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
        value: widget.contactData != null ? widget.contactData["name"] : '',
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
        value: widget.contactData != null ? widget.contactData["company"] : '',
        hint: "ex: S&S Sprinkler",
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
      // TODO: This should be a List of phone numbers.
      new CreatorItem<String>( // Phone number
        name: "Phone number",
        value: widget.contactData != null ? widget.contactData["phone"] : '',
        hint: "555-555-5555",
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
                        currentData['phone'] = value;
                      }
                    ),
                  ),
                );
              },
            )
          );
        }
      ),
      new CreatorItem<String>( // Email address
        name: "Email Address",
        value: widget.contactData != null ? widget.contactData["email"] : '',
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
      )
      // TODO: Notes
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