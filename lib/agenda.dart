import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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

  Map<String, Map<String, Map<String, dynamic>>> getAgendaData(){
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
    http.get('https://cybertronix-b188e.firebaseio.com/jobs.json?orderBy="datetime"&startAt="${today.toIso8601String().substring(0,10)}"&endAt="${twoweeks.toIso8601String().substring(0, 10)}"')
      .then((response) {
        resData = JSON.decode(response.body);
      });
    resData.forEach((id, job) {
      String jDate = job["datetime"].substring(0, 10);
      agendaData[jDate][id] = job;
    });
    return agendaData;
  }

  void buildAgenda() {
    /*http.get('http://cybertronix.us/api/agenda')
        .then((response){
          agendaData = JSON.decode(response.body);
    });*/
    Map<String, Map<String, Map<String, dynamic>>> agendaData = getAgendaData();
    agenda = [];
    agendaData.forEach((day, jobs) {
      DateTime date = DateTime.parse(day);
      DateFormat formatter = new DateFormat('EEEE, MMMM d');
      String txt = formatter.format(date);
      agenda.add(new ListTile(
        title: new Text(txt)
      ));
      if (jobs.length == 0) {
        agenda.add(new ListTile(
          title: new Text('No jobs scheduled.')
        ));
      } else {
        jobs.forEach((id, job) {
          DateTime jdt = DateTime.parse(job["datetime"]);
          DateFormat hour = new DateFormat.j();
          DateFormat time = new DateFormat.jm();
          Map<String, dynamic> location = getLocation(job['location']);
          agenda.add(new ListTile(
            // TODO: Consider that ISO is 24 hour clock.
            leading: new CircleAvatar(child: new Text(hour.format(jdt))),
            title: new Text('${time.format(jdt)}, ${job["description"]}'),
            subtitle: new Text('${location["name"]}\n${location["city"]}, ${location["state"]}'),
            isThreeLine: true,
            onTap: () {popupJobCard(context, id, job);}
          ));
        });
      }
    }); 
  }

  @override
  void initState(){
    super.initState();
    buildAgenda();
  }

  @override
  Widget build(BuildContext context) {
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