import 'package:flutter/material.dart';
import 'creator/job.dart';
import 'creator/contact.dart';
import 'creator/location.dart';
import 'creator/customer.dart';
import 'creator/package/panel.dart';
import 'creator/package/pump.dart';
import 'creator/package/motor.dart';
import 'creator/package/jockey.dart';

Widget getCreatorCard(String collection, Function(Map<String, dynamic>) changeData, {Map<String, dynamic> data}){
  switch (collection){
    case "jobs":
      return new JobCreatorCard(changeData, jobData: data);
    case "contacts":
      return new ContactCreatorCard(changeData, contactData: data);
    case "locations":
      return new LocationCreatorCard(changeData, locationData: data);
    case "customers":
      return new CustomerCreatorCard(changeData, customerData: data);
    default:
      return new Card(
        child: new Center(
          child: new Text("Creator for [$collection] not yet implemented"),
        ),
      );
  }
}

Widget getComponentCard(String component, String power, Function(String, Map<String, dynamic>) changeData, {Map<String, dynamic> componentData}){
  switch(component){
    case "panel":
      if (power == "Diesel"){
        return new DieselPanelCreatorCard(componentData, changeData);
      }
      return new ElectricPanelCreatorCard(componentData, changeData);
    case "pump":
      return new PumpCreatorCard(componentData, changeData);
    case "motor":
      if (power == "Diesel"){
        return new DieselMotorCreatorCard(componentData, changeData);
      }
      return new ElectricMotorCreatorCard(componentData, changeData);
    case "jockeypanel":
      return new JockeyPanelCreatorCard(componentData, changeData);
    case "jockeypump":
      return new JockeyPumpCreatorCard(componentData, changeData);
    case "tswitch":
      return new TransferSwitchCreatorCard(componentData, changeData);
    default:
      return null;
  }
}