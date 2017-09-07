import 'package:flutter/material.dart';
import 'creator/job.dart';
import 'creator/contact.dart';
import 'creator/location.dart';
import 'creator/customer.dart';
import 'creator/package/panel.dart';
import 'creator/package/pump.dart';
import 'creator/package/motor.dart';
import 'creator/package/jockey.dart';

Widget getCreatorCard(String category, Function(Map<String, dynamic>) changeData, {String objID, Map<String, dynamic> data}){
  switch (category){
    case "jobs":
      return new JobCreatorCard(changeData, jobData: data, jobID: objID);
    case "contacts":
      return new ContactCreatorCard(changeData, contactData: data, contactID: objID);
    case "locations":
      return new LocationCreatorCard(changeData, locationData: data, locationID: objID);
    case "customers":
      return new CustomerCreatorCard();
    default:
      return null;
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