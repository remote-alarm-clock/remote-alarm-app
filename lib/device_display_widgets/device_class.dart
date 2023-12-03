import 'package:flutter/material.dart';
import 'package:remote_alarm/memory.dart';

/// This packages all display methods for the device into a convenient class for the masses.
abstract class DeviceClass {
  const DeviceClass();
  Widget toMessagePreview(
      BuildContext context, String messagePreviewed, String username);
  Widget toIcon();
  String getDisplayName();
  DeviceType getDeviceType();
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
}

// icons.alarm and icons.remove for clock and lack

/* 
 double width =
        MediaQuery.of(context).size.width * 0.4; //40% of screen width

    double fullScreenWidth =
        MediaQuery.of(context).size.width; //100% of screen width

    return SizedBox(
        width: fullScreenWidth,
        child: Stack(
          children: [
            SvgPicture.asset(clockImage,
                width: fullScreenWidth,
                semanticsLabel: 'clockface'), // Background picture of clockface
            // Image aspect ratio: 0.5053, left relative to image: 0.2565, top relative to height: 0.2737
            Positioned(
              top: fullScreenWidth * 0.5053 * 0.2737, // height * top spacing
              left: fullScreenWidth * 0.2565, // width * left spacing
              child: Container(
                alignment: Alignment.topLeft,
                width: width,
                height: 0.65 * width, // Match 128*64 aspect ratio
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        widget._displayedMessage.padRight(21).replaceAllMapped(
                            RegExp(r'.{21}'), (match) => "${match.group(0)}\n"),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 90,
                            fontFamily: 'RobotoMono',
                            color: Colors.white))), // Display
              ),
            )
          ],
        ));*/