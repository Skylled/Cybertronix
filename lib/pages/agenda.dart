import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import 'data.dart';

/// A two week summary page of upcoming jobs
/// 
/// Something of a to-do list, organized by date and time.
class AgendaPage extends StatefulWidget {
  @override
  _NAgendaPageState createState() => new _NAgendaPageState();
}

class _NAgendaPageState extends State<AgendaPage> {
  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);
    DateTime twoweeks = new DateTime(now.year, now.month, now.day + 14);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Your Agenda'),
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add todo job',
        child: new Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).pushNamed('/create/jobs');
        },
      ),
      drawer: buildDrawer(context, 'agenda'),
      body: new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("jobs")
                                  .where("datetime", isGreaterThanOrEqualTo: today, isLessThan: twoweeks)
                                  .orderBy("datetime").snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (!snapshot.hasData) return new Text("Loading...");
          Map<String, List<Widget>> agendaData = new Map<String, dynamic>();
          for (int i = 0; i < 14; i++){
            DateTime newDate = new DateTime(today.year, today.month, today.day + i);
            agendaData[newDate.toIso8601String().substring(0, 10)] = new List<Widget>();
          }
          DateFormat formatter = new DateFormat('EEEE, MMMM d');
          DateFormat time = new DateFormat.jm();
          snapshot.data.documents.forEach((DocumentSnapshot document){
            DateTime dt = document["datetime"];
            agendaData[dt.toIso8601String().substring(0, 10)].add(
              new ListTile(
                title: new Text("${time.format(dt)}, ${document["name"]}"),
                onTap: () async {
                  await Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) => new DataPage('jobs', document.reference),
                    ),
                  );
                },
              ),
            );
            /// Plan B
            /// 
            /// 15 streams and builders for each day.
            /// Agenda is a list of StreamBuilders

            /// Create a map of dates to list<widget>
            /// 
            /// iterate list of documents, creating widgets,
            /// putting them into appropriate list at index of map
            /// 
            /// Create list of ExpansionTiles.
          });
          List<Widget> agendaTiles = <Widget>[];
          agendaData.forEach((String datestring, List<Widget> sublist){
            agendaTiles.add(
              new ExpansionTile(
                title: new Text(formatter.format(DateTime.parse(datestring))),
                leading: new CircleAvatar(
                  child: new Text(sublist.length.toString()),
                ),
                children: sublist.isNotEmpty ? sublist :
                  <Widget>[new ListTile(title: new Text("No jobs scheduled."),)],
              ),
            );
          });
          return new ListView(
            children: agendaTiles,
          );
        },
      ),
    );
  }
}