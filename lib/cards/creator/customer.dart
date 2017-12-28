import 'package:flutter/material.dart';

/// This simple Card allows for the creation of a new Customer.
class CustomerCreatorCard extends StatefulWidget {
  /// The data of the existing Customer to be edited (optional)
  final Map<String, dynamic> customerData;
  /// The containing page's callback to change data
  final Function(Map<String, dynamic>) changeData;
  
  /// Returns a new Customer Creator card with given data.
  CustomerCreatorCard(this.changeData, {Map<String, dynamic> customerData}):
    this.customerData = customerData ?? <String, dynamic> {};

  @override
  _CustomerCreatorCardState createState() => new _CustomerCreatorCardState();
}

class _CustomerCreatorCardState extends State<CustomerCreatorCard> {
  Map<String, dynamic> currentData;

  @override
  void initState(){
    super.initState();
    currentData = widget.customerData != null ? new Map<String, dynamic>.from(widget.customerData) : <String, dynamic> {};
  }

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
                  controller: new TextEditingController(text: currentData["name"]),
                  decoration: new InputDecoration(
                    hintText: "(e.g. S&S Sprinkler)",
                    labelText: "Company name",
                  ),
                  onChanged: (String value){
                    currentData["name"] = value;
                    widget.changeData(currentData);
                  },
                ),
              ),
            ],
          )
        )
      )
    );
  }
}