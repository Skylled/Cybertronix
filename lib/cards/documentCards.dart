import 'package:flutter/material.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import 'document/job.dart';
import 'document/contact.dart';
import 'document/location.dart';

// Future: Customer

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