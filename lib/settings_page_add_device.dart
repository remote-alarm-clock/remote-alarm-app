import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';
import 'package:settings_ui/settings_ui.dart';

/// This Widget is a screen to add a new device to the clock list.
class SettingsPageAddDevice extends StatefulWidget {
  const SettingsPageAddDevice({super.key});

  @override
  State<SettingsPageAddDevice> createState() => _SettingsPageAddDeviceState();
}

class _SettingsPageAddDeviceState extends State<SettingsPageAddDevice> {
  List<DeviceProperties> _devices = List.empty();
  bool allDevicesAlreadyAdded = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadDevices() async {
    List<DeviceProperties> dbDevices = await dbGetDevices();
    List<DeviceProperties> shownDevices = [];
    // Subtract one from another.
    for (DeviceProperties element in dbDevices) {
      if (!Memory.instance.getDevices().contains(element)) {
        shownDevices.add(element);
      }
    }

    _devices = shownDevices;

    if (dbDevices.isNotEmpty && shownDevices.isEmpty) {
      allDevicesAlreadyAdded = true;
    }
  }

  Future<void> saveNewDevice(
      DeviceProperties device, BuildContext context) async {
    await device.save();
    if (context.mounted) Navigator.pop(context);
  }

  SettingsSection deviceSelectSection() {
    List<SettingsTile> deviceTileList = List.empty(growable: true);

    bool noDevicesLoaded = true;

    for (DeviceProperties device in _devices) {
      //Memory.instance.getDevices()) {
      SettingsTile deviceTile = SettingsTile(
        title: Text(device.id),
        description: Text("Besitzer: ${device.receiverName}"),
        leading: device.deviceClass.toIcon(),
        onPressed: (context) {
          saveNewDevice(device, context);
        },
      );

      deviceTileList.add(deviceTile);
      noDevicesLoaded = false;
    }

    // Add a "no devices loaded" tile if there are no devices yet added.
    if (noDevicesLoaded) {
      deviceTileList.add(SettingsTile(
          title: const Text("Keine Geräte verfügbar"),
          enabled: false,
          description: Text((allDevicesAlreadyAdded
              ? "Alle Geräte aus der Datenbank wurden bereits hinzugefügt."
              : "In der Datenbank sind keine Geräte. Bitte zuerst ein Gerät mit Datenbank verbinden!")),
          leading: const Icon(Icons.warning)));
    }

    return SettingsSection(
        title: const Text('Verfügbare Geräte aus Datenbank'),
        tiles: deviceTileList);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn()) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bitte melde dich an!")));
      });
    }

    return FutureBuilder(
        future: loadDevices(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print("Something went wrong");
            return Scaffold(
                appBar: AppBar(title: const Text('Gerät hinzufügen')),
                body: const Center(
                    child: Text("Datenbank konnte nicht geladen werden!")));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(title: const Text('Gerät hinzufügen')),
                body: SettingsList(sections: [deviceSelectSection()]));
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
              appBar: AppBar(title: const Text('Gerät hinzufügen')),
              body: const Center(child: Text("Lade Datenbank...")));
        });
  }
}
