import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

Map<String, DatabaseReference> _refs;

void initDatabase(){
  _refs = new Map<String, DatabaseReference>();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(50000000);

  <String>["annuals", "contacts", "customers", "jobs", "locations", "monthlies"].forEach((String category){
    _refs[category] = FirebaseDatabase.instance.reference().child(category);
    _refs[category].keepSynced(true);
  });
}
//Map<String, Map<String, dynamic>>
Future<Map<String, Map<String, dynamic>>> getCategory(String category, {String sortBy: "name"}) async {
  DatabaseReference ref = _refs[category];
  DataSnapshot snap = await ref.orderByChild(sortBy).once();
  return snap.value;
}

Future<Map<String, dynamic>> getObject(String category, String id) async {
  DataSnapshot snap = await _refs[category].child(id).once();
  return snap.value;
}

void sendObject(String category, Map<String, dynamic> data, {String objID: null}) {
  DatabaseReference ref = _refs[category];
  if (objID != null) {
    ref.child(objID).set(data);
  } else {
    ref.push().set(data);
  }
}

Future<Map<String, Map<String, dynamic>>> findJobs(String field, String searchterm) async {
  DatabaseReference ref = _refs["jobs"];
  DataSnapshot snap = await ref.orderByChild(field).equalTo(searchterm).once();
  return snap.value;
}

Future<Map<String, Map<String, Map<String, dynamic>>>> getAgendaData() async {
  // Map<DateString, Map<JobId, Map<Key, Value>>>
  Map<String, Map<String, Map<String, dynamic>>> agendaData = new Map<String, dynamic>();
  DateTime today = new DateTime.now();
  // 15 because any full 8601 string would be alphabetized after the stripped counterpart.
  DateTime twoweeks = new DateTime(today.year, today.month, today.day + 15);
  for (int i = 0; i < 14; i++) {
    DateTime newDate = new DateTime(today.year, today.month, today.day + i);
    agendaData[newDate.toIso8601String().substring(0, 10)] = new Map<String, dynamic>();
  }
  DatabaseReference ref = _refs["jobs"];
  DataSnapshot snap = await ref.orderByChild("datetime").startAt(today.toIso8601String().substring(0,10)).endAt(twoweeks.toIso8601String().substring(0, 10)).once();
  if (snap.value != null) {
    snap.value.forEach((String id, Map<String, dynamic> job) {
      String jobDate = job["datetime"].substring(0, 10);
      agendaData[jobDate][id] = job;
    });
  }
  return agendaData;
}