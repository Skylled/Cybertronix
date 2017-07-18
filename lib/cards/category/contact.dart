import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import '../creatorCards.dart';
import 'package:meta/meta.dart';

/// A Material Card with a contact's info
/// 
/// Usually used with [showDialog]
class ContactInfoCard extends StatefulWidget {
  /// The contact's ID in Firebase
  final String contactID;
  /// The contact data stored in Firebase
  final Map<String, dynamic> contactData;

  /// A Material Card with a contact's info
  ContactInfoCard(this.contactID, {
    @required this.contactData
    });
  
  @override
  _ContactInfoCardState createState() => new _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {

  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showCreatorCard(context, "contacts", data: widget.contactData, objID: widget.contactID).then((dynamic x){
      setState((){
        populateLines();
      });
    });
  }

  void goShare(){ // Hook this into something!
    String shareString = "${widget.contactData['name']}";
    if (widget.contactData["phone"] != null){
      shareString += "\n${widget.contactData['phone']}";
    }
    if (widget.contactData["email"] != null){
      shareString += "\n${widget.contactData['email']}";
    }
    share.share(shareString);
  }

  void populateLines(){
    cardLines.clear();
    cardLines.add(
      new Container( // Future: Make this a sliver
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            // TODO: If contact doesn't have an image, use a placeholder.
            new Positioned.fill(
              child: new Image.asset('assets/hey_ladies.jpg', fit: BoxFit.fitWidth)
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                widget.contactData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                )
              )
            )
          ]
        )
      )
    );
    if (widget.contactData["company"] != null){
      cardLines.add(
        new ListTile(
          leading: new Icon(Icons.business),
          title: new Text(widget.contactData["company"])
        )
      );
    }
    cardLines.add(new Divider());
    if (widget.contactData["phone"] != null) {
      // TODO: Refactor in Firebase to allow for multiple phone numbers.
      cardLines.add(
        new ListTile(
          title: new Text(widget.contactData["phone"]),
          trailing: new Row(children: <Widget>[
            new IconButton(
              icon: new Icon(Icons.message),
              onPressed: (){
                url_launcher.launch('sms:${widget.contactData["phone"]}');
              }
            ),
            new IconButton(
              icon: new Icon(Icons.phone),
              onPressed: (){
                url_launcher.launch('tel:${widget.contactData["phone"]}');
              }
            ),
          ]),
        )
      );
    }
    if (widget.contactData["email"] != null) {
      cardLines.add(
        new ListTile(
          title: new Text(widget.contactData["email"]),
          trailing: new Row(
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.content_copy),
                onPressed: () {
                  // TODO: Copy email to clipboard.
                }
              ),
              new IconButton(
                icon: new Icon(Icons.mail),
                onPressed: (){url_launcher.launch("mailto:${widget.contactData['email']}");}
              )
            ]
          )
        )
      );
    }
    cardLines.add(new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: new Text("Edit info"),
            onPressed: (){
              goEdit(context);
            }
          )
        ]
      )
    ));
  }

  @override
  void initState() {
    super.initState();
    populateLines();
  }

  @override
  Widget build(BuildContext context){
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ListView(
          children: new List<Widget>.from(cardLines)
        )
      )
    );
  }
}