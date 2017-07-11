import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'cards/categoryCards.dart';
import 'drawer.dart';
import 'login.dart';
import 'firebase.dart' as firebase;

/// A two week summary page of upcoming jobs
/// 
/// Something of a to-do list, organized by date and time.
/// See [getAgendaData] for the data format it uses.
class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => new _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> agenda;
  Future<Map<String, Map<String, Map<String, dynamic>>>> agendaData = firebase.getAgendaData();

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

  void buildAgenda() {
    agenda = <Widget>[];
    agendaData.then((Map<String, Map<String, Map<String, dynamic>>> value) {
      value.forEach((String day, Map<String, Map<String, dynamic>> jobs) {
        DateTime date = DateTime.parse(day);
        DateFormat formatter = new DateFormat('EEEE, MMMM d');
        String txt = formatter.format(date);
        List<Widget> subJobs = <Widget>[];
        if (jobs.length == 0) {
          setState((){
            subJobs.add(new ListTile(
              title: new Text("No jobs scheduled.")
            ));
          });
        } else {
          jobs.forEach((String id, Map<String, dynamic> job) {
            DateTime jdt = DateTime.parse(job["datetime"]);
            DateFormat time = new DateFormat.jm();
            setState((){
              subJobs.add(new ListTile(
                title: new Text('${time.format(jdt)}, ${job["name"]}'),
                onTap: () {
                  showCategoryCard(context, "jobs", id, data: job);
                }
              ));
            });
          });
        }
        setState((){
          agenda.add(new ExpansionTile(
            title: new Text(txt),
            leading: new CircleAvatar(child: new Text(jobs.length.toString())),
            children: subJobs
          ));
        });
      });
    }); 
  }

  @override
  void initState(){
    super.initState();
    buildAgenda();
  }

  @override
  Widget build(BuildContext context) {
    if (firebase.loggedIn) {
      return new Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(),
        floatingActionButton: buildFloatingActionButton(),
        drawer: buildDrawer(context, 'agenda'),
        body: new Center(
          child: new ListView(
            children: new List<Widget>.from(agenda)
          ),
        ),
      );
    } else {
      return new LoginPage();
    }
  }
}