import 'package:flutter/material.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/main.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/message_send_view.dart';
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
  final List<Widget> _tabs = List.empty(growable: true);
  final List<Widget> _sites = List.empty(growable: true);
  DeviceTabsView() : super(key: tabsViewKey);

  @override
  State<StatefulWidget> createState() => _DeviceTabsViewState();
}

class _DeviceTabsViewState extends State<DeviceTabsView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    refreshTabController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {
      for (final device in Memory.instance.getDevices()) {
        dbRegisterListener(device);
      }
      refreshTabController();
    });
  }

  void refreshTabController() {
    final props = Memory.instance.getDevices();
    _tabController.dispose();
    widget._tabs.clear();
    widget._sites.clear();

    _tabController = TabController(length: props.length, vsync: this);

    for (DeviceProperties device in props) {
      widget._tabs.add(device.toTab());
      widget._sites.add(MessageSendView(device: device));
    }
  }

  IconButton settingsAction(BuildContext context) {
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
  void didUpdateWidget(covariant DeviceTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Memory.instance.getDevices().length != _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(
          length: Memory.instance.getDevices().length, vsync: this);
      print("updates");
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = Memory.instance.getDevices();
    if (props.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
            actions: <Widget>[settingsAction(context)],
          ),
          body: const NoDevicesAlert());
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          actions: <Widget>[settingsAction(context)],
          bottom: TabBar(
            controller: _tabController,
            tabs: widget._tabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: widget._sites,
        ));
  }
}
