import 'dart:async';
import 'package:flutter/material.dart';
import '../../pages/selector.dart';

/// Takes a [DateTime] and replaces its time with one from a [TimeOfDay]
DateTime replaceTimeOfDay(DateTime dt, TimeOfDay tod){
  return new DateTime(
    dt.year,
    dt.month,
    dt.day,
    tod.hour,
    tod.minute
  );
}

/// This takes two [DateTime]s and returns a new one with the second's date
/// and the first's time.
DateTime replaceDate(DateTime original, DateTime newdt){
  return new DateTime(
    newdt.year,
    newdt.month,
    newdt.day,
    original.hour,
    original.minute
  );
}

/// AsyncContactChip creates a [Chip] that displays "Loading..." until
/// the provided [Future] returns.
/// In this instance, the text it changes to is the Map's `name` property.
/// But it can be easily modified for other uses.
/// I love this little snippet for some reason.
class AsyncChip extends StatefulWidget {
  final Future<Map<String, dynamic>> contactData;
  final VoidCallback onDeleted;

  /// Takes a [Future] Contact and a [VoidCallback] and creates
  /// a [Chip] that when the Future returns will read the Contact's
  /// name.
  AsyncChip(this.contactData, this.onDeleted);

  @override
  _AsyncChipState createState() => new _AsyncChipState();
}

class _AsyncChipState extends State<AsyncChip>{
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

/// Open a [SelectorPage] to pick an object.
Future<Map<String, dynamic>> pickFromCategory({
  BuildContext context,
  String category,
  List<String> initialObjects,
}) async {
  return await Navigator.of(context).push(
    new MaterialPageRoute<Map<String, dynamic>>(
      builder: (BuildContext context) => new SelectorPage(category, initialObjects),
      fullscreenDialog: true,
    )
  );
}

// Internal: Most of the following code is borrowed from 
// flutter/examples/flutter_gallery/lib/demo/material/expansion_panels_demo.dart

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