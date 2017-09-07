import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import 'components.dart';

/// This [Card] opens in a dialog, and lets you create a 
/// new job, or, if fed in data and an ID, edit an existing job.
class JobCreatorCard extends StatefulWidget {
  /// The data of an existing job to be edited (Optional)
  final Map<String, dynamic> jobData;
  /// The ID of an existing job to edit (Optional)
  final String jobID;

  final Function(Map<String, dynamic>) changeData;

  /// Creates a job creator/editor in a Card
  JobCreatorCard(this.changeData, {Map<String, dynamic> jobData, String jobID}):
    this.jobID = jobID,
    this.jobData = jobData ?? <String, dynamic>{};

  @override
  _JobCreatorCardState createState() => new _JobCreatorCardState();
}

class _JobCreatorCardState extends State<JobCreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;

  String locationName = "";
  String customerName = "";

  DateFormat datefmt = new DateFormat("EEEE, MMMM d");
  DateFormat timefmt = new DateFormat("h:mm a");
  DateFormat fullfmt = new DateFormat("h:mm a, EEEE, MMMM d");

  List<String> addObj(List<String> objList, String objID){
    List<String> updated = new List<String>.from(objList);
    updated.add(objID);
    return updated;
  }

  List<String> removeObj(List<String> objList, String objID){
    List<String> updated = new List<String>.from(objList);
    updated.remove(objID);
    return updated;
  }

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
        value: widget.jobData['name'] ?? '',
        hint: "(i.e. Pump test at CVS Amite)",
        valueToString: (String value) => value,
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
                        widget.changeData(currentData);
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
        value: widget.jobData["datetime"] != null ? DateTime.parse(widget.jobData["datetime"]) : new DateTime.now(),
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
                      widget.changeData(currentData);
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
        value: widget.jobData["location"],
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
                      widget.changeData(currentData);
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
                                initialObjects: <String>[field.value],
                              );
                              if (chosen != null && chosen["id"] != field.value){
                                debugPrint("Chosen was okay.");
                                locationName = chosen["name"];
                                field.onChanged(chosen["id"]);
                              } else {
                                debugPrint("Chosen was not okay!");
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
        value: widget.jobData["customer"],
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
                      widget.changeData(currentData);
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
                                initialObjects: <String>[field.value],
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
        value: widget.jobData['contacts'] ?? <String>[],
        hint: "Who is involved with this job?",
        valueToString: (List<String> value) {
          if (value != null){
            if (value.length == 1){
              return value.first;
            } else if (value.length > 1) {
              return value.length.toString();
            }
          }
          return "Select contacts";
        },
        builder: (CreatorItem<List<String>> item){
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
                  child: new FormField<List<String>>(
                    initialValue: item.value,
                    onSaved: (List<String> value) {
                      item.value = value;
                      currentData["contacts"] = value;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<List<String>> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: (){
                          List<Widget> chips = new List<Widget>();
                          chips.add(
                            new ListTile(
                              title: new Text("Add a contact"),
                              trailing: new Icon(Icons.add),
                              onTap: () async {
                                Map<String, dynamic> chosen = await pickFromCategory(
                                  context: context,
                                  category: "contacts",
                                  initialObjects: field.value,
                                );
                                if (chosen != null && !field.value.contains(chosen["id"])){
                                  field.onChanged(addObj(field.value, chosen["id"]));
                                }
                              },
                            ),
                          );
                          field.value.forEach((String contactID){
                            chips.add(
                              new AsyncChip(
                                firebase.getObject("contacts", contactID), (){
                                  field.onChanged(removeObj(field.value, contactID));
                                },
                              ),
                            );
                          });
                          return chips;
                        }(),
                      );
                    }
                  ),
                );
              }
            ),
          );
        }
      ),
      new CreatorItem<Map<String, bool>>( // Users
        name: "Users",
        value: widget.jobData["users"] ?? <String, bool>{},
        hint: "Which employees are assigned to this job?",
        valueToString: (Map<String, bool> value) {
          if (value != null){
            if (value.length == 1){
              return value.keys.first;
            } else if (value.length > 1) {
              return value.length.toString();
            }
          }
          return "Select users";
        },
        builder: (CreatorItem<Map<String, bool>> item) {
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
                  child: new FormField<Map<String, bool>>(
                    initialValue: item.value,
                    onSaved: (Map<String, bool> value){
                      item.value = value;
                      currentData["users"] = value;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<Map<String, bool>> field) {
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: (){
                          List<Widget> chips = new List<Widget>();
                          chips.add(
                            new ListTile(
                              title: new Text("Add a user"),
                              trailing: new Icon(Icons.add),
                              onTap: () async {
                                Map<String, dynamic> chosen = await pickFromCategory(
                                  context: context,
                                  category: "users",
                                );
                                if (chosen != null){
                                  field.onChanged((){
                                    Map<String, bool> updated = new Map<String, bool>.from(field.value);
                                    updated[chosen["id"]] = true;
                                    return updated;
                                  }());
                                }
                              },
                            )
                          );
                          field.value.keys.forEach((String userID){
                            chips.add(
                              new AsyncChip(firebase.getObject("users", userID), (){
                                field.onChanged((){
                                  Map<String, bool> updated = new Map<String, bool>.from(field.value);
                                  updated.remove(userID);
                                }());
                              })
                            );
                          });

                          return chips;
                        }(),
                      );
                    },
                  )
                );
              },
            ),
          );
        }
      ),
      new CreatorItem<String>( // Notes
        name: "Notes",
        value: widget.jobData['notes'] ?? '',
        hint: "(Anything special about this job?)",
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
      )
      // Future: Billing [po, billed?]
    ];
  }

  Widget build(BuildContext build){
    return(new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ExpansionPanelList(
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
          }).toList(),
        ),
      ),
    ));
  }
}