
import 'dart:async';
import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;
import '../../dialogs/selector.dart';

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
  Map<String, dynamic> data = firebase.getObject(category, id);
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