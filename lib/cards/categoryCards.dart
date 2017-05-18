import 'package:flutter/material.dart';
import 'category/job.dart';
import 'category/contact.dart';

void showCategoryCard(BuildContext context, String category, String objID, {Map<String,dynamic> data: null}){
  switch (category){
    case 'jobs':
      showDialog(
        context: context,
        child: new JobInfoCard(objID, jobData: data)
      );
      break;
    case "contacts":
      showDialog(
        context: context,
        child: new ContactInfoCard(objID, contactData: data),
      );
      break;
    /*
    case "locations":
      showDialog(
        context: context,
        child: new LocationInfoCard(data: data, objID: objID),
      );
      break;
    */
    default:
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("This category is not available yet.")
      ));

  }
}