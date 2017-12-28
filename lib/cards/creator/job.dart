import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tools.dart';

/// This [Card] opens in a dialog, and lets you create a 
/// new job, or, if fed in data and an ID, edit an existing job.
class JobCreatorCard extends StatefulWidget {
  /// The data of an existing job to be edited (Optional)
  final Map<String, dynamic> jobData;

  final Function(Map<String, dynamic>) changeData;

  /// Creates a job creator/editor in a Card
  JobCreatorCard(this.changeData, {Map<String, dynamic> jobData}):
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

  List<DocumentReference> addObj(List<DocumentReference> objList, DocumentReference objID){
    List<DocumentReference> updated = new List<DocumentReference>.from(objList);
    updated.add(objID);
    return updated;
  }

  List<DocumentReference> removeObj(List<DocumentReference> objList, DocumentReference objID){
    List<DocumentReference> updated = new List<DocumentReference>.from(objList);
    updated.remove(objID);
    return updated;
  }

  void initState(){
    // TODO: MAJOR: Refactor here!
    super.initState();
    currentData = widget.jobData != null ? new Map<String, dynamic>.from(widget.jobData) : <String, dynamic>{"datetime": new DateTime.now()};
    DocumentReference locationRef = currentData["location"];
    DocumentReference customerRef = currentData["customer"];
    if (locationRef != null){
      locationRef.snapshots.first.then((DocumentSnapshot snapshot){
        // TODO: Might need a setState here.
        locationName = snapshot["name"];
      });
    }
    if (customerRef != null){
      customerRef.snapshots.first.then((DocumentSnapshot snapshot){
        customerName = snapshot["name"];
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
      new CreatorItem<DocumentReference>( // Location
        name: "Location",
        value: widget.jobData["location"],
        hint: "Where is the job?",
        valueToString: (DocumentReference locationID) {
          if (locationID != null){
            return locationName;
          } else {
            return "Select a location";
          }
        },
        builder: (CreatorItem<DocumentReference> item) {
          void close() {
            setState((){
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                String tempName;
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<DocumentReference>(
                    initialValue: item.value,
                    onSaved: (DocumentReference value) {
                      item.value = value;
                      currentData["location"] = value;
                      locationName = tempName;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<DocumentReference> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(item.valueToString(field.value)),
                            trailing: new Icon(Icons.create),
                            onTap: () async {
                              DocumentSnapshot chosen = await pickFromCollection(
                                context: context,
                                collection: "locations",
                                initialObjects: <DocumentReference>[field.value],
                              );
                              if (chosen != null && chosen.reference != field.value){
                                debugPrint("Chosen was okay.");
                                tempName = chosen["name"];
                                field.onChanged(chosen.reference);
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
      new CreatorItem<DocumentReference>( // Customer
        name: "Customer",
        value: widget.jobData["customer"],
        hint: "Who is this job for?",
        valueToString: (DocumentReference customerID) {
          if (customerID != null){
            return customerName;
          } else {
            return "Select a customer";
          }
        },
        builder: (CreatorItem<DocumentReference> item) {
          void close() {
            setState((){
              item.isExpanded = false;
            });
          }

          String tempName;
          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  onSave: () { Form.of(context).save(); close(); },
                  onCancel: () { Form.of(context).reset(); close(); },
                  child: new FormField<DocumentReference>(
                    initialValue: item.value,
                    onSaved: (DocumentReference value){
                      item.value = value;
                      currentData["customer"] = value;
                      customerName = tempName;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<DocumentReference> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(item.valueToString(item.value)),
                            trailing: new Icon(Icons.create),
                            onTap: () async {
                              DocumentSnapshot chosen = await pickFromCollection(
                                context: context,
                                collection: "customers",
                                initialObjects: <DocumentReference>[field.value],
                              );
                              if (chosen != null && chosen.reference != field.value){
                                tempName = chosen["name"];
                                field.onChanged(chosen.reference);
                              }
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
      ),
      new CreatorItem<List<DocumentReference>>( // Contacts
        name: "Contacts",
        value: widget.jobData['contacts'] ?? <DocumentReference>[],
        hint: "Who is involved with this job?",
        valueToString: (List<DocumentReference> value) {
          if (value != null){
            return value.length.toString();
          }
          return "Select contacts";
        },
        builder: (CreatorItem<List<DocumentReference>> item){
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
                  child: new FormField<List<DocumentReference>>(
                    initialValue: item.value,
                    onSaved: (List<DocumentReference> value) {
                      item.value = value;
                      currentData["contacts"] = value;
                      widget.changeData(currentData);
                    },
                    builder: (FormFieldState<List<DocumentReference>> field){
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
                                DocumentSnapshot chosen = await pickFromCollection(
                                  context: context,
                                  collection: "contacts",
                                  initialObjects: field.value,
                                );
                                if (chosen != null && !field.value.contains(chosen.reference)){
                                  field.onChanged(addObj(field.value, chosen.reference));
                                }
                              },
                            ),
                          );
                          field.value.forEach((DocumentReference contactID){
                            chips.add(
                              new StreamBuilder<DocumentSnapshot>(
                                stream: contactID.snapshots,
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                                  void onDeleted(){
                                    field.onChanged(removeObj(field.value, contactID));
                                  }

                                  if (!snapshot.hasData) {
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