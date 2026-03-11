import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Clipboard

import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/shared/widgets/common/settings_banner_ad.dart'; // Import do Widget
// import 'package:disciplinum/shared/widgets/common/scroll_indicator_arrow.dart'; // Removido pois não é mais usado aqui
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/core/theme/theme_controller.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

import 'how_it_works_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'secret_menu_screen.dart'; // Importe a nova tela

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = NotificationService.soundEnabled;
  bool _isSyncing = false;

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

  Future<void> _sincronizarAgora() async {
    setState(() => _isSyncing = true);

    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isAuthenticated) {
      if (mounted) {
        setState(() => _isSyncing = false);
        EnhancedSnackBarHelper.showWarning(
            context, 'Faça login para sincronizar seus dados na nuvem.');
      }
      return;
    }

    final ok = await CloudSyncService.syncNow();

    if (!mounted) return;
    setState(() => _isSyncing = false);

    // Força atualização da UI do GamificationService via Provider se necessário
    // mas refreshAllDataFromCloud já chama notifyListeners()

    if (ok) {
      EnhancedSnackBarHelper.showSuccess(context, 'Dados sincronizados com sucesso!');
    } else {
      EnhancedSnackBarHelper.showError(context, 'Não foi possível sincronizar agora.');
    }
  }

  // OBS: _exportarDados foi removido daqui e movido para secret_menu_screen.dart
  // OBS: _mostrarMenuSobre foi removido
  // OBS: _buildMenuCard foi removido

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
    final gamification = Provider.of<GamificationService>(context);
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
                  value: gamification.notificationsPaused,
                  onChanged: (val) =>
                      setState(() => gamification.setNotificationsPaused(val)),
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
              sectionHeader('Sincronização'),
              settingContainer([
                ListTile(
                  dense: true,
                  leading: _isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.cloud_sync_outlined,
                          color: isDark ? Colors.white70 : Colors.black54),
                  title: Text(
                    'Sincronizar agora',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: const Text('Backup manual na nuvem'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _isSyncing ? null : _sincronizarAgora,
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
                  // Botão de Tema (Somente para Dev)
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () {
                      Provider.of<ThemeController>(context, listen: false)
                          .toggleTheme();
                      EnhancedSnackBarHelper.showInfo(context,
                          "Dev, lembre-se de remover esse botão antes de publicar o app!");
                    },
                    color: Colors.red.withValues(alpha: 0.2),
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
