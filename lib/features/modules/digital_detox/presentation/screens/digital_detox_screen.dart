import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/providers/digital_detox_providers.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_applock_service.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_time_settings_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_limits_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_rollover_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_weekly_screen.dart';
import 'package:disciplinum/features/modules/digital_detox/presentation/screens/digital_detox_fasting_breaks_screen.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'package:disciplinum/features/monitoring/presentation/screens/select_apps_screen.dart';

class DigitalDetoxScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  const DigitalDetoxScreen({super.key, this.heroTag});

  @override
  ConsumerState<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends ConsumerState<DigitalDetoxScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.digitalDetox);
  final List<String> _selectedApps = [];
  bool _isModuleActive = false;
  bool _isLoadingData = false;

  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAllPersistentData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      final service = ref.read(digitalDetoxServiceLocalProvider);
      
      // Carregar dados locais sem depender de cloud sync
      final config = await service.getOrCreateConfig(userId);
      final apps = config.monitoredApps;

      if (mounted) {
        setState(() {
          _selectedApps.clear();
          _selectedApps.addAll(apps);
          _isModuleActive = config.isModuleActive;
        });

        if (_isModuleActive) {
          bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();
          if (!mounted) return;

          if (accessibilityGranted) {
            ref.read(digitalDetoxServiceLocalProvider);
            LoggerService.instance.i('Jejum Digital: AppLock ativado para ${_selectedApps.length} apps');
          } else {
            setState(() => _isModuleActive = false);
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados', error: e);
    } finally {
      _isLoadingData = false;
    }
  }

  Future<void> _toggleModule() async {
    HapticFeedback.mediumImpact();

    if (_selectedApps.isEmpty) {
      _showSelectAppsFirstDialog();
      return;
    }

    if (_isModuleActive) {
      final shouldDeactivate = await showDialog<bool>(
        context: context,
        builder: (context) => DeactivateModuleDialog(
          nicheId: NicheId.digitalDetox,
        ),
      );

      if (shouldDeactivate == true && mounted) {
        try {
          final userId = ref.read(digitalDetoxCurrentUserIdProvider);
          await ref.read(digitalDetoxServiceLocalProvider).deactivateModule(userId);
          setState(() => _isModuleActive = false);
        } catch (e) {
          LoggerService.instance.e('Erro ao desativar módulo', error: e);
        }
      }
    } else {
      bool accessibilityGranted = await PermissionService.hasAccessibilityPermission();

      if (!accessibilityGranted) {
        _showPermissionRequiredDialog();
        return;
      }

      try {
        final userId = ref.read(digitalDetoxCurrentUserIdProvider);
        await ref.read(digitalDetoxServiceLocalProvider).activateModule(userId);

        for (final app in _selectedApps) {
          await ref.read(digitalDetoxServiceLocalProvider).addMonitoredApp(userId, app);
        }

        setState(() => _isModuleActive = true);
      } catch (e) {
        LoggerService.instance.e('Erro ao ativar módulo', error: e);
      }
    }
  }

  Future<void> _selectApps() async {
    await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) => SelectAppsScreen(
          args: SelectAppsScreenArgs(
            initiallySelected: _selectedApps,
            onSaved: (selectedApps) {
              setState(() {
                _selectedApps.clear();
                _selectedApps.addAll(selectedApps);
              });
            },
            nicheId: NicheId.digitalDetox,
          ),
        ),
      ),
    );
  }

  void _addCommonApps() {
    final commonApps = DigitalDetoxAppLockService.instance.getCommonSocialMediaApps();
    final newApps = commonApps.where((app) => !_selectedApps.contains(app)).toList();

    if (newApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os apps comuns já estão adicionados')),
      );
      return;
    }

    setState(() => _selectedApps.addAll(newApps));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newApps.length} apps adicionados')),
    );
  }

  void _showSelectAppsFirstDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione Apps Primeiro'),
        content: const Text('Você precisa selecionar pelo menos um app para monitorar antes de iniciar o Jejum Digital.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Necessária'),
        content: const Text('O Jejum Digital precisa de acesso à Acessibilidade para monitorar os apps.\n\nIsso permite que o app detecte quando você abre apps de redes sociais e mostre a tela de bloqueio.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openAccessibilitySettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(digitalDetoxCurrentUserIdProvider);
    final state = ref.watch(digitalDetoxNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jejum Digital'),
        leading: widget.heroTag != null
            ? Hero(
                tag: widget.heroTag!,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildMainTab(state),
          _buildHowItWorksTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_android),
            label: 'Jejum Digital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Como Funciona',
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(DigitalDetoxState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(int.parse((_niche.color ?? '#7C4DFF').replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _niche.icon ?? 'ðŸ“±',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _niche.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _niche.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apps Section
          Text(
            'Apps para Jejum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione os apps de redes sociais que você quer controlar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              onTap: _selectApps,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.apps,
                      color: _selectedApps.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedApps.isEmpty
                                ? 'Selecionar Apps'
                                : '${_selectedApps.length} apps selecionados',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if (_selectedApps.isNotEmpty)
                            Text(
                              'Toque para alterar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addCommonApps,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Apps Comuns (Instagram, TikTok, etc.)'),
          ),
          if (_selectedApps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedApps.map((app) {
                return Chip(
                  label: Text(
                    _getAppName(app),
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: _isModuleActive ? null : const Icon(Icons.close, size: 16),
                  onDeleted: _isModuleActive
                      ? null
                      : () => setState(() => _selectedApps.remove(app)),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _isModuleActive ? null : () {
                setState(() => _selectedApps.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lista de apps limpa')),
                );
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpar Lista'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Configurações de Horário
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Configurar Horários'),
              subtitle: const Text('Defina quando os apps podem ser usados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalDetoxTimeSettingsScreen(),
                  ),
                );
              },
            ),
          ),

          // Configurações de Limites
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Limite de Tempo Diário'),
              subtitle: const Text('Controle por quanto tempo pode usar os apps'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalDetoxLimitsScreen(),
                  ),
                );
              },
            ),
          ),

          // Configurações de Sessões
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Sessões Controladas'),
              subtitle: const Text('Use apps em sessões curtas com tempo de espera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelectAppsScreen(
                      args: SelectAppsScreenArgs(
                        initiallySelected: _selectedApps,
                        onSaved: (selectedApps) {
                          setState(() {
                            _selectedApps.clear();
                            _selectedApps.addAll(selectedApps);
                          });
                        },
                        nicheId: NicheId.digitalDetox,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Configurações de Horas Cumulativas
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: const Text('Horas Cumulativas'),
              subtitle: const Text('Acumule minutos não usados para usar depois'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalDetoxRolloverScreen(),
                  ),
                );
              },
            ),
          ),

          // Configurações de Limites Semanais
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Limites Semanais'),
              subtitle: const Text('Controle o tempo total de uso por semana'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalDetoxWeeklyScreen(),
                  ),
                );
              },
            ),
          ),

          // Quebras de Jejum (FASE 7)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.local_cafe),
              title: const Text('Quebras de Jejum'),
              subtitle: const Text('Use suas quebras de jejum para pular limites'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalDetoxFastingBreaksScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _toggleModule,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isModuleActive ? Colors.red : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isModuleActive ? 'Desativar Jejum Digital' : 'Iniciar Jejum Digital',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          if (_isModuleActive)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Módulo Ativo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          '${_selectedApps.length} apps sendo monitorados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (state.error != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => ref.read(digitalDetoxNotifierProvider(ref.read(digitalDetoxCurrentUserIdProvider)).notifier).clearError(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como funciona o Jejum Digital?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildStep(
            icon: Icons.select_all,
            title: '1. Selecione os Apps',
            description: 'Escolha os apps de redes sociais que você quer controlar (Instagram, TikTok, Facebook, etc.).',
          ),
          _buildStep(
            icon: Icons.play_circle_outline,
            title: '2. Inicie o Jejum',
            description: 'Ative o módulo para começar a monitorar. Você precisa conceder permissão de Acessibilidade.',
          ),
          _buildStep(
            icon: Icons.block,
            title: '3. Tela de Bloqueio',
            description: 'Quando tentar abrir um app monitorado, uma tela de bloqueio aparecerá.',
          ),
          _buildStep(
            icon: Icons.emoji_events,
            title: '4. Ganhe Recompensas',
            description: 'A cada 7 dias disciplinados, você ganha 1 "Quebra de Jejum"!',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dica: Você pode configurar horários permitidos, limites de tempo diários e muito mais nas próximas atualizações!',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppName(String packageName) {
    final appNames = {
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.twitter.android': 'Twitter',
      'com.pinterest': 'Pinterest',
      'com.linkedin.android': 'LinkedIn',
      'com.reddit.frontpage': 'Reddit',
      'com.whatsapp': 'WhatsApp',
      'com.discord': 'Discord',
      'com.telegram.messenger': 'Telegram',
      'com.google.android.youtube': 'YouTube',
      'com.twitch.android': 'Twitch',
    };
    return appNames[packageName] ?? packageName.split('.').last;
  }
}
