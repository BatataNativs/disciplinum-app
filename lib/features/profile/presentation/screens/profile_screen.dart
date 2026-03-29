import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/features/profile/presentation/widgets/account_options_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/store_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/theme_button.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_action_button.dart';
import 'package:disciplinum/features/app_lock/presentation/widgets/app_lock_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  IapService? _iapService;
  Timer? _errorTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Configura o feedback visual para as compras nesta tela
      _iapService = ref.read(iapServiceProvider.notifier);
      _iapService!.onPurchaseResult = (productId, success) {
        if (!mounted) return;
        
        if (success) {
          // Cancela o timeout apenas se for sucesso
          _errorTimeout?.cancel();
          _errorTimeout = null;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🛒 Compra realizada com sucesso!')),
          );
        }
        // Se não for sucesso, NÃO cancela o timeout - deixa ele mostrar erro de conexão
      };
    });
  }

  @override
  void dispose() {
    // Cancela o timeout se existir
    _errorTimeout?.cancel();
    
    // Limpa o callback usando a referência salva, sem precisar do context
    if (_iapService != null && _iapService!.onPurchaseResult != null) {
      _iapService!.onPurchaseResult = null;
    }
    super.dispose();
  }

  void _showAccountOptions(BuildContext context, dynamic authService) {
    showDialog(
      context: context,
      builder: (ctx) => AccountOptionsDialog(authService: authService),
    );
  }

  void _showLojinhaDialog(BuildContext context, dynamic iap) {
    showDialog(
      context: context,
      builder: (ctx) => const StoreDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider.notifier);
    final iapState = ref.watch(iapServiceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent, // Scaffold Transparente
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.transparent, // AppBar Transparente
          elevation: 0,
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark, // Ícones da barra de status
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // --- NOVO LAYOUT: AVATAR (ESQ) + BOTÕES (DIR) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COLUNA ESQUERDA: AVATAR
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                const ProfileAvatarSection(),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // COLUNA DIREITA: BOTÕES DE AÇÃO
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ESPAÇAMENTO PARA ALINHAR COM ALTURA DA FOTO DE PERFIL
                                const SizedBox(height: 38),

                                // BOTÃO DE TEMA
                                const ThemeButton(),
                                const SizedBox(height: 8),

                                // MINHA CONTA
                                ProfileActionButton(
                                  label: 'Minha conta',
                                  icon: Icons.person_outline,
                                  onPressed: () => _showAccountOptions(context, authService),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 8),

                                // LOJA DO APP
                                ProfileActionButton(
                                  label: 'Loja do app',
                                  icon: Icons.storefront,
                                  onPressed: () => _showLojinhaDialog(context, iapState),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 8),

                                // BOTÃO DE TESTE DO APP LOCK
                                AppLockButton(),
                                
                                // TEMA DO APP
                                ThemeButton(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // SEÇÃO DE INFORMAÇÕES DO PERFIL
                      const ProfileInfoSection(),

                      if (!authService.isAuthenticated) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Faça login para salvar seu progresso!',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.orangeAccent
                                  : const Color.fromARGB(255, 189, 114, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRouter.login),
                          child: const Text('Fazer Login / Criar Conta'),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // --- BOTÃO MEU PROGRESSO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color.fromARGB(255, 78, 77, 77)
                                    .withValues(alpha: 0.7)
                                : const Color.fromARGB(255, 24, 24, 24)
                                    .withValues(alpha: 0.7),
                            foregroundColor: isDark
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.myProgress);
                          },
                          icon: const Icon(Icons.bar_chart_rounded, size: 28),
                          label: const Text(
                            'CONQUISTAS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 1),
      ),
    );
  }
}
