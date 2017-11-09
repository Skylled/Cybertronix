import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'document/job.dart';
import 'document/contact.dart';
import 'document/location.dart';

// Future: Customer

// TODO: MAJOR: None of the InfoCards should need to be Stateful because the StreamBuilder should rebuild them all!

Widget getDocumentCard(String collection, DocumentSnapshot document){
  switch(collection) {
    case 'jobs':
      return new JobInfoCard(document);
    case "contacts":
      return new ContactInfoCard(document);
    case "locations":
      return new LocationInfoCard(document);
    default:
      return null;
  }
}