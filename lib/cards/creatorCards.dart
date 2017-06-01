import 'package:flutter/material.dart';
import 'dart:async';
import 'creator/job.dart';
import 'creator/contact.dart';
import 'creator/location.dart';

void showCreatorCard(BuildContext context, String category, {Map<String, dynamic> data: null, String objID: null}){
  switch (category){
    case "jobs":
      showDialog(
        context: context,
        child: new JobCreatorCard(jobData: data, jobID: objID),
      );
      break;
    case "contacts":
      showDialog(
        context: context,
        child: new ContactCreatorCard(contactData: data, contactID: objID),
      );
      break;
    case "locations":
      showDialog(
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

Future<String> awaitNewPackage(BuildContext context) async {
  return "TODO: Need to write a PackageCreator!";
  /*return await showDialog(
    context: context,
    child: new PackageCreatorCard()
  ); */
}