
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../firebase.dart';
import '../dialogs/selector.dart';

// Internal: Most of this code borrowed from expansion_panels_demo.dart

DateTime replaceTimeOfDay(DateTime dt, TimeOfDay tod){
  return new DateTime(
    dt.year,
    dt.month,
    dt.day,
    tod.hour,
    tod.minute
  );
}

DateTime replaceDate(DateTime original, DateTime newdt){
  return new DateTime(
    newdt.year,
    newdt.month,
    newdt.day,
    original.hour,
    original.minute
  );
}

Map<String, dynamic> mapFromID(String category, String id) {
  Map<String, dynamic> objMap = <String, dynamic>{"id": id};
  Map<String, dynamic> data = getObject(category, id);
  objMap["data"] = data;
  return objMap;
}

class AsyncContactChip extends StatefulWidget {
  final Future<Map<String, dynamic>> contactData;
  final VoidCallback onDeleted;

  AsyncContactChip(this.contactData, this.onDeleted);

  @override
  _AsyncContactChipState createState() => new _AsyncContactChipState();
}

class _AsyncContactChipState extends State<AsyncContactChip>{
  String label;
  @override
  void initState() {
    super.initState();
    label = "Loading...";
    widget.contactData.then((Map<String, dynamic> data){
      setState((){
        label = data["name"];
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return new Chip(
      label: new Text(label),
      onDeleted: widget.onDeleted
    );
  }
}

Future<String> pickFromCategory({
  BuildContext context,
  String category,
  String initialObject: null,
}) async {
  return await showDialog(
    context: context,
    child: new SelectorDialog(
      category: category,
      initialObject: initialObject
    )
  );
}

typedef Widget CreatorItemBodyBuilder<T>(CreatorItem<T> item);
typedef String ValueToString<T>(T value);

// Consider actually reading this?
class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({
    this.name,
    this.value,
    this.hint,
    this.showHint
  });

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return new AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 2,
          child: new Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: new FittedBox(
              fit: BoxFit.scaleDown,
              alignment: FractionalOffset.centerLeft,
              child: new Text(
                name,
                style: textTheme.body1.copyWith(fontSize: 15.0),
              ),
            ),
          ),
        ),
        new Expanded(
          flex: 3,
          child: new Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: _crossFade(
              new Text(value, style: textTheme.caption.copyWith(fontSize: 15.0)),
              new Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
              showHint
            )
          )
        )
      ]
    );
  }
}

// Maybe I'll read this eventually.
class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({
    this.margin: EdgeInsets.zero,
    this.child,
    this.onSave,
    this.onCancel
  });

  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return new Column(
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 24.0
          ) - margin,
          child: new Center(
            child: new DefaultTextStyle(
              style: textTheme.caption.copyWith(fontSize: 15.0),
              child: child
            )
          )
        ),
        const Divider(height: 1.0),
        new Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: new FlatButton(
                  onPressed: onCancel,
                  child: const Text('CANCEL', style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500
                  ))
                )
              ),
              new Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: new FlatButton(
                  onPressed: onSave,
                  textTheme: ButtonTextTheme.accent,
                  child: const Text('SAVE')
                )
              )
            ]
          )
        )
      ]
    );
  }
}

class CreatorItem<T> {
  CreatorItem({
    this.name,
    this.value,
    this.hint,
    this.builder,
    this.valueToString
  }) : textController = new TextEditingController(text: valueToString(value));

  final String name;
  final String hint;
  final TextEditingController textController;
  final CreatorItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value; // How does this work?
  bool isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return new DualHeaderWithHint(
        name: name,
        value: valueToString(value),
        hint: hint,
        showHint: isExpanded
      );
    };
  }
}

// TODO: Save object using currentData

// TODO: Keep in mind! Data is sometimes loaded instead of IDs
// Look for ID strings that might be maps instead
class CreatorCard extends StatefulWidget {
  final String category;
  final Map<String, dynamic> data;

  CreatorCard(String category, {Map<String, dynamic> data: null}):
    this.category = category,
    this.data = data;

  @override
  _CreatorCardState createState() => new _CreatorCardState();
}

class _CreatorCardState extends State<CreatorCard> {
  List<CreatorItem<dynamic>> _items;
  Map<String, dynamic> currentData;
  List<String> contactList;

  DateFormat datefmt = new DateFormat("EEEE, MMMM d");
  DateFormat timefmt = new DateFormat("h:mm a");
  DateFormat fullfmt = new DateFormat("h:mm a, EEEE, MMMM d");

  void initState(){
    super.initState();
    currentData = widget.data != null ? new Map<String, dynamic>.from(widget.data) : <String, dynamic>{};
    switch (widget.category) {
      case 'jobs':
        _items = getJobItems();
    }
  }

  List<CreatorItem<dynamic>> getJobItems() {
    return <CreatorItem<dynamic>>[
      new CreatorItem<String>( // Name
        name: "Title",
        value: widget.data != null ? widget.data['name'] : '',
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
        // TODO: Bug! If you pick the time after the date, the date resets back.
        name: "Date & time",
        value: widget.data != null ? DateTime.parse(widget.data["datetime"]) : new DateTime.now(),
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
      new CreatorItem<Map<String, dynamic>>( // Location
        name: "Location",
        value: widget.data != null ? <String, dynamic>{"id": widget.data["location"],
                                                       "data": widget.data["locationData"]} 
                                   : <String, dynamic>{"id": "",
                                                       "data": <String, dynamic>{"name": "Select a location"}},
        hint: "Where is the job?",
        valueToString: (Map<String, dynamic> loc) => loc["data"]["name"],
        builder: (CreatorItem<Map<String, dynamic>> item) {
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
                  child: new FormField<Map<String, dynamic>>(
                    initialValue: item.value,
                    onSaved: (Map<String, dynamic> value) {
                      item.value = value;
                      currentData["location"] = value["id"];
                      currentData["locationData"] = value["data"];
                    },
                    builder: (FormFieldState<Map<String, dynamic>> field){
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            title: new Text(field.value["data"]["name"]),
                            trailing: new Icon(Icons.create),
                            onTap: () async {
                              final String chosen = await pickFromCategory(
                                context: context,
                                category: "locations",
                                initialObject: field.value["id"],
                              );
                              if (chosen != null && chosen != field.value["id"]){
                                field.onChanged(mapFromID("locations", chosen));
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
      new CreatorItem<String>( // TODO: Customer
        name: "Customer",
        value: widget.data != null ? widget.data["customer"] : null,
        hint: "Who is this job for?",
        valueToString: (String customerID) {
          if (customerID != null){
            
          }
        }
      ),
      new CreatorItem<List<String>>( // Contacts
        name: "Contacts",
        value: widget.data != null ? widget.data['contacts'] : <String>[],
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
                          Map<String, dynamic> conData = getObject("contacts", contactID);
                          return new Chip(
                            label: conData["name"],
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
      // TODO: Billing [po, billed?]
      // TODO: Notes
    ];
  }

  Widget build(BuildContext build){
    return(new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new Column(
          children: <Widget>[
            new SingleChildScrollView(
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
                }).toList()
              )
            ),
            new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: new Text("Save"),
                  onPressed: (){} // TODO: Pass currentData to Firebase.
                ),
                new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: (){
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