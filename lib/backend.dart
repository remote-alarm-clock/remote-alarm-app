import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Check if the given clock id exists. True if the ID could be validated.
Future<bool> dbValidateID(clockID) async {
  final clock = await FirebaseDatabase.instance.ref("clocks/$clockID").get();
  return clock.exists;
}

void dbSendMessage(context, message, alarmActive) async {
  // Check if username has been set
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString("username") == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Es wurde kein Benutzername gesetzt. Bitte wähle als erstes einen Namen.")));
    return;
  }
  if (prefs.getString("clock_id") == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Es wurde keine Clock_ID gesetzt. Bitte wähle eine aus.")));
    return;
  }

  final username = prefs.getString("username")!;
  final clockID = prefs.getString("clock_id")!;

  // Do not get any data, only call to check if the db exists.
  DatabaseReference clockRef = FirebaseDatabase.instance.ref("clocks/$clockID");
  if (!(await clockRef.limitToFirst(1).get()).exists) {
    // Stressy..
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Es existiert keine Uhr mit der ID '$clockID'! Bitte ID ändern.")));
    return;
  }

  DatabaseReference messagesRef = clockRef.child("messages");
  DatabaseReference lastMsgIDRef = messagesRef.child("latest_message_id");
  // Get newest Message ID
  DataSnapshot latestMessageId = await lastMsgIDRef.get();
  int newMessageID =
      0; // Start with message ID zero, if there have not been any messaged sent yet.

  if (latestMessageId.exists) {
    // Load the latest message ID.
    newMessageID = (int.parse(latestMessageId.value.toString())) + 1;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Es wurden noch keine Nachrichten versendet. Lege neuen Datenbankeintrag an.")));
  }

  // Push new Message to Stack
  await messagesRef.update({
    "$newMessageID/sender_name": username,
    "$newMessageID/text": message,
    "$newMessageID/bell": (alarmActive ? 1 : 0),
    "$newMessageID/timestamp":
        (DateTime.now().millisecondsSinceEpoch / 1000.0).round(),
    "latest_message_id": newMessageID
  });
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Nachricht ist raus!")));
}
