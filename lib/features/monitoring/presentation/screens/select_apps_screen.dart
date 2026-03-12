import 'package:disciplinum/models/user_niche_app.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'dart:typed_data';

import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/storage/preferences_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class SelectAppsScreenArgs {
  final List<String> initiallySelected;
  final void Function(List<String>) onSaved;
  final NicheId nicheId;

  SelectAppsScreenArgs({
    required this.initiallySelected,
    required this.onSaved,
    required this.nicheId,
  });
}

class AsyncAppIcon extends StatefulWidget {
  final String packageName;
  final bool isDark;

  const AsyncAppIcon({
    super.key,
    required this.packageName,
    required this.isDark,
  });

  @override
  State<AsyncAppIcon> createState() => _AsyncAppIconState();
}

class _AsyncAppIconState extends State<AsyncAppIcon> {
  Future<Uint8List?>? _iconFuture;

  @override
  void initState() {
    super.initState();
    _iconFuture = InstalledAppService().getAppIcon(widget.packageName);
  }

  @override
  void didUpdateWidget(AsyncAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _iconFuture = InstalledAppService().getAppIcon(widget.packageName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _iconFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          );
        }

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isDark ? Colors.white12 : Colors.black12,
          ),
          child: const Icon(Icons.android, size: 20, color: Colors.grey),
        );
      },
    );
  }
}

class SelectAppsScreen extends StatefulWidget {
  final SelectAppsScreenArgs args;
  const SelectAppsScreen({super.key, required this.args});

  @override
  State<SelectAppsScreen> createState() => _SelectAppsScreenState();
}

class _SelectAppsScreenState extends State<SelectAppsScreen> {
  final Set<String> _selected = <String>{};
  String _searchQuery = '';
  bool _includeSystemApps = false;

  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoadingApps = true;

