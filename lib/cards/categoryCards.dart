import 'package:flutter/material.dart';
import 'category/job.dart';
import 'category/contact.dart';
import 'category/location.dart';
import 'category/package.dart';

// Future: Customer

/// This pops up a [Dialog] [Card] with info about a particular object.
void showCategoryCard(BuildContext context, String category, String objID,
    {Map<String, dynamic> data: null}) {
  switch (category) {
    case 'jobs':
      showDialog(
        context: context,
        child: new JobInfoCard(objID, jobData: data),
      );
      break;
    case "contacts":
      showDialog(
        context: context,
        child: new ContactInfoCard(objID, contactData: data),
      );
      break;
    case "locations":
      showDialog(
        context: context,
        child: new LocationInfoCard(objID, locationData: data),
      );
      break;
    default:
      showDialog(
        context: context,
        child: new AlertDialog(
          content: new Text("This category, ($category), is not implemented yet."),
          actions: <Widget>[new RaisedButton(
            child: new Text("Ok"),
            onPressed: (){
              Navigator.pop(context);
            },
          )],
        )
      );
  }
}

/// This displays a [Dialog] [Card] with info loaded from Firebase
void showPackageCard(BuildContext context, Map<String, dynamic> data){
  showDialog(
    context: context,
    child: new PackageInfoCard(data)
  );
}