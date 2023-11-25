import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page_add_device.dart';
import 'package:remote_alarm/settings_page_clock_configure.dart';
import 'package:remote_alarm/username_setup_dialog.dart';
import 'package:settings_ui/settings_ui.dart';

import 'login_dialog.dart';

Future<void> signout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
}

bool isLoggedIn() {
  return FirebaseAuth.instance.currentUser != null;
}

/**
 * SETTINGS
 */
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _username;
  late String _userEmail;
  late bool _loggedIn;
  @override
  void initState() {
    super.initState();
    _username = 'nicht-gesetzt';
    _userEmail = 'abgemeldet';
    _loggedIn = false;
    reloadSettings();
  }

  Future<void> reloadSettings() async {
    if (Memory.instance.getUsername() != null) {
      _username = Memory.instance.getUsername()!;
    }
    if (FirebaseAuth.instance.currentUser != null) {
      _loggedIn = true;
      _userEmail = FirebaseAuth.instance.currentUser!.email!;
    } else {
      _loggedIn = false;
    }

    setState(() {});
  }

  SettingsSection userSettingsSection() {
    return SettingsSection(
      title: const Text('Benutzer'),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
          leading: const Icon(Icons.person),
          title: const Text('Benutzername'),
          value: Text(_username),
          onPressed: (context) async {
            await usernameDialogBuilder(context);
            await reloadSettings();
          },
        ),
        credentialWidget(),
      ],
    );
  }

  SettingsTile credentialWidget() {
    if (_loggedIn) {
      return SettingsTile.navigation(
        leading: const Icon(Icons.logout),
        title: const Text('Abmelden'),
        value: Text(_userEmail),
        onPressed: (context) async {
          await signout(context);
          await reloadSettings();
        },
      );
    } else {
      return SettingsTile.navigation(
        leading: const Icon(Icons.login),
        title: const Text(
          'Anmelden',
          style: TextStyle(color: Colors.red),
        ),
        onPressed: (context) async {
          await loginDialogBuilder(context);
          await reloadSettings();
        },
      );
    }
  }

  SettingsSection deviceSettingsSection() {
    List<SettingsTile> deviceTileList = List.empty(growable: true);

    deviceTileList.add(SettingsTile(
      title: const Text("Gerät hinzufügen"),
      description: const Text("Füge ein Gerät zur Liste hinzu"),
      leading: const Icon(Icons.add),
      onPressed: (context) async {
        // Check if a new device can be added.
        if (!memoryNewDeviceAdditionAllowed()) return;
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const SettingsPageAddDevice();
        }));
        setState(() {});
      },
    ));

    bool noDevicesLoaded = true;

    for (DeviceProperties device in Memory.instance.getDevices()) {
      SettingsTile deviceTile = SettingsTile.navigation(
        title: Text(device.id),
        description: Text("Besitzer: ${device.receiverName}"),
        leading: device.deviceType.icon,
        onPressed: (context) async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SettingsPageClockConfigure(currentDevice: device);
          }));
          setState(() {});
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
          description: const Text("Füge ein Gerät mit der Option oben hinzu!"),
          leading: const Icon(Icons.warning)));
    }
    return SettingsSection(title: const Text('Wecker'), tiles: deviceTileList);
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
        appBar: AppBar(title: const Text('Einstellungen')),
        body: SettingsList(
            sections: [userSettingsSection(), deviceSettingsSection()]));
  }
}
