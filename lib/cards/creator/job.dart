import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import 'components.dart';

class JobCreatorCard extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobID;

  JobCreatorCard({this.jobData, this.jobID});

  @override
  _JobCreatorCardState createState() => new _JobCreatorCardState();
}

class _JobCreatorCardState extends State<JobCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;
  List<String> contactList;

  String locationName = "";
  String customerName = "";

  DateFormat datefmt = new DateFormat("EEEE, MMMM d");
  DateFormat timefmt = new DateFormat("h:mm a");
  DateFormat fullfmt = new DateFormat("h:mm a, EEEE, MMMM d");

  void initState(){
    super.initState();
    currentData = widget.jobData != null ? new Map<String, dynamic>.from(widget.jobData) : <String, dynamic>{};
    if (currentData["location"] != null){
      firebase.getObject("locations", currentData["location"]).then((Map<String, dynamic> data){
        locationName = data["name"];
      });
    }
    if (currentData["customer"] != null){
      firebase.getObject("customers", currentData["customer"]).then((Map<String, dynamic> data){
        customerName = data["name"];
      });
    }
    _items = getJobItems();
  }

  List<CreatorItem<dynamic>> getJobItems() {
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Name
        name: "Title",
        value: widget.jobData != null ? widget.jobData['name'] : '',
        hint: "(i.e. Pump test at CVS Amite)",
        valueToString: (String value) => value == '' ? "Please enter a name" : value,
        builder: (CreatorItem<String> item){
          void close() {
            setState(() {
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
                      onSaved: (String value) {
                        item.value = value;
                        currentData['name'] = value;
                      }
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      new CreatorItem<DateTime>( // When
        name: "Date & time",
        value: widget.jobData != null ? DateTime.parse(widget.jobData["datetime"]) : new DateTime.now(),
        hint: "When is the job?",
        valueToString: (DateTime dt) => fullfmt.format(dt),
        builder: (CreatorItem<DateTime> item) {
          void close() {
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
                  child: new FormField<DateTime>(
                    initialValue: item.value,
                    onSaved: (DateTime value) {
                      item.value = value;
                      currentData["datetime"] = value.toIso8601String();
                    },
                    builder: (FormFieldState<DateTime> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(datefmt.format(field.value)),
                            trailing: new Icon(Icons.calendar_today),
                            onTap: () async {
                              final DateTime chosen = await showDatePicker(
                                context: context,
                                initialDate: field.value,
                                firstDate: new DateTime(2008),
                                lastDate: new DateTime(2068)
                              );
                              if (chosen != null && (chosen.year != field.value.year || chosen.month != field.value.month || chosen.day != field.value.day)){
                                print("I'm supposed to change here!");
                                field.onChanged(replaceDate(field.value, chosen));
                              }
                            }
                          ),
                          new ListTile(
                            title: new Text(timefmt.format(field.value)),
                            trailing: new Icon(Icons.access_time),
                            onTap: () async {
                              final TimeOfDay chosen = await showTimePicker(
                                context: context,
                                initialTime: new TimeOfDay.fromDateTime(field.value)
                              );
                              if (chosen != null) {
                                setState((){
                                  field.onChanged(replaceTimeOfDay(field.value, chosen));
                                });
                              }
                            }
                          )
                        ]
                      );
                    }
                  ),
                );
              }
            ),
          );
        }
      ),
      new CreatorItem<String>( // Location
        name: "Location",
        value: widget.jobData != null ? widget.jobData["location"] : null,
        hint: "Where is the job?",
        valueToString: (String locationID) {
          if (locationID != null){
            return locationName;
          } else {
            return "Select a location";
          }
        },
        builder: (CreatorItem<String> item) {
          void close() {
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
                  child: new FormField<String>(
                    initialValue: item.value,
                    onSaved: (String value) {
                      item.value = value;
                      currentData["location"] = value;
                    },
                    builder: (FormFieldState<String> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(item.valueToString(field.value)),
                            trailing: new Icon(Icons.create),
                            onTap: () async {
                              Map<String, dynamic> chosen = await pickFromCategory(
                                context: context,
                                category: "locations",
                                initialObject: field.value,
                              );
                              if (chosen != null && chosen["id"] != field.value){
                                locationName = chosen["name"];
                                field.onChanged(chosen["id"]);
                              }
                            }
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
      ),
      new CreatorItem<String>( // Customer
        name: "Customer",
        value: widget.jobData != null ? widget.jobData["customer"] : null,
        hint: "Who is this job for?",
        valueToString: (String customerID) {
          if (customerID != null){
            return customerName;
          } else {
            return "Select a customer";
          }
        },
        builder: (CreatorItem<String> item) {
          void close() {
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
                  child: new FormField<String>(
                    initialValue: item.value,
                    onSaved: (String value){
                      item.value = value;
                      currentData["customer"] = value;
                    },
                    builder: (FormFieldState<String> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(item.valueToString(item.value)),
                            trailing: new Icon(Icons.create),
                            onTap: () async {
                              Map<String, dynamic> chosen = await pickFromCategory(
                                context: context,
                                category: "customers",
                                initialObject: field.value,
                              );
                              if (chosen != null && chosen["id"] != field.value){
                                field.onChanged(chosen["id"]);
                              }
                            }
                          )
                        ]
                      );
                    }
                  ),
                );
              }
            )
          );
        }
      ),
      new CreatorItem<List<String>>( // Contacts
        name: "Contacts",
        value: widget.jobData != null ? widget.jobData['contacts'] : <String>[],
        hint: "Who is involved with this job?",
        valueToString: (List<String> value) {
          if (value.length == 1){
            return value.first;
          } else if (value.length > 1) {
            return value.length.toString();
          } else {
            return "Select contacts";
          }
        },
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
                          return new AsyncContactChip(firebase.getObject("contacts", contactID), (){
                            field.onChanged(removeContact(field.value, contactID));
                          });
                        }).toList()
                      );
                      x.children.insert(0, new ListTile(
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
                      return x;
                    }
                  ),
                );
              }
            ),
          );
        }
      )
      // TODO: Billing [po, billed?]
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
              expansionCallback: (int index, bool isExpanded) {
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
                  onPressed: (){ Navigator.pop(context); }
                ),
                new FlatButton(
                  child: new Text("Save & Finish"),
                  textColor: Theme.of(context).accentColor,
                  onPressed: () async {
                     firebase.sendObject("jobs", currentData, objID: widget.jobID);
                     Navigator.pop(context);
                  }
                )
              ]
            )
          ]
        )
      )
    ));
  }
}