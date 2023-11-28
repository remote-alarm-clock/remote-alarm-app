import 'package:flutter/material.dart';
import 'package:remote_alarm/main.dart';
import 'package:remote_alarm/message_send_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeviceType {
  clock,
  lack;

  @override
  String toString() {
    return name.toString();
  }

  /// Try to create DeviceType from String. If its not possible, throws an UnknownDeviceException!
  static DeviceType fromString(String devType) {
    return DeviceType.values.firstWhere((element) =>
        element.toString() ==
        devType); //, orElse: () => throw UnknownDeviceException("Das Gerät $devType ist nicht implementiert!"));
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
  int lastClockStatusCount;
  String lastMessage;
  String lastTime;

  @override
  bool operator ==(Object other) {
    return other is DeviceProperties && other.id == id;
  }

  DeviceProperties(this.id, this.receiverName, this.deviceType,
      this.lastClockStatusCount, this.lastMessage, this.lastTime);

  /// Create Tab widget from the properties of this device.
  Widget toTab() {
    return Tab(
      text: receiverName,
      icon: deviceType.icon,
    );
  }

  Widget toMessageView() {
    return MessageSendView(device: this);
  }

  /// Try to save DeviceProperties into memory.
  Future<void> save() async {
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

    // Status Count
    await prefs.setInt("${id}_last_clock_status_count", lastClockStatusCount);

    // Last Message
    await prefs.setString("${id}_last_clock_status", lastMessage);

    // Last Time of Message
    await prefs.setString("${id}_last_clock_status_utc", lastTime);

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

    // Status Count
    success = await prefs.remove("${id}_last_clock_status_count");

    // Last Message
    success = await prefs.remove("${id}_last_clock_status");

    // Last Time of Message
    success = await prefs.remove("${id}_last_clock_status_utc");

    // Make the memory instance have newest data.
    await Memory.instance.reload();

    return success;
  }

  @override
  int get hashCode => Object.hash(id, receiverName);
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

/// Here is where the main save shit happens! Wow such wise. Such memory.
/// The Memory class acts as a cache for data. Should something change somewhere else in code, call Memory.instance.reload() to refresh the cache. Thank you!
class Memory {
  List<DeviceProperties> _devices = List.empty(growable: true);
  String? _username;

  static final Memory instance = Memory();

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDevices = prefs.getStringList("saved_devices");

    final List<DeviceProperties> devs = List.empty(growable: true);

    if (savedDevices == null || savedDevices.isEmpty) {
      //throw NoDevicesSavedException("Es wurden keine Geräte gespeichert!");
    } else {
      for (String deviceID in savedDevices) {
        final deviceReceiverName = prefs.getString("${deviceID}_receiver_name");
        final deviceType = prefs.getString("${deviceID}_device_type");
        final deviceStatusCount =
            prefs.getInt("${deviceID}_last_clock_status_count");
        final deviceMessage = prefs.getString("${deviceID}_last_clock_status");
        final deviceMessageTime =
            prefs.getString("${deviceID}_last_clock_status_utc");

        if (deviceReceiverName == null ||
            deviceType == null ||
            deviceStatusCount == null ||
            deviceMessage == null ||
            deviceMessageTime == null) {
          // throw MemoryBrokenException("Es fehlen Parameter vom Gerät $deviceID!");
        } else {
          devs.add(DeviceProperties(
              deviceID,
              deviceReceiverName,
              DeviceType.fromString(deviceType),
              deviceStatusCount,
              deviceMessage,
              deviceMessageTime));
        }
      }
    }

    // Only assign new devices once the entire list has loaded. Should avoid wheird cases (without using mutex :o)
    _devices = devs;

    // Load other variables
    _username = prefs.getString("username");
  }

  List<DeviceProperties> getDevices() {
    return _devices;
  }

  /// Warning! This can be null if no username is set. Should be validated externally! If so, one can set the username with setUsername(String)
  String? getUsername() {
    return _username;
  }

  Future<void> setUsername(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
  }
}

bool memoryNewDeviceAdditionAllowed() {
  if (Memory.instance.getDevices().length >= maximumAllowedDeviceCount) {
    scaffoldKey.currentState!.showSnackBar(const SnackBar(
        content: Text(
            "Es sind bereits $maximumAllowedDeviceCount Geräte hinzugefügt. Bitte ein Gerät entfernen, bevor ein neues hinzugefügt werden kann!")));
    return false;
  }
  return true;
}
