import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'device_type.dart';

/**
 * HOW TO ADD DeviceClasses
 * 
 * Hello. In order to add a new device type to the app you got to do several things
 * - First: Go to 'device_type.dart' and add a new enum with the exact name of the type you want to support. (No Spaces allowed.) This name is used 1to1 in the serialization to Firebase. So chose wisely. (Also name should match, whats in the devices firmware.)
 * - Second: Add a new class here which 'implements DeviceClass' For orientation you can use the 'NotImplementedDevice' sample. Naming: ALWAYS use a descriptive name. Also the name should end with 'Device'.
 *           Don't forget to add a 'const' constructor. Put the class into a new file naming it 'device_class_{name}.dart'.
 * - Third: Go back to 'device_type.dart' and expand the 'deviceClass' getters switch statement to return your new class. (See 'unknown' example aswell).
 * - Fourth: Stonks.
 */

/// This packages all display methods for the device into a convenient class for the masses.
abstract class DeviceClass {
  const DeviceClass();

  /// When displaying the `MessageSendView` class this functions gets called a lot to render a preview of the message on the device. Here you can enjoy maximum creativity with images and stuff. Thats why the BuildContext is given.
  /// [messagePreviewed] The message string which the user wants to send. Unformatted.
  /// [username] The users username. At this point, it will be non-empty.
  Widget toMessagePreview(
      BuildContext context, String messagePreviewed, String username);

  /// Return What this devices Icon should be.
  Widget toIcon();

  /// The cleartext name of this device. Can be localized, but should be String for now.
  String getDisplayName();

  /// The devices enumeratable type.
  DeviceType getDeviceType();
  @override
  String toString() {
    return getDeviceType().toString();
  }

  /// Return whether [message] is valid to be sent to this device.
  /// First index is a bool indicating whether [message] is valid.
  /// Second opional index is the error message to be displayed to a user.
  List isMessageValid(String message);
}

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


// icons.alarm and icons.remove for clock and lack

