import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPageClockConfigure extends StatefulWidget {
  final DeviceProperties _currentDevice;
  const SettingsPageClockConfigure(
      {super.key, required DeviceProperties currentDevice})
      : _currentDevice = currentDevice;

  @override
  State<SettingsPageClockConfigure> createState() =>
      _SettingsPageClockConfigureState();
}

class _SettingsPageClockConfigureState
    extends State<SettingsPageClockConfigure> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> removeCurrentDevice(
      DeviceProperties device, BuildContext context) async {
    await device.remove();
    if (context.mounted) Navigator.pop(context);
  }

  SettingsSection deviceInformationSection() {
    return SettingsSection(title: const Text('Informationen'), tiles: [
      SettingsTile(
          title: const Text("Geräte-ID"),
          description: Text(widget._currentDevice.id),
          leading: const Icon(Icons.label)),
      SettingsTile(
          title: const Text("Besitzer"),
          description: Text(widget._currentDevice.receiverName),
          leading: const Icon(Icons.person)),
      SettingsTile(
          title: const Text("Gerätetyp"),
          description: Text(widget._currentDevice.deviceType.toString()),
          leading: widget._currentDevice.deviceType.icon)
    ]);
  }

  SettingsSection deviceActionSection() {
    return SettingsSection(title: const Text('Aktionen'), tiles: [
      SettingsTile(
          title: const Text("Gerät entfernen",
              style: TextStyle(color: Colors.redAccent)),
          description: const Text(
            "Entfernt das Gerät aus der App!",
            style: TextStyle(color: Colors.redAccent),
          ),
          leading: const Icon(
            Icons.delete,
          ),
          onPressed: (context) {
            removeCurrentDevice(widget._currentDevice, context);
          }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn()) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bitte melde dich an!")));
      });
    }

    return Scaffold(
        appBar: AppBar(
            title: Text('Einstellungen für ${widget._currentDevice.id}')),
        body: SettingsList(
            sections: [deviceInformationSection(), deviceActionSection()]));
  }
}
