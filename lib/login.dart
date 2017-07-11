import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase.dart' as firebase;

/// This page is for logging in via Google,
/// to enable cool features like push notifs,
/// and database writing.

// TODO: I need to make this process painless.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<Null> signIn() async {
    GoogleSignInAccount googleUser = await firebase.googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      firebase.user = await firebase.auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );
      firebase.loggedIn = true;
      Navigator.popAndPushNamed(context, '/');
    } else {
      print("Silent auth failed");
    }
  }

  Future<Null> silent() async {
    GoogleSignInAccount googleUser = await firebase.googleSignIn.signInSilently();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      firebase.user = await firebase.auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );
      firebase.loggedIn = true;
      Navigator.popAndPushNamed(context, '/');
    }
  }

  @override
  void initState(){
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: new Text("Login")),
      body: new Center(
        child: new InkWell(
          child: new Image.asset("assets/google_sign_in.png"),
          onTap: (){
            signIn();
          },
        )
      ),
    );
  }
}