import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// The firebase auth instance
final FirebaseAuth auth = FirebaseAuth.instance;
/// The google sign in plugin instance
final GoogleSignIn googleSignIn = new GoogleSignIn();

final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

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
  if (auth.currentUser == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
  if (auth.currentUser == null) {
    return false;
  } else {
    firebaseMessaging.subscribeToTopic(auth.currentUser.uid);
    return true;
  }
}

Map<String, DatabaseReference> _refs;

/// Initializes the database with a maximum 50MB cache, and
/// tells the underlying implementation to cache all categories.
void initDatabase(){
  firebaseMessaging.requestNotificationPermissions();

  _refs = new Map<String, DatabaseReference>();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(50000000);

  <String>["annuals", "contacts", "customers", "jobs", "locations", "monthlies"].forEach((String category){
    _refs[category] = FirebaseDatabase.instance.reference().child(category);
    _refs[category].keepSynced(true);
  });
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

Map<String, dynamic> scrub(Map<String, dynamic> data) {
  Map<String, dynamic> newData = new Map<String, dynamic>.from(data);
  newData.forEach((String key, dynamic value){
    if (value is Map) {
      value = scrub(value); // Recursion!
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
// TODO: I don't know if this can delete fields correctly.
void sendObject(String category, Map<String, dynamic> data, {String objID: null}) {
  DatabaseReference ref = _refs[category];
  if (objID != null) {
    ref.child(objID).set(scrub(data));
  } else {
    ref.push().set(scrub(data));
  }
}

/// Finds all jobs whose [field] matches the [searchterm].
Future<Map<String, Map<String, dynamic>>> findJobs(String field, String searchterm) async {
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