  late final NicheId _nicheId;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _nicheId = widget.args.nicheId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingApps = true);

    _isGuest = await PreferencesService.isGuestMode();

    try {
      final results = await Future.wait([
        _isGuest
            ? PreferencesService.loadUserNicheApps(nicheId: _nicheId)
            : CloudSyncService.loadUserNicheApps(nicheId: _nicheId),
        InstalledAppService().getApps(
          excludeSystemApps: !_includeSystemApps,
        ),
      ]);

      final userApps = results[0];
      _allApps = results[1] as List<AppInfo>;

      final saved =
          (userApps as List<UserNicheApp>).map((a) => a.appPackage).toList();

      _selected.clear();
      _selected
          .addAll(saved.isNotEmpty ? saved : widget.args.initiallySelected);

      _applyFiltersAndSort();
    } catch (e) {
      LoggerService.instance.e('Error loading apps', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingApps = false);
      }
    }
  }

  void _applyFiltersAndSort() {
    List<AppInfo> filtered = _allApps;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = _allApps.where((app) {
        return app.name.toLowerCase().contains(query) ||
            app.packageName.toLowerCase().contains(query);
      }).toList();
    }

    final sorted = List<AppInfo>.from(filtered);
    sorted.sort((a, b) {
      final aSelected = _selected.contains(a.packageName);
      final bSelected = _selected.contains(b.packageName);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    _filteredApps = sorted;
  }

  String get _systemAppsSubtitle {
    if (_nicheId == NicheId.spending) {
      return 'Ex: Mercado Livre, Amazon, Shopee...';
    } else if (_nicheId == NicheId.bingeEating) {
      return 'Ex: iFood, Rappi, Zé Delivery...';
    }
    return 'Ex: Configurações, Relógio, Câmera...';
  }

  void _toggle(String packageName) {
    setState(() {
      if (_selected.contains(packageName)) {
        _selected.remove(packageName);
      } else {
        _selected.add(packageName);
      }
      // Removido _applyFiltersAndSort() para evitar que a lista pule
      // e para economizar processamento durante interações rápidas.
    });
  }

  Future<void> _save() async {
    // VALIDAÇÃO: Verificar se selecionou pelo menos um app
    if (_selected.isEmpty) {
      EnhancedSnackBarHelper.showWarning(
        context,
        "Escolha pelo menos um app",
      );
      return;
    }

    // FASE 7: Verificar permissão de sobreposição para o Timer visual
    if (!mounted) return;
    final hasOverlay = await PermissionService.ensureOverlayPermission(context);
    if (!hasOverlay) {
      // O usuário recusou ou fechou o diálogo, mas permitimos salvar
      // (o overlay apenas não aparecerá até ele ativar).
      // Mas o ideal é avisar.
      LoggerService.instance.w('Usuário não concedeu permissão de sobreposição ainda.');
    }

    if (_isGuest) {
      await PreferencesService.removeAllAppsForNiche(nicheId: _nicheId);
      for (final app in _selected) {
        await PreferencesService.addUserNicheApp(
          nicheId: _nicheId,
          package: app,
        );
      }
    } else {
      await CloudSyncService.removeAllAppsForNiche(nicheId: _nicheId);
      for (final app in _selected) {
        await CloudSyncService.addUserNicheApp(
          nicheId: _nicheId,
          package: app,
        );
      }
    }

    widget.args.onSaved(_selected.toList());
    if (!mounted) return;
    Navigator.pop(context);

    EnhancedSnackBarHelper.showSuccess(context, 'Apps selecionados salvos!');
  }

  Future<void> _removeApp(String packageName) async {
    setState(() {
      _selected.remove(packageName);
      _applyFiltersAndSort();
    });

    if (_isGuest) {
      await PreferencesService.removeUserNicheApp(
        nicheId: _nicheId,
        package: packageName,
      );
    } else {
      await CloudSyncService.removeUserNicheApp(
        nicheId: _nicheId,
        package: packageName,
      );
    }

    if (!mounted) return;

    EnhancedSnackBarHelper.showInfo(context, 'App removido: $packageName');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Selecionar aplicativos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoadingApps
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar app...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        setState(() {
                          _applyFiltersAndSort();
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Exibir aplicativos nativos do dispositivo',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _systemAppsSubtitle,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      activeThumbColor: Colors.green,
                      dense: true,
                      value: _includeSystemApps,
                      onChanged: (val) async {
                        setState(() => _isLoadingApps = true);
                        _includeSystemApps = val;
                        _allApps = await InstalledAppService().getApps(
                          excludeSystemApps: !_includeSystemApps,
                          forceRefresh: true,
                        );
                        _applyFiltersAndSort();
                        if (mounted) setState(() => _isLoadingApps = false);
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _filteredApps.isEmpty
                          ? Center(
                              child: Text(
                                _allApps.isEmpty
                                    ? 'Nenhum app encontrado.'
                                    : 'Nenhum app encontrado com "$_searchQuery"',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredApps.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final app = _filteredApps[index];
                                final selected =
                                    _selected.contains(app.packageName);

                                return GestureDetector(
                                  key: ValueKey(app.packageName),
                                  onLongPress: selected
                                      ? () => _removeApp(app.packageName)
                                      : null,
                                  onTap: () => _toggle(app.packageName),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? (isDark
                                              ? Colors.green
                                                  .withValues(alpha: 0.15)
                                              : Colors.green
                                                  .withValues(alpha: 0.1))
                                          : (isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.05)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selected
                                            ? Colors.green
                                                .withValues(alpha: 0.5)
                                            : (isDark
                                                ? Colors.white10
                                                : Colors.black
                                                    .withValues(alpha: 0.05)),
                                        width: selected ? 1.5 : 1.0,
                                      ),
                                      boxShadow: [
                                        if (!isDark && !selected)
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: AsyncAppIcon(
                                            packageName: app.packageName,
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                app.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: selected
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                app.packageName,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selected
                                                ? Colors.green
                                                : (isDark
                                                    ? Colors.white12
                                                    : Colors.black.withValues(
                                                        alpha: 0.05)),
                                          ),
                                          child: selected
                                              ? const Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : const Icon(Icons.add,
                                                  size: 16, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selected.length} app(s) selecionado(s)',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Salvar apps selecionados'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
