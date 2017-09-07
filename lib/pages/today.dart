import 'dart:async';
import 'package:flutter/material.dart';
import '../firebase.dart' as firebase;
// ListView of Cards, new JobPreviewCard

class JobPreviewCard extends StatefulWidget {
  final Map<String, dynamic> jobData;

  JobPreviewCard(this.jobData);

  @override
  _JobPreviewCardState createState() => new _JobPreviewCardState();
}

class _JobPreviewCardState extends State<JobPreviewCard> {
  Map<String, dynamic> locationData;

  Future<Map<String, dynamic>> getLocationData() async {
    if (widget.jobData["location"] != null){
      return await firebase.getObject("locations", widget.jobData["location"]);
    } else {
      return null;
    }
  }

  @override
  void initState(){
    super.initState();
    getLocationData().then((Map<String, dynamic> newLoc){
      setState((){
        locationData = newLoc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Card(
        child: new Column(
          children: <Widget>[
            new Container(
              height: 200.0,
              child: new Stack(
                children: <Widget>[
                  new Positioned.fill(
                    child: (){
                      if (widget.jobData["photos"] != null){
                        return new Image.network(widget.jobData["photos"][0], fit: BoxFit.fitWidth);
                      } else if (locationData != null && locationData["photos"] != null){
                        return new Image.network(locationData["photos"][0], fit: BoxFit.fitWidth);
                      }
                    }()
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayPage extends StatefulWidget {
  @override
  _TodayPageState createState() => new _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      
    );
  }
}