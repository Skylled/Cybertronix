import 'package:flutter/material.dart';
import 'document/job.dart';
import 'document/contact.dart';
import 'document/location.dart';

// Future: Customer

Widget getDocumentCard(String collection, String objID, {Map<String, dynamic> data}){
  switch(collection) {
    case 'jobs':
      return new JobInfoCard(objID, jobData: data);
    case "contacts":
      return new ContactInfoCard(objID, contactData: data);
    case "locations":
      return new LocationInfoCard(objID, locationData: data);
    default:
      return null;
  }
}