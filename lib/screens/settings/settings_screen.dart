import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Clipboard

import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/widgets/settings_banner_ad.dart'; // Import do Widget
// import '../widgets/scroll_indicator_arrow.dart'; // Removido pois não é mais usado aqui
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/misc/system_stuff/theme_controller.dart';
import 'package:disciplinum/utils/snackbar_helper.dart';

import 'how_it_works_screen.dart';
import 'package:disciplinum/screens/opening/onboarding_screen.dart';
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
        SnackBarHelper.showError(context, 'Nenhum app de e-mail encontrado.');
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
        SnackBarHelper.showWarning(context, 'Faça login para sincronizar seus dados na nuvem.');
      }
      return;
    }

    final ok = await CloudSyncService.syncNow();

    if (!mounted) return;
    setState(() => _isSyncing = false);

    // Força atualização da UI do GamificationService via Provider se necessário
    // mas refreshAllDataFromCloud já chama notifyListeners()

    if (ok) {
      SnackBarHelper.showSuccess(context, 'Dados sincronizados com sucesso!');
    } else {
      SnackBarHelper.showError(context, 'Não foi possível sincronizar agora.');
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
                          SnackBarHelper.showSuccess(context, 'Pix copiado!');
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
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blueAccent : Colors.black,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        // cor de fundo
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
        backgroundColor:
            Colors.transparent, // Transparente para ver o gradiente
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Configurações'),
          backgroundColor: Colors.transparent, // AppBar Transparente
          elevation: 0,
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark, // Ícones da barra de status
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 0),
            children: [
              const SettingsBannerAd(),
              sectionHeader('Notificações'),
// 1. Switch: Pausar notificações
              SwitchListTile(
                // --- ESTILO PADRONIZADO ---
                activeThumbColor: isDark
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(
                        255, 0, 0, 0), // Cor da bolinha quando ativo
                activeTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black
                        .withValues(alpha: 0.2), // Cor do fundo quando ativo
                inactiveThumbColor: isDark
                    ? Colors.grey
                    : const Color.fromARGB(
                        255, 255, 255, 255), // Cor da bolinha quando inativo
                inactiveTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color.fromARGB(255, 0, 0, 0)
                        .withValues(alpha: 0.2), // Cor do fundo quando inativo
                // ---------------------------

                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text(
                  'Pausar notificações temporariamente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  'Não receber alertas mesmo com módulo ativado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
                secondary: Icon(
                  Icons.pause_circle_outline,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
                value: gamification.notificationsPaused,
                onChanged: (val) {
                  gamification.setNotificationsPaused(val);
                  setState(() {});
                },
              ),

              // 2. Switch: Sons de alerta
              SwitchListTile(
                // --- ESTILO PADRONIZADO (IDÊNTICO AO DE CIMA) ---
                activeThumbColor: isDark
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(
                        255, 0, 0, 0), // Cor da bolinha quando ativo
                activeTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black
                        .withValues(alpha: 0.4), // Cor do fundo quando ativo
                inactiveThumbColor: isDark
                    ? Colors.grey
                    : const Color.fromARGB(
                        255, 255, 255, 255), // Cor da bolinha quando inativo
                inactiveTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black
                        .withValues(alpha: 0.2), // Cor do fundo quando inativo
                // -----------------------------------------------

                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text(
                  'Sons de alerta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  _soundEnabled ? 'Som e vibração' : 'Apenas vibração',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
                secondary: Icon(
                  _soundEnabled ? Icons.volume_up : Icons.vibration,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
                value: _soundEnabled,
                onChanged: (val) {
                  setState(() => _soundEnabled = val);
                  NotificationService.setSoundEnabled(val);
                },
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Config. de estilo de notificações do Android',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Gerenciar acesso a notificações',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: Icon(Icons.settings_applications,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color.fromARGB(255, 0, 0, 0)),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color.fromARGB(255, 0, 0, 0)),
                onTap: NotificationService.openNotificationSettings,
              ),
              sectionHeader('Sincronização'),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Sincronizar agora',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Validar conexão com a nuvem',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: _isSyncing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.sync,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 0, 0, 0)),
                onTap: _isSyncing ? null : _sincronizarAgora,
              ),
              sectionHeader('Sobre o Projeto'),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Avalie o App',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Avalie-o na Google Play Store',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: const Icon(Icons.star_rate, color: Colors.amber),
                onTap: _avaliarApp,
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Enviar Feedback / Bug / Comentário / Sugestão',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Enviar um e-mail para o desenvolvedor',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: const Icon(
                  Icons.bug_report,
                  color: Color.fromARGB(255, 237, 65, 65),
                ),
                onTap: _enviarFeedback,
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Apoie o Desenvolvedor 💲',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Pagar um "café" (Pix)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: const Icon(
                  Icons.coffee,
                  color: Color.fromARGB(255, 119, 185, 205),
                ),
                onTap: () => _mostrarModalCafezinho(context),
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Como funciona',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text(
                    'Breve explicação sobre como funciona o aplicativo',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: const Icon(
                  Icons.help_outline_rounded,
                  color: Color.fromARGB(255, 78, 244, 66),
                ),
                onTap: _mostrarDialogoComoFunciona,
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Rever tela de apresentação',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color.fromARGB(255, 0, 0, 0))),
                subtitle: Text('Reveja a tela de apresentação do app',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color.fromARGB(255, 96, 96, 96))),
                leading: const Icon(
                  Icons.add_to_home_screen,
                  color: Color.fromARGB(255, 108, 179, 250),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const OnboardingScreen(isReviewMode: true)),
                ),
              ),

              // Rodapé com frase versão
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '“A disciplina é a mãe do sucesso.” – Ésquilo',
                          style: textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : const Color.fromARGB(255, 25, 25, 25),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 8),
                        // BOTÃO DEV (permite testar temas)
                        GestureDetector(
                          onTap: () {
                            Provider.of<ThemeController>(context, listen: false)
                                .toggleTheme();
                            SnackBarHelper.showInfo(context, "Dev, lembre-se de remover esse botão antes de publicar o app!");
                          },
                          child: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 23,
                            color: const Color.fromARGB(255, 236, 19, 19)
                                .withValues(alpha: 1.0),
                          ),
                        ),
                      ],
                    ),

                    // AQUI ESTÁ A MUDANÇA PRINCIPAL:
                    InkWell(
                      // Agora navega para a tela nova
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecretMenuScreen())),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Disciplinum v1.0.0',
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 40, 40, 40),
                              ),
                            ),
                            Icon(
                              Icons.menu_book_rounded,
                              size: 20,
                              color: isDark
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                      .withValues(alpha: 0.2)
                                  : const Color.fromARGB(255, 55, 55, 55)
                                      .withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 3),
      ),
    );
  }
}
