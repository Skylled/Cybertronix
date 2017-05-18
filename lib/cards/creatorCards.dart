import 'package:flutter/material.dart';
import 'creator/job.dart';

void showCreatorCard(BuildContext context, String category, {Map<String, dynamic> data: null, String objID: null}){
  switch (category){
    case "jobs":
      showDialog(
        context: context,
        child: new JobCreatorCard(data: data, objID: objID),
      );
  }
}