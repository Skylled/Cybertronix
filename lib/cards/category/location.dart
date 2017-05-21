import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../firebase.dart' as firebase;
import '../creatorCards.dart';
import '../categoryCards.dart';

class LocationInfoCard extends StatefulWidget {
  final String locationID;
  final Map<String, dynamic> locationData;

  LocationInfoCard(String locationID, {Map<String, dynamic> locationData: null}):
    this.locationID = locationID,
    this.locationData = (locationData == null && locationID != null) ? firebase.getObject("locations", locationID) : locationData;
  
  @override
  _LocationInfoCardState createState() => new _LocationInfoCardState();
}

class _LocationInfoCardState extends State<LocationInfoCard> {
  
  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showCreatorCard(context, "locations", data: widget.locationData);
  }

  void populateLines(){
    cardLines.add(
      new Container( // TODO: Make this a shrinking title?
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            // TODO: If location doesn't have an image, use a placeholder.
            new Positioned.fill(
              child: new Image.asset('assets/placeholder.jpg')
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
      widget.locationData["contacts"].forEach((String contactID) {
        Map<String, dynamic> contactData = firebase.getObject("contacts", contactID);
        Widget trailing = (contactData["phone"] != null) ? new IconButton(icon: new Icon(Icons.phone),
                                                                          onPressed: (){ url_launcher.launch('tel:${contactData["phone"]}'); }) 
                                                         : null;
        cardLines.add(new ListTile(
          title: new Text(contactData["name"]),
          trailing: trailing,
          onTap: () {
            showCategoryCard(context, "contacts", contactID, data: contactData);
          }
        ));
      });
    }
    if (widget.locationData["packages"] != null){
      // Firebase lists cannot be length 0
      cardLines.add(new Divider());
      cardLines.add(
        new ListTile(
          dense: true,
          title: new Text("Package info")
        )
      );
      widget.locationData["packages"].forEach((String packageID){
        Map<String, dynamic> package = firebase.getObject("packages", packageID);
        Map<String, dynamic> panel = firebase.getObject("panels", package["panel"]);
        Map<String, dynamic> pump = firebase.getObject("pumps", package["pump"]);
        Map<String, dynamic> jockeyPanel = firebase.getObject("jockeypanels", package["jockeypanel"]);
        Map<String, dynamic> jockeyPump = firebase.getObject("jockeypumps", package["jockeypump"]);
        // i.e. "Tornatech Diesel"
        String title = "${panel != null ? panel['manufacturer'] : ''} ${package['power']}";
        List<Widget> packageLines = <Widget>[];
        if (panel != null){
          packageLines.add(
            new ListTile(
              title: new Text("Panel info"),
              onTap: (){
                showCategoryCard(context, "panels", package["panel"], data: panel);
              }
            )
          );
        }
        if (pump != null){
          packageLines.add(
            new ListTile(
              title: new Text("Pump info"),
              onTap: (){
                showCategoryCard(context, "pumps", package["pump"], data: pump);
              }
            )
          );
        }
        cardLines.add(new ExpansionTile(
          title: new Text(title),
          children: packageLines,
        ));
        if (jockeyPanel != null){
          List<Widget> jockeyLines = <Widget>[
            new ListTile(
              title: new Text("Jockey panel info"),
              onTap: (){
                showCategoryCard(context, "jockeypanels", package["jockeypanel"], data: jockeyPanel);
              }
            )
          ];
          if (jockeyPump != null){
            jockeyLines.add(
              new ListTile(
                title: new Text("Jockey pump info"),
                onTap: (){
                  showCategoryCard(context, "jockeypumps", package["jockeypump"], data: jockeyPump);
                }
              )
            );
          }
          cardLines.add(new ExpansionTile(
            title: new Text("${jockeyPanel["manufacturer"]}"),
            children: jockeyLines
          ));
        }
      });
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
          children: new List<Widget>.from(cardLines),
        ),
      ),
    );
  }
}