import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'device_class.dart';
import 'device_type.dart';

class LackDevice implements DeviceClass {
  const LackDevice();
  @override
  DeviceType getDeviceType() {
    return DeviceType.lack;
  }

  @override
  String getDisplayName() {
    return "Lack Regalbrett";
  }

  @override
  List isMessageValid(String message) {
    return [
      message.length <= 100,
      "Nachricht darf nicht länger als 100 Zeichen sein!"
    ];
  }

  @override
  Widget toIcon() {
    return const Icon(Icons.remove);
  }

  @override
  Widget toMessagePreview(
      BuildContext context, String messagePreviewed, String username) {
    const backgroundImage = 'assets/lackface_no_bitmap.svg';

    double fullScreenWidth =
        MediaQuery.of(context).size.width; //100% of screen width

    const double aspectRatioOfImage = 40 / 144;

    // WIDTH: 144 Start 8 END 144-8 = 128/144 = 0.888
    // HEIGHT: 40 Start 27 END 27+8 = 8/40 = 0.2
    const double factorTextboxWidth = 0.888;
    const double factorTextboxHeight = aspectRatioOfImage * 0.2;

    // left: 8/144 = 0.0555 top: 27/40 = 0.675
    const double factorTextboxLeft = 0.0555;
    const double factorTextboxTop = 0.675;
    String displayedMessage = "$username> $messagePreviewed";

    return SizedBox(
        width: fullScreenWidth,
        child: Stack(
          children: [
            SvgPicture.asset(backgroundImage,
                width: fullScreenWidth,
                semanticsLabel: 'lackface'), // Background picture of lack
            // Image aspect ratio: 0.5053, left relative to image: 0.2565, top relative to height: 0.2737
            Positioned(
              top: fullScreenWidth * aspectRatioOfImage * factorTextboxTop,
              left: fullScreenWidth * factorTextboxLeft,
              child: Container(
                alignment: Alignment.centerLeft,
                width: fullScreenWidth * factorTextboxWidth,
                height: fullScreenWidth * factorTextboxHeight,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(displayedMessage,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 90,
                            fontFamily: 'Minecraft',
                            color: Colors.red))), // Display
              ),
            )
          ],
        ));
  }
}
