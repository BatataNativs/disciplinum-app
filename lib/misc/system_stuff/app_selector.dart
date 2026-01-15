import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'dart:io';

class AppSelector extends StatefulWidget {
  final void Function(String package, String appName, Uint8List? icon)
      onSelected;

  const AppSelector({super.key, required this.onSelected});

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  List<AppInfo> _apps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    if (kIsWeb || !Platform.isAndroid) {
      setState(() {
        _apps = [];
        _loading = false;
      });
      return;
    }
    final apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      withIcon: true,
    );
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apps.isEmpty) {
      return const Center(child: Text('Função disponível só no Android.'));
    }
    return ListView.builder(
      itemCount: _apps.length,
      itemBuilder: (context, idx) {
        final app = _apps[idx];
        return ListTile(
          leading: app.icon != null
              ? Image.memory(app.icon!, width: 40, height: 40)
              : const Icon(Icons.apps),
          title: Text(app.name),
          subtitle: Text(app.packageName),
          onTap: () {
            widget.onSelected(app.packageName, app.name, app.icon);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
