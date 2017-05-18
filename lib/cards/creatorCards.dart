import 'package:flutter/material.dart';
import 'creator/job.dart';

void showCreatorCard(BuildContext context, String category, {Map<String, dynamic> data: null, String objID: null}){
  switch (category){
    case "jobs":
      showDialog(
        context: context,
        child: new JobCreatorCard(jobData: data, jobID: objID),
      );
      break;
    /*
    case "contacts":
      showDialog(
        context: context,
        child: new ContactCreatorCard(data: data, objID: objID),
      );
      break;
    */
    /*
    case "locations":
      showDialog(
        context: context,
        child: new LocationCreatorCard(data: data, objID: objID),
      );
      break;
    */
    default:
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("This category is not available yet.")
      ));
  }
}