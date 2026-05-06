import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Clipboard

import 'package:disciplinum/core/theme/app_theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

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
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'O Disciplinum é um app independente.\nSe ele te ajuda, considere pagar um "café"!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copie a chave Pix (chave aleatória) abaixo\npara fazer uma doação pelo seu app bancário:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            color: colorScheme.primary),
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
    final colorScheme = Theme.of(context).colorScheme;

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1.1,
          ),
        ),
      );
    }

    Widget settingContainer(List<Widget> children) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
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
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
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
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
              if (ref.watch(themeControllerProvider) == AppTheme.pink) ...[
                // == FLORES GRANDES (60-80) ==
                Positioned(
                  top: 50,
                  right: -15,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Icon(
                      Icons.local_florist,
                      size: 72,
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top: 280,
                  left: -25,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 68,
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  right: -15,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Icon(
                      Icons.spa,
                      size: 76,
                      color: colorScheme.primary.withValues(alpha: 0.13),
                    ),
                  ),
                ),
                // == FLORES MÉDIAS (30-45) ==
                Positioned(
                  top: 70,
                  left: 60,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.eco,
                      size: 42,
                      color: colorScheme.secondary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                Positioned(
                  top: 240,
                  right: 70,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Icon(
                      Icons.local_florist,
                      size: 38,
                      color: colorScheme.primary.withValues(alpha: 0.20),
                    ),
                  ),
                ),
                Positioned(
                  top: 500,
                  left: 40,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Icon(
                      Icons.spa,
                      size: 36,
                      color: colorScheme.secondary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 320,
                  right: 55,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 40,
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // == FLORES PEQUENAS (originais) ==
                // Canto superior esquerdo
                Positioned(
                  top: 100,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Icon(
                      Icons.local_florist,
                      size: 26,
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Positioned(
                  top: 160,
                  left: 70,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 20,
                      color: colorScheme.secondary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                // Canto superior direito
                Positioned(
                  top: 120,
                  right: 40,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: Icon(
                      Icons.spa,
                      size: 24,
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // Meio esquerdo
                Positioned(
                  top: 400,
                  left: 20,
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 22,
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                // Meio direito
                Positioned(
                  top: 500,
                  right: 30,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.local_florist,
                      size: 24,
                      color: colorScheme.secondary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // Inferior esquerdo
                Positioned(
                  bottom: 300,
                  left: 50,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Icon(
                      Icons.eco,
                      size: 18,
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                // Inferior direito
                Positioned(
                  bottom: 250,
                  right: 40,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Icon(
                      Icons.spa,
                      size: 22,
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Centro espalhado
                Positioned(
                  top: 700,
                  left: 80,
                  child: Transform.rotate(
                    angle: 0.9,
                    child: Icon(
                      Icons.eco,
                      size: 16,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
              ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 120),
                children: [
                  const SettingsBannerAd(),
              sectionHeader('Notificações'),
              settingContainer([
                SwitchListTile(
                  activeThumbColor: Colors.white,
                  activeTrackColor: colorScheme.primary,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.1),
                  dense: true,
                  title: Text(
                    'Pausar notificações',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: const Text('Silenciar alertas temporariamente'),
                  secondary: Icon(Icons.notifications_paused_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.7)),
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
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    indent: 56),
                SwitchListTile(
                  activeThumbColor: Colors.white,
                  activeTrackColor: colorScheme.primary,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.1),
                  dense: true,
                  title: Text(
                    'Sons de alerta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(_soundEnabled ? 'Som e vibração' : 'Mudo'),
                  secondary: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.vibration,
                      color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() => _soundEnabled = val);
                    NotificationService.setSoundEnabled(val);
                  },
                ),
                Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    indent: 56),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.settings_suggest_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  title: Text(
                    'Configurações do Android',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: _avaliarApp,
                ),
                Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    indent: 56),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.mail_outline, color: Colors.blue),
                  title: Text(
                    'Enviar Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: _enviarFeedback,
                ),
                Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
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
                      color: colorScheme.onSurface,
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: _mostrarDialogoComoFunciona,
                ),
                Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
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
                      color: colorScheme.onSurface,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.menu_book_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botões de Dev (remover antes de publicar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Tema Claro (Somente para Dev)
                      Tooltip(
                        message: 'DEV: Testar tema Claro (remover antes de publicar)',
                        child: IconButton(
                          icon: const Icon(Icons.wb_sunny, color: Colors.orange),
                          onPressed: () async {
                            final controller = ref.read(themeControllerProvider.notifier);
                            await controller.setTheme(AppTheme.light);
                            if (context.mounted) {
                              EnhancedSnackBarHelper.showInfo(context,
                                  "Dev: Tema Claro ativado (remover antes de publicar!)");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Tema Dark (Somente para Dev)
                      Tooltip(
                        message: 'DEV: Testar tema Dark (remover antes de publicar)',
                        child: IconButton(
                          icon: const Icon(Icons.dark_mode, color: Colors.black),
                          onPressed: () async {
                            final controller = ref.read(themeControllerProvider.notifier);
                            await controller.setTheme(AppTheme.dark);
                            if (context.mounted) {
                              EnhancedSnackBarHelper.showInfo(context,
                                  "Dev: Tema Dark ativado (remover antes de publicar!)");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Tema Rosa (Somente para Dev)
                      Tooltip(
                        message: 'DEV: Testar tema Rosa (remover antes de publicar)',
                        child: IconButton(
                          icon: const Icon(Icons.palette, color: Colors.pink),
                          onPressed: () async {
                            final controller = ref.read(themeControllerProvider.notifier);
                            await controller.setTheme(AppTheme.pink);
                            if (context.mounted) {
                              EnhancedSnackBarHelper.showInfo(context,
                                  "Dev: Tema Rosa ativado (remover antes de publicar!)");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Tema Halloween (Somente para Dev)
                      Tooltip(
                        message: 'DEV: Testar tema Halloween (remover antes de publicar)',
                        child: IconButton(
                          icon: const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                          onPressed: () async {
                            final controller = ref.read(themeControllerProvider.notifier);
                            await controller.setTheme(AppTheme.halloween);
                            if (context.mounted) {
                              EnhancedSnackBarHelper.showInfo(context,
                                  "Dev: Tema Halloween ativado (remover antes de publicar!)");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão Testar Tela Lock (Somente para Dev)
                      Tooltip(
                        message: 'DEV: Testar App Lock (remover antes de publicar)',
                        child: IconButton(
                          icon: const Icon(Icons.shield),
                          onPressed: () => _testarTelaLock(context),
                          color: Colors.orange.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
