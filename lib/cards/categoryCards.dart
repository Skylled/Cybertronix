import 'package:flutter/material.dart';
import 'category/job.dart';
import 'category/contact.dart';
import 'category/location.dart';

// Future: Customer

Widget getCategoryCard(String category, String objID, {Map<String, dynamic> data}){
  switch(category) {
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