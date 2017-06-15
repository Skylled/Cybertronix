import 'package:flutter/material.dart';

class PackageInfoCard extends StatelessWidget{
  final Map<String, dynamic> packageData;

  PackageInfoCard(this.packageData);

  Map<String, String> prettify = <String, String>{
    "manufacturer": "Manufacturer",
    "model": "Model #",
    "serial": "Serial #",
    "chargervolts": "AC Voltage",
    "enginevolts": "DC Voltage",
    "start": "Start Pressure",
    "stop": "Stop Pressure",
    "enclosure": "Enclosure Rating",
    "hp": "HP",
    "starting": "Starting Type",
    "volts": "AC Volts",
    "phase": "Phase",
    "rpm": "RPM",
    "ground": "Ground",
    "shutoff": "Shutoff", // TODO: here and down
    "rated": "Rated",
    "over": "Over",
  };

  Widget packageTile(Map<String, dynamic> object, String key){
    return new ListTile(
      title: new Text(object[key].toString()),
      subtitle: new Text(prettify[key]),
    );
  }

  List<Widget> panelSubList(Map<String, dynamic> panel, String power){
    List<String> keyList;
    if (power == "diesel"){
      keyList = <String>["manufacturer", "power", "model", "serial", "chargervolts", "enginevolts", "start", "stop", "enclosure"];
    } else {
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "volts", "phase", "starting", "start", "stop", "enclosure"];
    }
    return keyList.map((String key){
      if (key == "power"){
        return new ListTile(
          title: new Text(power),
          subtitle: new Text("Power")
        );
      }
      return packageTile(panel, key);
    }).toList();
  }

  List<Widget> tswitchSubList(Map<String, dynamic> tswitch){
    return <String>["manufacturer", "model", "serial"].map((String key){
      return packageTile(tswitch, key);
    }).toList();
  }

  List<Widget> pumpSubList(Map<String, dynamic> pump){
    return <String>["manufacturer", "model", "serial", "rpm", "shutoff", "rated", "over"].map((String key){
      return packageTile(pump, key);
    }).toList();
  }

  List<Widget> motorSubList(Map<String, dynamic> motor, String power){
    List<String> keyList;
    if (power == "diesel"){
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "rpm", "volts", "ground"];
    } else {
      keyList = <String>["manufacturer", "power", "model", "serial", "hp", "rpm", "volts", "amps", "phase"];
    }
    return keyList.map((String key){
      if (key == "power"){
        return new ListTile(
          title: new Text(power),
          subtitle: new Text("Power")
        );
      }
      return packageTile(motor, key);
    }).toList();
  }

  List<Widget> jpanelSubList(Map<String, dynamic> jpanel){
    return <String>["manufacturer", "model", "serial", "hp", "start", "stop", "enclosure"].map((String key){
      return packageTile(jpanel, key);
    }).toList();
  }

  List<Widget> jpumpSubList(Map<String, dynamic> jpump){
    return <String>["manufacturer", "model", "serial", "hp", "volts", "phase"].map((String key){
      return packageTile(jpump, key);
    }).toList();
  }

  List<Widget> getLines(){
    List<Widget> lines = <Widget>[];
    if (packageData["panel"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Panel"),
        children: panelSubList(packageData["panel"], packageData["power"]),
      ));
    }
    if (packageData["tswitch"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Transfer Switch"),
        children: tswitchSubList(packageData["tswitch"]),
      ));
    }
    if (packageData["pump"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Pump"),
        children: pumpSubList(packageData["pump"]),
      ));
    }
    if (packageData["motor"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Motor"),
        children: motorSubList(packageData["motor"], packageData["power"]),
      ));
    }
    if (packageData["jockeypanel"] != null){
      List<Widget> jockeyWidgets = <Widget>[];
      jockeyWidgets.addAll(jpanelSubList(packageData["jockeypanel"]));
      if (packageData["jockeypump"] != null){
        jockeyWidgets.addAll(jpumpSubList(packageData["jockeyPump"]));
      }
      lines.add(new ExpansionTile(
        title: new Text("Jockey"),
        children: jockeyWidgets,
      ));
    }
    return lines;
  }

  @override
  Widget build(BuildContext build){
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 28.0, 8.0, 12.0),
      child: new Card(
        child: new ListView(
          children: getLines(),
        ),
      ),
    );
  }
}