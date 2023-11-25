import 'package:flutter/material.dart';

enum DeviceType {
  clock,
  lack;
}

class DeviceProperties {
  String id;
  String receiverName;
  DeviceType deviceType;

  DeviceProperties(devID, devReceiverName, devType)
      : id = devID,
        receiverName = devReceiverName,
        deviceType = devType;
}

Icon deviceTypeToIcon(DeviceType type) {
  return const Icon(Icons.alarm);
}

Widget deviceToTab(DeviceProperties properties) {
  return Tab(
    text: properties.receiverName,
    icon: deviceTypeToIcon(properties.deviceType),
  );
}
