import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  Future<Map<String, Map<String, Map<String, dynamic>>>> agendaData = getAgendaData();

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
      child: new JobCard(jobId, jobData)
    );
  }

  void buildAgenda() {
    print("buildAgenda()");
    agenda = [];
    agendaData.then((value) {
      print("agendaData.then()");
      value.forEach((day, jobs) {
        print("value.forEach()");
        DateTime date = DateTime.parse(day);
        DateFormat formatter = new DateFormat('EEEE, MMMM d');
        String txt = formatter.format(date);
        List subJobs = [];
        if (jobs.length == 0) {
          print("No jobs.");
          setState((){
            print('setState() 0');
            subJobs.add(new TwoLevelListItem(
              title: new Text("No jobs scheduled.")
            ));
          });
        } else {
          jobs.forEach((id, job) {
            print("jobs.forEach()");
            DateTime jdt = DateTime.parse(job["datetime"]);
            DateFormat time = new DateFormat.jm();
            setState((){
              print("setState() 2");
              subJobs.add(new TwoLevelListItem(
                title: new Text('${time.format(jdt)}, ${job["description"]}'),
                onTap: () {
                  popupJobCard(context, id, job);
                }
              ));
            });
          });
        }
        setState((){
          print('setState() 1');
          agenda.add(new TwoLevelSublist(
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
        child: new TwoLevelList(
          type: MaterialListType.oneLineWithAvatar,
          children: new List.from(agenda)
        ),
      ),
    );
  }
}