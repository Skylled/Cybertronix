import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../firebase.dart';
import 'creatorCards.dart';

class JobCard extends StatefulWidget {
  final String jobID;
  final Map<String, dynamic> jobData;

  JobCard(this.jobID, this.jobData);
  
  
  @override
  JobCardState createState() => new JobCardState(jobID, jobData);
}

class JobCardState extends State<JobCard> {
  // TODO: Change to widget.jobID and widget.jobData
  final String jobID;
  final Map<String, dynamic> jobData;
  JobCardState(this.jobID, this.jobData);

  List<Widget> cardLines = <Widget>[];

  void goEdit(BuildContext context){
    showDialog(
      context: context,
      child: new CreatorCard("jobs", data: jobData),
    );
  }

  void populateLines (){
    DateFormat formatter = new DateFormat("h:mm a, EEEE, MMMM d");
    String address = '${jobData["locationData"]["address"]}, ${jobData["locationData"]["city"]}, ${jobData["locationData"]["state"]}';
    cardLines.add(
      new Container(
        height: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: new Image(
                image: new AssetImage('assets/placeholder.jpg')
              )
            ),
            new Positioned(
              bottom: 16.0,
              child: new Text(
                jobData["name"],
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                ))
            )
          ]
        )
      )
    );
    print('jobData["datetime"]: ${jobData["datetime"]}');
    print('parsed: ${DateTime.parse(jobData["datetime"])}');
    cardLines.add(
      new ListTile(
        leading: new Icon(Icons.access_time),
        title: new Text(formatter.format(DateTime.parse(jobData["datetime"])))
      )
    );
    cardLines.add(
      new ListTile(
        title: new Text(address),
        trailing: new IconButton(
          icon: new Icon(Icons.navigation),
          onPressed: () {
            url_launcher.launch('google.navigation:q=$address');
          }
        ),
        onTap: (){
          // TODO: Popup a Location preview
        }
      )
    );
    cardLines.add(new Divider());
    jobData["contacts"].forEach((String contactId) {
      Map<String, dynamic> contactData;
      getObject("contacts", contactId).then((Map<String, dynamic> con) async {
        contactData = con;
        setState((){
          // Insert because Async.
          cardLines.insert((cardLines.length - 1), new ListTile(
            title: new Text(contactData["name"]),
            trailing: new IconButton(
              icon: new Icon(Icons.phone),
              onPressed: (){
                url_launcher.launch('tel:${contactData["phone"]}');
              }
            ),
            onTap: () {} // TODO: Launch a contact details card.
          ));
        });
      });
    });
    cardLines.add(new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: new Text('Edit info'),
            onPressed: () {
              goEdit(context);
            }
          ),
          new FlatButton(
            child: new Text('Reports'),
            onPressed: () {}
          ),
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