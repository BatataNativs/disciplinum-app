import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Clipboard

import 'package:disciplinum/shared/widgets/common/settings_banner_ad.dart'; 
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

import 'how_it_works_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/app_lock/presentation/screens/app_lock_screen.dart';
import 'secret_menu_screen.dart'; // Importe a nova tela

/// Provider para estado de pausa de notificações
final notificationsPausedProvider = StateNotifierProvider<NotificationsPausedNotifier, bool>((ref) {
  final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
  return NotificationsPausedNotifier(prefs);
});

/// Notifier para gerenciar estado de pausa de notificações
class NotificationsPausedNotifier extends StateNotifier<bool> {
  final ObjectBoxPreferencesRepository _prefs;
  static const String _key = 'notifications_paused';

  NotificationsPausedNotifier(this._prefs) : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    final paused = await _prefs.getBool(_key) ?? false;
    state = paused;
  }

  Future<void> setPaused(bool paused) async {
    state = paused;
    await _prefs.setBool(_key, paused);
    
    // Cancelar ou reagendar notificações baseado no estado
    if (paused) {
      await NotificationService.cancelAll();
    }
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEnabled = NotificationService.soundEnabled;

  @override
  void initState() {
    super.initState();
  }

  // --- AÇÕES DE CONFIGURAÇÃO ---

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _enviarFeedback() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'disciplinum.app@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Feedback Disciplinum',
      }),
    );

    try {
      await AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: emailLaunchUri.toString(),
      ).launch();
    } catch (e) {
      if (mounted) {
        EnhancedSnackBarHelper.showError(context, 'Nenhum app de e-mail encontrado.');
      }
    }
  }

  void _avaliarApp() async {
    if (kIsWeb || !Platform.isAndroid) return;
    const intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'market://details?id=com.disciplinum.app',
    );
    try {
      await intent.launch();
    } catch (e) {
      const webIntent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data:
            'https://play.google.com/store/apps/details?id=com.disciplinum.app',
      );
      await webIntent.launch();
    }
  }

  void _testarTelaLock(BuildContext context) {
    EnhancedSnackBarHelper.showInfo(
        context, "Dev: Remover botão de teste antes de publicar!");

    final testEvent = AppLockEvent(
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      appIconBytes: null,
      nicheId: NicheId.focus,
      alertMessage:
          '⏳ Atenção aos objetivos. Mantenha o foco e a disciplina para alcançar seu objetivo!',
      timestamp: DateTime.now(),
      onExitApp: () => Navigator.of(context).pop(),
      onOpenApp: () => Navigator.of(context).pop(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppLockScreen(lockEvent: testEvent),
      ),
    );
  }

  void _mostrarDialogoComoFunciona() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HowItWorksScreen()),
    );
  }

  void _mostrarModalCafezinho(BuildContext context) {
    const String chavePix = 'f3b7c116-1d53-4a51-a6a2-5de1f36e688e';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Apoie o Projeto ☕',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF1F2937), // cor do título do modal
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'O Disciplinum é um app independente.\nSe ele te ajuda, considere pagar um "café"!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copie a chave Pix (chave aleatória) abaixo\npara fazer uma doação pelo seu app bancário:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.amberAccent
                        : const Color.fromARGB(255, 43, 33, 188),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.indigo.withValues(alpha: 0.3)
                        : Colors.blue.withValues(
                            alpha: 0.1), // cor de fundo da caixa do pix
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chavePix,
                          style: TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            color: isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF4F46E5)),
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: chavePix),
                          );
                          Navigator.pop(ctx);
                          EnhancedSnackBarHelper.showSuccess(context, 'Pix copiado!');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar provider local para estado de notificações
    final notificationsPaused = ref.watch(notificationsPausedProvider);
    final notificationsNotifier = ref.read(notificationsPausedProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white54 : Colors.black54,
            letterSpacing: 1.1,
          ),
        ),
      );
    }

    Widget settingContainer(List<Widget> children) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.black : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(children: children),
      );
    }

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
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Configurações'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 120),
            children: [
              const SettingsBannerAd(),
              sectionHeader('Notificações'),
              settingContainer([
                SwitchListTile(
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
                  dense: true,
                  title: Text(
                    'Pausar notificações',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: const Text('Silenciar alertas temporariamente'),
                  secondary: Icon(Icons.notifications_paused_outlined,
                      color: isDark ? Colors.white70 : Colors.black54),
                  value: notificationsPaused,
                  onChanged: (val) async {
                    await notificationsNotifier.setPaused(val);
                    if (context.mounted) {
                      EnhancedSnackBarHelper.showInfo(
                        context,
                        val ? 'Notificações pausadas' : 'Notificações ativadas',
                      );
                    }
                  },
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.black : Colors.grey[100],
                    indent: 56),
                SwitchListTile(
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
                  dense: true,
                  title: Text(
                    'Sons de alerta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(_soundEnabled ? 'Som e vibração' : 'Mudo'),
                  secondary: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.vibration,
                      color: isDark ? Colors.white70 : Colors.black54),
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() => _soundEnabled = val);
                    NotificationService.setSoundEnabled(val);
                  },
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.black : Colors.grey[300],
                    indent: 56),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.settings_suggest_outlined,
                      color: isDark ? Colors.white70 : Colors.black54),
                  title: Text(
                    'Configurações do Android',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: const Text('Gerenciar permissões do sistema'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: NotificationService.openNotificationSettings,
                ),
              ]),
              sectionHeader('Suporte e Feedback'),
              settingContainer([
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.star_outline, color: Colors.amber),
                  title: Text(
                    'Avalie o App',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: _avaliarApp,
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.black : Colors.grey[100],
                    indent: 56),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.mail_outline, color: Colors.blue),
                  title: Text(
                    'Enviar Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: _enviarFeedback,
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.black : Colors.grey[100],
                    indent: 56),
                ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.coffee_outlined, color: Colors.brown),
                  title: Text(
                    'Apoie o Desenvolvedor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () => _mostrarModalCafezinho(context),
                ),
              ]),
              sectionHeader('Sobre'),
              settingContainer([
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.info_outline, color: Colors.green),
                  title: Text(
                    'Como funciona',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: _mostrarDialogoComoFunciona,
                ),
                Divider(
                    height: 1,
                    color: isDark ? Colors.black : Colors.grey[100],
                    indent: 56),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.replay_outlined,
                      color: Colors.orange),
                  title: Text(
                    'Rever tela de apresentação',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const OnboardingScreen(isReviewMode: true)),
                  ),
                ),
              ]),
              const SizedBox(height: 32),
              Column(
                children: [
                  Text(
                    '“A disciplina é a mãe do sucesso.” – Ésquilo',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SecretMenuScreen())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            'Disciplinum v1.0.0',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.menu_book_rounded,
                            size: 18,
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botões de Dev (remover antes de publicar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão de Tema (Somente para Dev)
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          ref.read(themeControllerProvider.notifier).toggleTheme();
                          EnhancedSnackBarHelper.showInfo(context,
                              "Dev: Remover botão de tema antes de publicar!");
                        },
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 16),
                      // Botão Testar Tela Lock (Somente para Dev)
                      IconButton(
                        icon: const Icon(Icons.shield),
                        onPressed: () => _testarTelaLock(context),
                        color: Colors.orange.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 3),
      ),
    );
  }
}
