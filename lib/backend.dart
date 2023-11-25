import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

/// Loads a list of clock names from the db. WARNING: This downloads the entire DB. Should be used sparsely to not bill too much! (There is probably a more efficient way => Maybe storing names of clocks in separate DB?)
Future<List<DeviceProperties>> dbGetDevices() async {
  final List<DeviceProperties> devices = List.empty(growable: true);
  final clock = await FirebaseDatabase.instance.ref("clocks").get();
  if (!clock.exists) {
    return devices;
  }

  for (final child in clock.children) {
    String id = child.key!;
    try {
      String receiverName = child.child("clock_user").value!.toString();
      String deviceType = child.child("clock_type").value!.toString();
      DeviceType type = DeviceType.fromString(deviceType);
      String deviceStatusCount = child
          .child("clock_fb")
          .child("latest_clock_status_count")
          .value!
          .toString();
      int deviceStatusCountInt = int.parse(deviceStatusCount);
      DeviceProperties prop = DeviceProperties(
          id, receiverName, type, deviceStatusCountInt, "nicht geladen", "");

      devices.add(prop);
    } on Exception catch (_, e) {
      print(e);
      scaffoldKey.currentState!.showSnackBar(SnackBar(
          content: Text(
              "Es wurde ein Gerät '$id' gefunden, aber der Datenbankeintrag ist kaputt! Wird übersprungen.")));
    }
  }

  return devices;
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

Future<void> dbShowMessageFromClock(
    DatabaseEvent event, DeviceProperties device) async {
  final newStatusCount = int.parse(event.snapshot.value.toString());

  // Do not display notification if message is consistent
  if (newStatusCount == device.lastClockStatusCount) return;

  // Load Message Body
  final msg = await FirebaseDatabase.instance
      .ref("clocks/${device.id}/clock_fb/latest_clock_status")
      .get();
  final utc = await FirebaseDatabase.instance
      .ref("clocks/${device.id}/clock_fb/latest_clock_status_utc")
      .get();

  final msgString = msg.value.toString();
  String timeString = ""; // Will be empty if no date is found.
  if (utc.exists) {
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch((utc.value as int) * 1000);
    final DateFormat formatterDate = DateFormat("dd.MM.yyyy");
    final DateFormat formatterTime = DateFormat("HH:mm");
    final date = formatterDate.format(timestamp);
    final time = formatterTime.format(timestamp);
    timeString = "$date um $time Uhr";
  }

  // Save everything
  device.lastClockStatusCount = newStatusCount;
  device.lastMessage = msgString;
  device.lastTime = timeString;

  await device.save();

  showNotification(
      "Nachricht von ${device.receiverName}", "$timeString\n$msgString");
}

/// Register a notification listener for the specific device properties.
Future<void> dbRegisterListener(DeviceProperties device) async {
  DatabaseReference starCountRef = FirebaseDatabase.instance
      .ref('clocks/${device.id}/clock_fb/latest_clock_status_count');
  starCountRef.onValue.listen((DatabaseEvent event) async {
    dbShowMessageFromClock(event, device);
  });
}
