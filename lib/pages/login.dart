import 'package:flutter/material.dart';
import '../firebase.dart' as firebase;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState(){
    super.initState();
    firebase.ensureLoggedIn().then((bool loggedIn){
      if (loggedIn){
        print("Logged in. Pushing...");
        Navigator.of(context).pushReplacementNamed('/agenda');
      } else {
        print("Login failed.");
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Login"),
      ),
      body: new Center(
        child: new RaisedButton(
          child: new Text("Login with Google"),
          onPressed: () async {
            if (await firebase.ensureLoggedIn()){
              print("Logged in. Pushing...");
              Navigator.of(context).pushReplacementNamed('/agenda');
            } else {
              print("Login failed.");
            }
          },
        )
      ),
    );
  }
}