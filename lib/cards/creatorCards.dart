import 'package:flutter/material.dart';

Widget customerCard(GlobalKey formKey){
  return new Container(
    padding: const EdgeInsets.all(12.0),
    child: new Card(
      child: new Form(
        key: formKey
      )
    )
  );
}