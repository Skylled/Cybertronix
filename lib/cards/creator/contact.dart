import 'package:flutter/material.dart';
import 'tools.dart';

/// This [Card] opens in a dialog, and lets you create a 
/// new contact, or, if fed in data and an ID, edit an existing
/// contact.
class ContactCreatorCard extends StatefulWidget {
  /// The data of an existing contact to be edited (Optional)
  final Map<String, dynamic> contactData;
  
  final Function(Map<String, dynamic>) changeData;

  /// Creates a Contact creator/editor in a Card
  ContactCreatorCard(this.changeData, {Map<String, dynamic> contactData}):
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
    widget.changeData(currentData);
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
                        widget.changeData(currentData);
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
                        widget.changeData(currentData);
                      }
                    ),
                  ),
                );
              },
            )
          );
        }
      ),
      // [{"number": "555-555-5555", "type": "Cell"},]
      new CreatorItem<String>(
        name: "Phone number",
        value: widget.contactData["phoneNumbers"] != null ?
               widget.contactData["phoneNumbers"][0]["number"] : "",
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
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: item.textController,
                        decoration: new InputDecoration(
                          hintText: item.hint,
                          labelText: item.name,
                        ),
                        onSaved: (String value){
                          item.value = value;
                          if (currentData['phoneNumbers'] == null){
                            currentData['phoneNumbers'] = <Map<String, String>>[<String, String>{"type": "Cell", "number": value}];
                          } else {
                            currentData['phoneNumbers'][0]["number"] = value;
                          }
                          widget.changeData(currentData);
                        }
                      )
                    ],
                  ),
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
                        widget.changeData(currentData);
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
                        widget.changeData(currentData);
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