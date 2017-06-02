import 'package:flutter/material.dart';
import 'dart:async';
import 'creator/job.dart';
import 'creator/contact.dart';
import 'creator/location.dart';

Future<dynamic> showCreatorCard(BuildContext context, String category, {Map<String, dynamic> data: null, String objID: null}) async {
  switch (category){
    case "jobs":
      return await showDialog(
        context: context,
        child: new JobCreatorCard(jobData: data, jobID: objID),
      );
      break;
    case "contacts":
      return await showDialog(
        context: context,
        child: new ContactCreatorCard(contactData: data, contactID: objID),
      );
      break;
    case "locations":
      return await showDialog(
        context: context,
        child: new LocationCreatorCard(locationData: data, locationID: objID),
      );
      break;
    default:
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("This category is not available yet.")
      ));
  }
}

Future<Map<String, dynamic>> awaitPackage(BuildContext context, {Map<String, dynamic> packageData}) async {
  return null;
  /*return await showDialog(
    context: context,
    child: new PackageCreatorCard(packageData: packageData)
  ); */
}