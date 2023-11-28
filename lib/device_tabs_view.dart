import 'package:flutter/material.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/main.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';

final tabsViewKey = GlobalKey<_DeviceTabsViewState>();

class NoDevicesAlert extends StatelessWidget {
  const NoDevicesAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.alarm),
                  title: Text("Keine Geräte!"),
                  subtitle: Text(
                      "Es wurden keine Geräte hinzugefügt. Bitte gehe in die Einstellungen um dort ein Gerät hinzuzufügen."),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Einstellungen'),
                      onPressed: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const SettingsPage();
                        }));
                        if (tabsViewKey.currentState != null) {
                          tabsViewKey.currentState!.refresh();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          )),
      const Spacer(flex: 10),
    ]);
  }
}

class DeviceTabsView extends StatefulWidget {
  DeviceTabsView() : super(key: tabsViewKey);

  @override
  State<StatefulWidget> createState() => _DeviceTabsViewState();
}

class _DeviceTabsViewState extends State<DeviceTabsView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {
      for (final device in Memory.instance.getDevices()) {
        dbRegisterListener(device);
      }
    });
  }

  IconButton _settingsAction(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Öffne Einstellungen',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const SettingsPage();
          }));
          refresh();
        });
  }

  @override
  Widget build(BuildContext context) {
    final props = Memory.instance.getDevices();
    if (props.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
            actions: <Widget>[_settingsAction(context)],
          ),
          body: const NoDevicesAlert());
    }

    return DefaultTabController(
        length: props.length,
        child: Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
              actions: <Widget>[_settingsAction(context)],
              bottom: TabBar(
                tabs: props.map((device) => device.toTab()).toList(),
              ),
            ),
            body: TabBarView(
              children: props.map((device) => device.toMessageView()).toList(),
            )));
  }
}
