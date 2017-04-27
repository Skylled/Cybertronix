import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../firebase.dart';

class JobCard extends StatefulWidget {
  final String jobID;
  final Map jobData;

  JobCard(this.jobID, this.jobData);
  
  
  @override
  JobCardState createState() => new JobCardState(jobID, jobData);
}

class JobCardState extends State<JobCard> {
  final String jobID;
  final Map<String, dynamic> jobData;
  JobCardState(this.jobID, this.jobData);

  List cardLines = [];

  void populateLines (){
    DateFormat formatter = new DateFormat('jm EEEE, MMMM d');
    String address = '${jobData["locationData"]["address"]}, ${jobData["locationData"]["city"]}, ${jobData["locationData"]["state"]}';
    /*new Image( // TODO: Text over image, maybe from Contacts demo
      image: new AssetImage('assets/face-bradon.jpg')
    ),*/
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
        )
      )
    );
    cardLines.add(new Divider());
    jobData["contacts"].forEach((contactId) {
      Map<String, dynamic> contactData;
      getObject("contacts", contactId).then((con) async {
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
            child: new Text('Reports'),
            onPressed: () {}
          ),
          new FlatButton(
            child: new Text('More info'),
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
          children: new List.from(cardLines)
        )
      )
    );
  }
}