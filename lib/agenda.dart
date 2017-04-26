import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'cards/job.dart';
import 'drawer.dart';
import 'firebase.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage();

  @override
  AgendaPageState createState() => new AgendaPageState();
}

class AgendaPageState extends State<AgendaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> agenda;

  Widget buildAppBar(){
    return new AppBar(
      title: new Text('Your Agenda'),
    );
  }
  
  Widget buildFloatingActionButton() {
    return new FloatingActionButton(
      tooltip: 'Add todo job',
      child: new Icon(Icons.add),
      onPressed: null
    );
  }

  void popupJobCard(BuildContext context, String jobId, Map<String, dynamic> jobData){
    showDialog(
      context: context,
      child: buildJobCard(jobId, jobData)
    );
  }

  Future<Map<String, Map<String, Map<String, dynamic>>>> getAgendaData() async {
    print("getAgendaData()");
    // Map<DateString, Map<JobId, Map<Key, Value>>>
    Map<String, Map<String, Map<String, dynamic>>> agendaData = new Map();
    DateTime today = new DateTime.now();
    DateTime twoweeks;
    for (int i = 0; i < 14; i++) {
      DateTime newDate = new DateTime(today.year, today.month, today.day + i);
      agendaData[newDate.toIso8601String().substring(0, 10)] = new Map();
      twoweeks = newDate; // Last iteration is what matters.
    }
    Map<String, Map<String, dynamic>> resData;
    // TODO Multi-line string!
    print('Getting jobs.');
    http.Response response = await http.get('https://cybertronix-b188e.firebaseio.com/jobs.json?orderBy="datetime"&startAt="${today.toIso8601String().substring(0,10)}"&endAt="${twoweeks.toIso8601String().substring(0, 10)}"');
    print('Got jobs: ${response.body}');
    resData = JSON.decode(response.body);
    resData.forEach((id, job) {
      String jDate = job["datetime"].substring(0, 10);
      agendaData[jDate][id] = job;
    });
    return agendaData;
  }

  void buildAgenda() {
    print("buildAgenda()");
    agenda = [];
    agenda.add(new ListTile(
      title: new Text("Your Agenda")
    ));
    Future<Map<String, Map<String, Map<String, dynamic>>>> agendaData = getAgendaData();
    agendaData.then((value) {
      print("agendaData.then()");
      value.forEach((day, jobs) {
        print("value.forEach()");
        DateTime date = DateTime.parse(day);
        DateFormat formatter = new DateFormat('EEEE, MMMM d');
        String txt = formatter.format(date);
        setState((){
          print('setState() 1');
          agenda.add(new ListTile(
            title: new Text(txt),
            onTap: (){
              print('date onTap()');
            }
          ));
        });
        if (jobs.length == 0) {
          print("No jobs.");
          setState((){
            print('setState() 0');
            agenda.add(new ListTile(
              title: new Text('No jobs scheduled.'),
              onTap: (){
                print('No jobs onTap()');
              }
              //dense: true // TODO: Verify this
            ));
          });
        } else {
          jobs.forEach((id, job) {
            print("jobs.forEach()");
            DateTime jdt = DateTime.parse(job["datetime"]);
            DateFormat hour = new DateFormat.j();
            DateFormat time = new DateFormat.jm();
            getLocation(job['location']).then((location) {
              print("getLocation.then()");
              setState((){
                print("setState() 2");
                agenda.add(new ListTile(
                  // TODO: Consider that ISO is 24 hour clock.
                  leading: new CircleAvatar(child: new Text(hour.format(jdt))),
                  title: new Text('${time.format(jdt)}, ${job["description"]}'),
                  subtitle: new Text('${location["name"]}\n${location["city"]}, ${location["state"]}'),
                  isThreeLine: true,
                  onTap: () {
                    print('job onTap');
                    //popupJobCard(context, id, job);
                  }
                ));
              });
            });
          });
        }
      });
    }); 
  }

  @override
  void initState(){
    super.initState();
    buildAgenda();
    print("initState() finished");
  }

  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    print("build() $builds");
    print("agenda.length: ${agenda.length}");
    if (agenda.length > 0) {
      print('${agenda[0].runtimeType}');
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingActionButton(),
      drawer: buildDrawer(context, 'agenda'),
      body: new Center(
        child: new ListView(
          children: agenda
        ),
      ),
    );
  }
}