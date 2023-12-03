import 'package:flutter/material.dart';

import 'device_class.dart';
import 'device_type.dart';

class NotImplementedDevice implements DeviceClass {
  const NotImplementedDevice();
  @override
  String getDisplayName() {
    return "Unbekannt";
  }

  @override
  Widget toIcon() {
    return const Icon(Icons.question_mark);
  }

  @override
  Widget toMessagePreview(
      BuildContext context, String messagePreviewed, String username) {
    return Center(
        child: Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Text(
        "$username > $messagePreviewed",
        style: const TextStyle(),
      ),
    ));
  }

  @override
  DeviceType getDeviceType() {
    return DeviceType.unknown;
  }

  @override
  List isMessageValid(String message) {
    return [
      message.length <= 100,
      "Nachricht darf nicht länger als 100 Zeichen sein!"
    ];
  }
}
