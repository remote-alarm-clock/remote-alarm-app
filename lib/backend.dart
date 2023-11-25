import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:remote_alarm/main.dart';
import 'package:remote_alarm/memory.dart';

/// Check if the given clock id exists. True if the ID could be validated.
Future<bool> dbValidateID(clockID) async {
  final clock = await FirebaseDatabase.instance
      .ref("clocks/$clockID")
      .limitToFirst(1)
      .get();
  return clock.exists;
}

void dbSendMessage(
    DeviceProperties device, String message, bool alarmActive) async {
  final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
  // Check if username has been set
  if (Memory.instance.getUsername() == null) {
    scaffold.showSnackBar(const SnackBar(
        content: Text(
            "Es wurde kein Benutzername gesetzt. Bitte wähle als erstes einen Namen.")));
    return;
  }
  /* Maybe move this check somewhere else? 
 if (device.id == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Es wurde keine Clock_ID gesetzt. Bitte wähle eine aus.")));
    return;
  }*/

  // Do not get any data, only call to check if the db exists.
  DatabaseReference clockRef =
      FirebaseDatabase.instance.ref("clocks/${device.id}");
  if (!(await dbValidateID(device.id))) {
    // Stressy..
    scaffold.showSnackBar(SnackBar(
        content: Text(
            "Es existiert kein Gerät mit der ID '${device.id}'! Bitte ID ändern.")));
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
    scaffold.showSnackBar(const SnackBar(
        content: Text(
            "Es wurden noch keine Nachrichten versendet. Lege neuen Datenbankeintrag an.")));
  }

  // Push new Message to Stack
  await messagesRef.update({
    "$newMessageID/sender_name": Memory.instance.getUsername()!,
    "$newMessageID/text": message,
    "$newMessageID/bell": (alarmActive ? 1 : 0),
    "$newMessageID/timestamp":
        (DateTime.now().millisecondsSinceEpoch / 1000.0).round(),
    "latest_message_id": newMessageID
  });
  scaffold.showSnackBar(const SnackBar(content: Text("Nachricht ist raus!")));
}
