import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';

class ContactInfoCard extends StatefulWidget {
  final String contactID;
  final Map<String, dynamic> contactData;

  ContactInfoCard(String contactID, {Map<String, dynamic> contactData: null}):
    this.contactID = contactID,
    this.contactData = (contactData == null && contactID != null) ? firebase.getObject("contacts", contactID) : contactData;
  
  @override
  _ContactInfoCardState createState() => new _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {

  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showCreatorCard(context, "contacts", data: widget.contactData);
  }

  void goShare(){
    // TODO: Make this contact into a VCard and give it to the SMS app?
  }

  void populateLines(){
    cardLines.add(
      new Container( // TODO: Make this a shrinking title?
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            // TODO: If contact doesn't have an image, use a placeholder.
            new Positioned.fill(
              child: new Image.asset('assets/hey_ladies.jpg')
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
          leading: new Icon(Icons.work), // TODO: Maybe a building icon?
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
                // TODO: double check url
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
                icon: new Icon(Icons.content_copy), // TODO: What icon here?
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
  void initState(){
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