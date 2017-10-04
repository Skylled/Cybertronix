import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
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
    initDatabase();
    firebaseMessaging.subscribeToTopic(fUser.uid);
    return true;
  }
}

Map<String, DatabaseReference> _refs;

bool initialized = false;

/// Initializes the database with a maximum 50MB cache, and
/// tells the underlying implementation to cache all categories.
void initDatabase(){
  if (!initialized){
    firebaseMessaging.requestNotificationPermissions();

    _refs = new Map<String, DatabaseReference>();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(50000000);

    <String>["annuals", "contacts", "customers",
            "jobs", "locations", "monthlies", "users"].forEach((String category){
      _refs[category] = FirebaseDatabase.instance.reference().child(category);
      _refs[category].keepSynced(true);
    });

    initialized = true;
  }
}

/// Retrieves all the objects from a given [category],
/// sorted by `name`, unless set otherwise by [sortBy].
Future<Map<String, Map<String, dynamic>>> getCategory(String category, {String sortBy: "name"}) async {
  DatabaseReference ref = _refs[category];
  DataSnapshot snap = await ref.orderByChild(sortBy).once();
  return snap.value;
}

/// Retrieve a specific object from a [category] by its [id].
Future<Map<String, dynamic>> getObject(String category, String id) async {
  DataSnapshot snap = await _refs[category].child(id).once();
  return snap.value;
}

Map<String, dynamic> _scrub(Map<String, dynamic> data) {
  Map<String, dynamic> newData = new Map<String, dynamic>.from(data);
  newData.forEach((String key, dynamic value){
    if (value is Map) {
      value = _scrub(value); // Recursion!
    } else if (value is String) {
      if (value.length <= 0) {
        value = null;
      }
    }
  });
  return newData;
}

/// Writes a new object to a [category] or changes the object at [objID]
/// to brand new data.
void sendObject(String category, Map<String, dynamic> data, {String objID}) {
  DatabaseReference ref = _refs[category];
  if (objID != null) {
    ref.child(objID).set(_scrub(data));
  } else {
    DatabaseReference tempRef = ref.push();
    data["id"] = tempRef.key;
    tempRef.set(_scrub(data));
  }
}

/// Finds all jobs whose [field] matches the [searchterm].
Future<Map<String, Map<String, dynamic>>> findJobs(String field, String searchterm) async {
  print("searchterm: ${searchterm.runtimeType} $searchterm");
  DatabaseReference ref = _refs["jobs"];
  DataSnapshot snap = await ref.orderByChild(field).equalTo(searchterm).once();
  return snap.value;
}

/// Retrieves the next two weeks of jobs and sorts by datetime.
/// 
/// Format: Map<DateString, Map<JobId, Map<Key, Value>>>
Future<Map<String, Map<String, Map<String, dynamic>>>> getAgendaData() async {
  Map<String, Map<String, Map<String, dynamic>>> agendaData = new Map<String, dynamic>();
  DateTime today = new DateTime.now();
  // 15 because any full 8601 string would be alphabetized after the stripped counterpart.
  DateTime twoweeks = new DateTime(today.year, today.month, today.day + 15);
  for (int i = 0; i < 14; i++) {
    DateTime newDate = new DateTime(today.year, today.month, today.day + i);
    agendaData[newDate.toIso8601String().substring(0, 10)] = new Map<String, dynamic>();
  }
  DatabaseReference ref = _refs["jobs"];
  DataSnapshot snap = await ref.orderByChild("datetime")
                               .startAt(today.toIso8601String().substring(0,10))
                               .endAt(twoweeks.toIso8601String().substring(0, 10))
                               .once();
  if (snap.value != null) {
    snap.value.forEach((String id, Map<String, dynamic> job) {
      String jobDate = job["datetime"].substring(0, 10);
      agendaData[jobDate][id] = job;
    });
  }
  return agendaData;
}

Future<List<Map<String, dynamic>>> getTodayData() async {
  List<Map<String, dynamic>> todaysJobs = new List<Map<String, Map<String, dynamic>>>();
  DatabaseReference ref = _refs["jobs"];
  DateTime today = new DateTime.now();
  DateTime midnight = new DateTime(today.year, today.month, today.day);
  DateTime endOfDay = new DateTime(today.year, today.month, today.day, 23, 59);
  DataSnapshot snap = await ref.orderByChild("datetime")
                               .startAt(midnight.toIso8601String())
                               .endAt(endOfDay.toIso8601String())
                               .once();
  if (snap.value != null) {
    snap.value.forEach((String id, Map<String, dynamic> job){
      todaysJobs.add(job);
    });
  }
  return todaysJobs;
}