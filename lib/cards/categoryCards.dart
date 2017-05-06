import 'package:flutter/material.dart';
import 'job.dart';

showCategoryCard(BuildContext context, String category, String id, {Map data: null}){
  switch (category){
    case 'jobs':
      showDialog(
        context: context,
        child: new JobCard(id, data)
      );
  }
}