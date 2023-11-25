import 'package:flutter/material.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/message_send_view.dart';

class DeviceTabsView extends StatefulWidget {
  final List<DeviceProperties> presentedDevices;

  const DeviceTabsView({super.key, required this.presentedDevices});

  @override
  State<StatefulWidget> createState() => _DeviceTabsViewState();
}

class _DeviceTabsViewState extends State<DeviceTabsView>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<Widget> _tabs = List.empty(growable: true);
  final List<Widget> _sites = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.presentedDevices.length, vsync: this);

    for (DeviceProperties device in widget.presentedDevices) {
      _tabs.add(device.toTab());
      _sites.add(MessageSendView(device: device));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geräte"),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sites,
      ),
    );
  }
}
