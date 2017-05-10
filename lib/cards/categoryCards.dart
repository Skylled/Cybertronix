import 'package:flutter/material.dart';
import 'job.dart';

void showCategoryCard(BuildContext context, String category, String id, {Map<String,dynamic> data: null}){
  switch (category){
    case 'jobs':
      showDialog(
        context: context,
        child: new JobCard(id, data)
      );
  }
}