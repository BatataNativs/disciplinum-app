import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/screens/schedule_screen.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/widgets/niche_details/niche_header.dart';
import 'package:disciplinum/widgets/niche_details/niche_info_section.dart';
import 'package:disciplinum/widgets/niche_details/niche_content_schedule.dart';

class DietSettingsScreen extends StatefulWidget {
  const DietSettingsScreen({super.key});

  @override
  State<DietSettingsScreen> createState() => _DietSettingsScreenState();
}

class _DietSettingsScreenState extends State<DietSettingsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.diet);
  final List<TimeOfDay> _times = [];
  bool _gamificationRunning = false;
  bool _loadingData = true;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadAllPersistentData();
  }

  // --- HARDCODED TEXTS FOR DIET ---
  String _getModuleHintText() {
    return 'Este módulo te ajuda a organizar seus horários de refeição e envia alertas '
        'para que você não saia da dieta. '
        'Ajuste os horários conforme sua rotina de refeições para manter consistência.'
        '\n\nATENÇÃO: Este módulo vai te notificar 30 min antes do horário definido, '
        'pra você ter tempo de preparar/aquecer a refeição.';
  }

  Future<void> _loadAllPersistentData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      final nId = _niche.id;
      final userTimes =
          await CloudSyncService.loadUserNicheTimes(nicheId: nId.id);
      final status = await CloudSyncService.loadModuleStatus(nId);

      final times = userTimes
          .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
          .toList();

      if (mounted) {
        setState(() {
          _times.clear();
          _times.addAll(times);
          _gamificationRunning = status?.isActive ?? false;
          _loadingData = false;
        });

        if (_gamificationRunning) {
          final gamification =
              Provider.of<GamificationService>(context, listen: false);
          gamification.scheduleByModule[nId] = List.from(_times);

          final granted = await NotificationService.requestPermission();
          if (granted == true) {
            gamification.startMonitoringApps(
              nicheId: nId,
              horarios: _times,
            );
          } else {
            setState(() => _gamificationRunning = false);
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    } finally {
      _isLoadingData = false;
    }
  }

  void _removeSchedule(TimeOfDay time) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _times.remove(time);
    });

    await CloudSyncService.removeUserNicheTime(
      nicheId: _niche.id.id,
      hour: time.hour,
      minute: time.minute,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Horário removido: ${_formatTime(time)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _openSchedule() async {
    HapticFeedback.selectionClick();
    if (_niche.maxSlots == null) return;

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          args: ScheduleScreenArgs(
            maxSlots: _niche.maxSlots!,
            initialTimes: List.from(_times),
            onChanged: (times) async {
              setState(() {
                _times
                  ..clear()
                  ..addAll(times);
              });

              await CloudSyncService.removeAllTimesForNiche(
                nicheId: _niche.id.id,
              );
              for (var t in times) {
                await CloudSyncService.addUserNicheTime(
                  nicheId: _niche.id.id,
                  hour: t.hour,
                  minute: t.minute,
                );
              }
            },
            nicheId: _niche.id.id,
          ),
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _ativarNichoMonitoramento() async {
    HapticFeedback.mediumImpact();

    // Diet module is mostly notification based (schedule), but logic check permission too
    // For consistency we check notification perms.

    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    gamification.startMonitoringApps(
      nicheId: _niche.id,
      horarios: _times,
    );

    final granted = await NotificationService.requestPermission();

    if (!mounted) return;

    if (granted == true) {
      _startGamificationCycle();
    } else {
      _showNotificationSettingsDialog();
    }
  }

  void _startGamificationCycle() {
    HapticFeedback.heavyImpact();
    setState(() {
      _gamificationRunning = true;
    });
    CloudSyncService.saveModuleStatus(
      nicheId: _niche.id,
      isActive: true,
    );
    Provider.of<GamificationService>(context, listen: false)
        .startModuleCycle(nicheId: _niche.id);
  }

  Future<void> _showNotificationSettingsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão necessária'),
        content: const Text(
          'Para receber notificações do Disciplinum, habilite as notificações do app nas configurações do Android.',
        ),
        actions: [
          TextButton(
            child: const Text('Abrir configurações'),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              NotificationService.openNotificationSettings();
            },
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _desativarNichoMonitoramento() {
    HapticFeedback.heavyImpact();
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.stopMonitoringApps();

    _resetMedalsForModule(
      notificationTitle: 'Progresso reiniciado neste módulo',
      notificationBody:
          'Você desativou o módulo ${_niche.name}. Se reativar no futuro, '
          'seu progresso começará novamente do zero.',
    );

    setState(() => _gamificationRunning = false);
    CloudSyncService.saveModuleStatus(
      nicheId: _niche.id,
      isActive: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Módulo desativado — Você não receberá mais alertas'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetMedalsForModule({
    String? notificationTitle,
    String? notificationBody,
    bool sendNotification = true,
  }) {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    gamification.resetMedals(
      _niche.id,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      sendNotification: sendNotification,
    );
  }

  Widget _buildMedalProgress(
      {required Color primaryColor, required Color secondaryColor}) {
    final gamification = Provider.of<GamificationService>(context);
    final nicheId = _niche.id;
    final diasConsecutivos =
        gamification.diasConsecutivosByModule[nicheId] ?? 0;

    String text;
    Color color = primaryColor;

    if (diasConsecutivos >= 10) {
      text = 'Parabéns! Você alcançou a medalha de Diamante (Nível Máximo)! 💎';
      color = Colors.blueAccent;
    } else if (diasConsecutivos >= 7) {
      final faltam = 10 - diasConsecutivos;
      text =
          'Sua medalha atual é de Ouro 🥇. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Diamante 💎.';
    } else if (diasConsecutivos >= 5) {
      final faltam = 7 - diasConsecutivos;
      text =
          'Sua medalha atual é de Prata 🥈. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Ouro 🥇.';
    } else if (diasConsecutivos >= 3) {
      final faltam = 5 - diasConsecutivos;
      text =
          'Sua medalha atual é de Bronze 🥉. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Prata 🥈.';
    } else {
      final faltam = 3 - diasConsecutivos;
      text =
          'Sem medalhas ainda. Faltam $faltam ${faltam == 1 ? 'dia' : 'dias'} para a medalha de Bronze 🥉.';
    }

    return NeonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.military_tech_outlined, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                'Como anda seu progresso:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (diasConsecutivos % 3) / 3,
              backgroundColor: secondaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gamification = Provider.of<GamificationService>(context);
    final medalAsset = gamification.currentMedalAsset(_niche.id);
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_niche.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 60, width: double.infinity, color: Colors.white),
                const SizedBox(height: 16),
                Container(height: 20, width: 200, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                    height: 40, width: double.infinity, color: Colors.white),
                const SizedBox(height: 16),
                Container(
                    height: 50, width: double.infinity, color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    // Specific content for Diet (Schedule)
    Widget content = NicheContentSchedule(
      times: _times,
      onAdd: _openSchedule,
      onRemove: _removeSchedule,
    );

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Manter Dieta',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NicheHeader(niche: _niche),
                      const SizedBox(height: 24),
                      _buildNotificationMessageSection(context),
                      const SizedBox(height: 12),
                      content,
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: GlowingButton(
                            text: _gamificationRunning
                                ? 'Desativar Monitoramento'
                                : 'Ativar Monitoramento',
                            color: _gamificationRunning
                                ? Colors.redAccent
                                : const Color.fromARGB(255, 16, 165, 53),
                            onPressed: _gamificationRunning
                                ? _desativarNichoMonitoramento
                                : _ativarNichoMonitoramento,
                            borderRadius: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_gamificationRunning) ...[
                        _buildMedalProgress(
                          primaryColor:
                              isDark ? Colors.white70 : const Color(0xFF6366F1),
                          secondaryColor: isDark
                              ? Colors.white70.withValues(alpha: 0.8)
                              : const Color(0xFF6366F1).withValues(alpha: 0.6),
                        ),
                        if (medalAsset != null)
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Conquista Atual',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                Image.asset(medalAsset, height: 80),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                      NicheInfoSection(hintText: _getModuleHintText()),
                      const SizedBox(height: 16),
                      const SizedBox(height: 40),
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

  Widget _buildNotificationMessageSection(BuildContext context) {
    final iap = Provider.of<IapService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final currentMsg = getModuleMessage(_niche.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717), // Anthracite
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mensagem de Alerta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              if (!iap.isCustomNotifUnlocked)
                const Icon(Icons.lock_outline, size: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentMsg,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (iap.isCustomNotifUnlocked) {
                  _openEditMessageDialog(context, gamification);
                } else {
                  _showPremiumFeatureDialog();
                }
              },
              label: Text(
                iap.isCustomNotifUnlocked
                    ? 'Editar Mensagem'
                    : 'Personalizar 🔓',
                style: const TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumFeatureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recurso pago 💰'),
        content: const Text(
          'A personalização de mensagens é um recurso pago. '
          '\nDeseja conhecer nossa lojinha?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                builder: (_) => const Lojinha(),
              );
            },
            child: const Text('Ir para Lojinha'),
          ),
        ],
      ),
    );
  }

  void _openEditMessageDialog(
      BuildContext context, GamificationService gamification) {
    final controller = TextEditingController(text: getModuleMessage(_niche.id));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Mensagem'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Digite sua mensagem personalizada...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await gamification.setCustomMessage(_niche.id, controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem atualizada!')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
