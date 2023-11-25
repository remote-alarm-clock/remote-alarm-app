import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeviceType {
  clock,
  lack;

  /// Try to create DeviceType from String. If its not possible, throws an UnknownDeviceException!
  static DeviceType fromString(String? devType) {
    return DeviceType.values.firstWhere(
        (element) => element.toString() == devType,
        orElse: () => throw UnknownDeviceException(
            "Das Gerät $devType ist nicht implementiert!"));
  }
}

// Cool type of extensions on values (instead of creating methods on the enum).
extension DeviceTypeIcon on DeviceType {
  /// Get Icon corresponding to the type of device.
  Icon get icon {
    switch (this) {
      case DeviceType.clock:
        return const Icon(Icons.alarm);
      case DeviceType.lack:
        return const Icon(Icons.remove);
      default:
        return const Icon(Icons.question_mark);
    }
  }
}

class DeviceProperties {
  String id;
  String receiverName;
  DeviceType deviceType;

  DeviceProperties(devID, devReceiverName, devType)
      : id = devID,
        receiverName = devReceiverName,
        deviceType = devType;

  /// Create Tab widget from the properties of this device.
  Widget toTab() {
    return Tab(
      text: receiverName,
      icon: deviceType.icon,
    );
  }

  /// Try to save DeviceProperties into memory.
  void save() async {
    final prefs = await SharedPreferences.getInstance();

    // ID in List
    List<String>? savedDevices = prefs.getStringList("saved_devices");
    savedDevices ??= List.empty(growable: true); // If null, initialize
    if (!savedDevices.contains(id)) {
      savedDevices.add(id);
    }
    await prefs.setStringList("saved_devices", savedDevices);

    // Receiver Name
    await prefs.setString("${id}_receiver_name", receiverName);

    // Device Type
    await prefs.setString("${id}_device_type", deviceType.toString());

    // Make the memory instance have newest data.
    await Memory.instance.reload();
  }

  /// Try to remove the DeviceProperties from memory.
  /// @return true if remove successful, false if not in memory or something went wrong.
  Future<bool> remove() async {
    final prefs = await SharedPreferences.getInstance();
    bool success = true;

    // ID in List
    List<String>? savedDevices = prefs.getStringList("saved_devices");
    if (savedDevices == null || !savedDevices.contains(id)) {
      return false;
    }

    savedDevices.remove(id);

    success = await prefs.setStringList("saved_devices", savedDevices);

    // Receiver Name
    success = await prefs.remove("${id}_receiver_name");

    // Device Type
    success = await prefs.remove("${id}_device_type");

    // Make the memory instance have newest data.
    await Memory.instance.reload();

    return success;
  }
}

class UnknownDeviceException implements Exception {
  String cause;
  UnknownDeviceException(this.cause);
}

class NoDevicesSavedException implements Exception {
  String cause;
  NoDevicesSavedException(this.cause);
}

class MemoryBrokenException implements Exception {
  String cause;
  MemoryBrokenException(this.cause);
}

// Here is where the main save shit happens! Wow such wise. Such memory.
class Memory {
  List<DeviceProperties> _devices = List.empty(growable: true);

  static final Memory instance = Memory();

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDevices = prefs.getStringList("saved_devices");

    final List<DeviceProperties> devs = List.empty(growable: true);

    if (savedDevices == null || savedDevices.isEmpty) {
      throw NoDevicesSavedException("Es wurden keine Geräte gespeichert!");
    }

    for (String deviceID in savedDevices) {
      final deviceReceiverName = prefs.getString("${deviceID}_receiver_name");
      final deviceType = prefs.getString("${deviceID}_device_type");

      if (deviceReceiverName == null || deviceType == null) {
        throw MemoryBrokenException("Es fehlen Parameter vom Gerät $deviceID!");
      }

      devs.add(DeviceProperties(
          deviceID, deviceReceiverName, DeviceType.fromString(deviceType)));
    }

    // Only assign new devices once the entire list has loaded. Should avoid wheird cases (without using mutex :o)
    _devices = devs;
  }

  List<DeviceProperties> getDevices() {
    return _devices;
  }
}