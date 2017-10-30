import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as provider;

/*
Some notes on cloud messaging.
I need to write a Firebase Cloud Function that
when a job is created/edited with a listed User,
pull the user's UID and send a Message to the
topic: $uid

Doing it client-side is potentially unreliable

Another challenge: Routing. How do you set it from the push?
Click the push, open direct to the job
*/

/// The firebase auth instance
final FirebaseAuth auth = FirebaseAuth.instance;
/// The google sign in plugin instance
final GoogleSignIn googleSignIn = new GoogleSignIn();

final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

Future<String> uploadPhoto(File imageFile) async {
  // Future: Make a thumbnail and a full-scale, upload both
  // Needs a paid plan, due to file sizes.
  String uid = (await auth.currentUser()).uid;
  String fileName = path.basename(imageFile.path);
  String filePath = "images/$uid/$fileName";
  StorageReference ref = FirebaseStorage.instance.ref().child(filePath);
  image_lib.Image original = image_lib.decodeImage(imageFile.readAsBytesSync());
  image_lib.Image rescale = image_lib.copyResize(original, 750);
  String temp = (await provider.getTemporaryDirectory()).path;
  File finalFile = await new File("$temp/$fileName").create(recursive: true);
  finalFile.writeAsBytesSync(image_lib.encodeJpg(rescale));
  Uri downloadUrl = (await ref.put(finalFile).future).downloadUrl;
  return downloadUrl.toString();
}

// This is mostly borrowed from flutter's FriendlyChat example
Future<bool> ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  if (user == null) {
    print('Silent login failed');
    user = await googleSignIn.signIn();
  } else {
    print('Silent login succeeded');
  }
  if (user == null) {
    print('User declined to log in.');
    return false;
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
  FirebaseUser fUser = await auth.currentUser();
  if (fUser == null) {
    print("fUser is null");
    return false;
  } else {
    firebaseMessaging.subscribeToTopic(fUser.uid);
    return true;
  }
}