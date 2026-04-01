import 'package:disciplinum/shared/models/user_niche_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:installed_apps/app_info.dart';
import 'dart:typed_data';

import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
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

class SelectAppsScreen extends ConsumerStatefulWidget {
  final SelectAppsScreenArgs args;
  const SelectAppsScreen({super.key, required this.args});

  @override
  ConsumerState<SelectAppsScreen> createState() => _SelectAppsScreenState();
}

class _SelectAppsScreenState extends ConsumerState<SelectAppsScreen> {
  final Set<String> _selected = <String>{};
  String _searchQuery = '';

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

    final prefs = ref.read(preferencesServiceProvider);
    _isGuest = await prefs.isGuestMode();

    try {
      final results = await Future.wait([
        _isGuest
            ? prefs.loadUserNicheApps(nicheId: _nicheId)
            : ref.read(cloudSyncServiceProvider).loadUserNicheApps(nicheId: _nicheId),
        InstalledAppService().getApps(
          excludeSystemApps: false,
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


  void _toggle(String packageName) {
    setState(() {
      if (_selected.contains(packageName)) {
        _selected.remove(packageName);
      } else {
        _selected.add(packageName);
      }
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
      final prefs = ref.read(preferencesServiceProvider);
      await prefs.removeAllAppsForNiche(nicheId: _nicheId);
      for (final app in _selected) {
        await prefs.addUserNicheApp(
          nicheId: _nicheId,
          package: app,
        );
      }
    } else {
      final cloudSync = ref.read(cloudSyncServiceProvider);
      await cloudSync.removeAllAppsForNiche(nicheId: _nicheId);
      for (final app in _selected) {
        await cloudSync.addUserNicheApp(
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
      await ref.read(preferencesServiceProvider).removeUserNicheApp(
        nicheId: _nicheId,
        package: packageName,
      );
    } else {
      await ref.read(cloudSyncServiceProvider).removeUserNicheApp(
        nicheId: _nicheId,
        package: packageName,
      );
    }

    if (!mounted) return;

    EnhancedSnackBarHelper.showInfo(context, 'App removido: $packageName');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.black]
                : [
                    colorScheme.primary.withValues(alpha: 0.06),
                    colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Selecionar aplicativos',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // --- Body ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isLoadingApps
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // Search bar
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar app...',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                prefixIcon: Icon(Icons.search_rounded,
                                    color: colorScheme.primary),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : colorScheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
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
                            const SizedBox(height: 12),
                            // App list
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
                                        final selected = _selected
                                            .contains(app.packageName);

                                        return GestureDetector(
                                          key: ValueKey(app.packageName),
                                          onLongPress: selected
                                              ? () =>
                                                  _removeApp(app.packageName)
                                              : null,
                                          onTap: () =>
                                              _toggle(app.packageName),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            padding:
                                                const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? Colors.green
                                                      .withValues(
                                                          alpha: isDark
                                                              ? 0.15
                                                              : 0.08)
                                                  : (isDark
                                                      ? Colors.white
                                                          .withValues(
                                                              alpha: 0.05)
                                                      : colorScheme.surface),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: selected
                                                    ? Colors.green
                                                        .withValues(
                                                            alpha: 0.5)
                                                    : colorScheme.outline
                                                        .withValues(
                                                            alpha: 0.15),
                                                width:
                                                    selected ? 1.5 : 1.0,
                                              ),
                                              boxShadow: [
                                                if (!isDark)
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.04),
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(0, 2),
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
                                                            .withValues(
                                                                alpha: 0.1),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(
                                                                0, 2),
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                  child: AsyncAppIcon(
                                                    packageName:
                                                        app.packageName,
                                                    isDark: isDark,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        app.name,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                        style: textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          fontWeight: selected
                                                              ? FontWeight
                                                                  .bold
                                                              : FontWeight
                                                                  .w600,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 2),
                                                      Text(
                                                        app.packageName,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                        style: textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha:
                                                                      0.45),
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selected
                                                        ? Colors.green
                                                        : colorScheme
                                                            .onSurface
                                                            .withValues(
                                                                alpha:
                                                                    0.08),
                                                  ),
                                                  child: Icon(
                                                    selected
                                                        ? Icons.check
                                                        : Icons.add,
                                                    size: 16,
                                                    color: selected
                                                        ? Colors.white
                                                        : colorScheme
                                                            .onSurface
                                                            .withValues(
                                                                alpha:
                                                                    0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            // --- Bottom area ---
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      size: 18, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_selected.length} app(s) selecionado(s)',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _save,
                                icon: const Icon(Icons.save_rounded),
                                label: const Text(
                                  'Salvar apps selecionados',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
