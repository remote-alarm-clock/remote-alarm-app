import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'device_class.dart';
import 'device_type.dart';

class ClockDevice implements DeviceClass {
  const ClockDevice();
  @override
  DeviceType getDeviceType() {
    return DeviceType.clock;
  }

  @override
  String getDisplayName() {
    return "Wecker";
  }

  @override
  List isMessageValid(String message) {
    return [
      message.length <= 126,
      "Nachricht darf nicht länger als 126 Zeichen sein!"
    ];
  }

  @override
  Widget toIcon() {
    return const Icon(Icons.alarm);
  }

  @override
  Widget toMessagePreview(
      BuildContext context, String messagePreviewed, String username) {
    const clockImage = 'assets/clockface_zoom.svg';
    double width =
        MediaQuery.of(context).size.width * 0.4; //40% of screen width

    double fullScreenWidth =
        MediaQuery.of(context).size.width; //100% of screen width

    String displayedMessage = "$username> $messagePreviewed";

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
                        displayedMessage.padRight(21).replaceAllMapped(
                            RegExp(r'.{21}'), (match) => "${match.group(0)}\n"),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 90,
                            fontFamily: 'RobotoMono',
                            color: Colors.white))), // Display
              ),
            )
          ],
        ));
  }
}
