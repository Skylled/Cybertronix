import 'package:flutter/material.dart';
import 'dart:async';
import 'creator/job.dart';
import 'creator/contact.dart';
import 'creator/location.dart';
import 'creator/package.dart';
import 'creator/customer.dart';

/// Opens a [Dialog] [Card] with a creator/editor for the given 
/// [category]. [data] and [objID] are for pre-filling the editor.
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
    case "customers":
      return await showDialog(
        context: context,
        child: new CustomerCreatorCard(),
      );
    default:
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("This category is not available yet.")
      ));
  }
}

/// Opens a [Dialog] [Card] with a Creator/Editor for a package.
/// [packageData] is for prefilling the editor.
Future<Map<String, dynamic>> awaitPackage(BuildContext context, {Map<String, dynamic> packageData: null}) async {
  Map<String, dynamic> newPackageData = <String, dynamic>{};
  if (packageData == null) {
    await showDialog(
      barrierDismissible: false,
      context: context,
      child: new SimpleDialog(
        title: new Text("Electric or Diesel?"),
        children: <Widget>[
          new SimpleDialogOption(
            child: new Text("Electric"),
            onPressed: (){
              newPackageData["power"] = "Electric";
            },
          ),
          new SimpleDialogOption(
            child: new Text("Diesel"),
            onPressed: (){
              newPackageData["power"] = "Diesel";
            },
          )
        ],
      )
    );
  }
  return await showDialog(
    context: context,
    child: new PackageCreatorCard(packageData: packageData != null ? packageData : newPackageData)
  );
}