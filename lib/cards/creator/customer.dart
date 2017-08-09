import 'package:flutter/material.dart';
import '../../firebase.dart' as firebase;

class CustomerCreatorCard extends StatefulWidget {
  @override
  _CustomerCreatorCardState createState() => new _CustomerCreatorCardState();
}

class _CustomerCreatorCardState extends State<CustomerCreatorCard> {
  String currentName;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Center(
        child: new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Center(
                child: new Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new Text(
                    "New Customer",
                    style: new TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
              ),
              // Maybe this should be a TextFormField?
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: new TextField(
                  decoration: new InputDecoration(
                    hintText: "(e.g. S&S Sprinkler)",
                    labelText: "Company name",
                  ),
                  onChanged: (String value){
                    currentName = value;
                  },
                ),
              ),
              new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: () { Navigator.pop(context); },
                  ),
                  new FlatButton(
                    child: new Text("Save"),
                    textColor: Theme.of(context).accentColor,
                    onPressed: (){
                      Map<String, String> customer = <String, String>{"name": currentName};
                      firebase.sendObject("customers", customer);
                      Navigator.pop(context, customer);
                    },
                  )
                ],
              ),
            ],
          )
        )
      )
    );
  }
}