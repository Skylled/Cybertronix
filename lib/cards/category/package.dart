import 'package:flutter/material.dart';

TextStyle titleStyle = new TextStyle(
  fontSize: 16.0,
  color: Colors.grey
);

TextStyle dataStyle = new TextStyle(
  fontSize: 24.0,
  color: Colors.black87
);

class DataStack extends StatelessWidget {
  final String title;
  final String data;

  DataStack(String title, dynamic data):
    this.title = title,
    this.data = data.toString();

  @override
  Widget build(BuildContext context){
    return new SizedBox(
      height: 20.0,
      width: 80.0,
      child: new Stack(
        children: <Widget>[
          new Positioned(
            left: 4.0,
            top: 4.0,
            child: new Text(title, style: titleStyle)
          ),
          new Positioned(
            left: 4.0,
            top: 24.0,
            child: new Text(data, style: dataStyle)
          )
        ],
      ),
    );
  }
}

class PanelInfoWidget extends StatelessWidget{
  final Map<String, dynamic> panelData;
  final String power;

  PanelInfoWidget(this.panelData, this.power);

  @override
  Widget build(BuildContext context){
    /* Column[
      Row[Stack.positioned, Stack.positioned],
      Row[Stack.positioned, Stack.positioned]
    ] */
    return new GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: <Widget>[
        new DataStack("Manufacturer", panelData["manufacturer"]),
        new DataStack("Power", power),

        new DataStack("Model #", panelData["model"]),
        new DataStack("Serial #", panelData["serial"]),

        new DataStack("Start pressure", panelData["start"]),
        new DataStack("Stop pressure", panelData["stop"]),

        new DataStack("Charger voltage", panelData["chargervolts"]),
        new DataStack("DC Voltage", panelData["enginevolts"]),

        new DataStack("Enclosure", panelData["enclosure"]),
        new DataStack("Grounding", panelData["ground"])
      ]
    );
  }
}

class PumpInfoWidget extends StatelessWidget{
  final Map<String, dynamic> pumpData;
  
  PumpInfoWidget(this.pumpData);

  @override
  Widget build(BuildContext context){
    return new Container();
  }
}

class MotorInfoWidget extends StatelessWidget{
  final Map<String, dynamic> motorData;
  final String power;

  MotorInfoWidget(this.motorData, this.power);

  @override
  Widget build(BuildContext context){
    return new Container();
  }
}

class JockeyPanelInfoWidget extends StatelessWidget{
  final Map<String, dynamic> panelData;
  
  JockeyPanelInfoWidget(this.panelData);

  @override
  Widget build(BuildContext context){
    return new Container();
  }
}

class JockeyPumpInfoWidget extends StatelessWidget{
  final Map<String, dynamic> pumpData;
  
  JockeyPumpInfoWidget(this.pumpData);

  @override
  Widget build(BuildContext context){
    return new Container();
  }
}

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
  };

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
      return new ListTile(
        title: new Text(panel[key].toString()),
        subtitle: new Text(prettify[key]),
      );
    }).toList();
  }

  List<Widget> tswitchSubList(Map<String, dynamic> tswitch){
    return <String>["manufacturer", "model", "serial"].map((String key){
      return new ListTile(
        title: new Text(tswitch[key].toString()),
        subtitle: new Text(prettify[key]),
      );
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
        children: <Widget>[],
      ));
    }
    if (packageData["pump"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Pump"),
        children: <Widget>[new PumpInfoWidget(packageData["pump"])],
      ));
    }
    if (packageData["motor"] != null){
      lines.add(new ExpansionTile(
        title: new Text("Motor"),
        children: <Widget>[new MotorInfoWidget(packageData["motor"], packageData["power"])],
      ));
    }
    if (packageData["jockeypanel"] != null){
      List<Widget> jockeyWidgets = <Widget>[];
      jockeyWidgets.add(new JockeyPanelInfoWidget(packageData["jockeyPanel"]));
      if (packageData["jockeypump"] != null){
        jockeyWidgets.add(new JockeyPumpInfoWidget(packageData["jockeyPump"]));
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