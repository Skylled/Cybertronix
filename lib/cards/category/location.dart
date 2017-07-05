import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share/share.dart' as share;
import 'package:intl/intl.dart';
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../categoryCards.dart';

class LocationInfoCard extends StatefulWidget {
  final String locationID;
  final Map<String, dynamic> locationData;

  LocationInfoCard(this.locationID, {this.locationData});
  
  @override
  _LocationInfoCardState createState() => new _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard> {
  
  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    setState(() async {
      await showCreatorCard(context, "locations", data: widget.locationData);
      populateLines();
    });
  }

  void goShare(){
    String shareString = "${widget.locationData['name']}\n${widget.locationData['address']}";
    shareString += "\n${widget.locationData['city']}, ${widget.locationData['state']} ${widget.locationData['zipcode']}";
    share.share(shareString);
  }

  void populateLines(){
    cardLines = <Widget>[];
    cardLines.add(
      new Container( // TODO: Make this a shrinking title?
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            // TODO: If location doesn't have an image, use a placeholder.
            new Positioned.fill(
              child: new Image.asset('assets/placeholder.jpg', fit: BoxFit.fitWidth)
            ),
            new Positioned(
              left: 8.0,
              bottom: 16.0,
              child: new Text(
                widget.locationData["name"],
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
    String subtitle = "${widget.locationData['city']}, ${widget.locationData['state']} ${widget.locationData['zipcode']}";
    cardLines.add(
      new ListTile(
        title: new Text(widget.locationData["address"]),
        subtitle: new Text(subtitle),
        trailing: new Icon(Icons.navigation),
        onTap: () {
          url_launcher.launch('google.navigation:q=${widget.locationData["address"]}, $subtitle');
        }
      )
    );
    if (widget.locationData["contacts"] != null) {
      cardLines.add(new Divider());
      // `offset` essentially marks where the divider is, and thus, where to insert
      int offset = cardLines.length;
      widget.locationData["contacts"].forEach((String contactID) {
        firebase.getObject("contacts", contactID).then((Map<String, dynamic> contactData){
          setState((){
            Widget trailing = (contactData["phone"] != null)
                ? new IconButton(icon: new Icon(Icons.phone),
                    onPressed: (){ url_launcher.launch('tel:${contactData["phone"]}'); })
                : null;
            cardLines.insert(offset, new ListTile(
              title: new Text(contactData["name"]),
              trailing: trailing,
              onTap: () {
                showCategoryCard(context, "contacts", contactID, data: contactData);
              }
            ));
          });
        });
      });
    }
    if (widget.locationData["packages"] != null){
      // Firebase lists cannot be length 0
      cardLines.add(new Divider());
      List<Widget> packageLines = <Widget>[];

      widget.locationData["packages"].forEach((Map<String, dynamic> package){
        Map<String, dynamic> panel = package["panel"];
        String title = "${panel != null ? panel['manufacturer'] : ''} ${package['power']}";
        packageLines.add(new ListTile(
          title: new Text(title),
          onTap: (){ showPackageCard(context, package); },
        ));
      });

      cardLines.add(new ExpansionTile(
        title: new Text("Packages"),
        children: packageLines,
      ));
    }
    cardLines.add(new Divider());
    // This doesn't have to be async. Just adding some responsiveness.
    // This query could be huge.
    List<Widget> prevJobs = <Widget>[new ListTile(title: new Text("Loading..."))];
    firebase.findJobs("location", widget.locationID)
    .then((Map<String, Map<String, dynamic>> results){
      setState((){
        prevJobs.clear();
        DateFormat datefmt = new DateFormat("M/d/y");
        results.forEach((String jobID, Map<String, dynamic> jobData){
          DateTime date = DateTime.parse(jobData["datetime"]);
          prevJobs.add(new ListTile(
            title: new Text("${datefmt.format(date)} ${jobData['name']}"),
            onTap: (){
              showCategoryCard(context, "jobs", jobID, data: jobData);
            }
          ));
        });
      });
    });
    cardLines.add(new ExpansionTile(
      title: new Text("Jobs"),
      children: new List<Widget>.from(prevJobs)
    ));
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
          children: new List<Widget>.from(cardLines),
        ),
      ),
    );
  }
}