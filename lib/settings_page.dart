import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/username_setup_dialog.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'clockid_setup_dialog.dart';
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
  late String _clock_id;
  @override
  void initState() {
    super.initState();
    _username = 'nicht-gesetzt';
    _userEmail = 'abgemeldet';
    _clock_id = 'uninitialisiert';
    _loggedIn = false;
    reloadSettings();
  }

  Future<void> reloadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (Memory.instance.getUsername() != null) {
      _username = Memory.instance.getUsername()!;
    }
    if (prefs.getString("clock_id") != null) {
      _clock_id = prefs.getString("clock_id")!;
    }
    if (FirebaseAuth.instance.currentUser != null) {
      _loggedIn = true;
      _userEmail = FirebaseAuth.instance.currentUser!.email!;
    } else {
      _loggedIn = false;
    }

    setState(() {});
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
          sections: [
            SettingsSection(
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
            ),
            SettingsSection(
              title: const Text('Wecker'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.lock_clock),
                  onPressed: (context) async {
                    await clockidDialogBuilder(context);
                    await reloadSettings();
                  },
                  title: Text(
                    'Angesteuerter Wecker',
                    style: TextStyle(
                        color: (_clock_id == "uninitialisiert"
                            ? Colors.red
                            : Colors.black)),
                  ),
                  value: Text(_clock_id),
                ),
              ],
            ),
          ],
        ));
  }
}
