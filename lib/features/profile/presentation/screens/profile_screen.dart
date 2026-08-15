import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/theme_button.dart';
import 'package:disciplinum/features/profile/presentation/widgets/account_options_dialog.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/core/theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAccountOptions(BuildContext context, AuthController authService) {
    showDialog(
      context: context,
      builder: (ctx) => AccountOptionsDialog(authService: authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;
    final isHalloweenTheme = currentTheme == AppTheme.halloween;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Perfil',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: colorScheme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
              if (isPinkTheme) ...[
                // == FLORES GRANDES (60-80) ==
                Positioned(
                  top: 40,
                  right: -15,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Icon(
                      Icons.local_florist,
                      size: 78,
                      color: colorScheme.primary.withValues(alpha: 0.13),
                    ),
                  ),
                ),
                Positioned(
                  top: 250,
                  left: -30,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 72,
                      color: colorScheme.secondary.withValues(alpha: 0.11),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: -20,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Icon(
                      Icons.spa,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                // == FLORES MÉDIAS (35-50) ==
                Positioned(
                  top: 60,
                  left: 80,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.eco,
                      size: 48,
                      color: colorScheme.secondary.withValues(alpha: 0.17),
                    ),
                  ),
                ),
                Positioned(
                  top: 220,
                  right: 60,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Icon(
                      Icons.local_florist,
                      size: 44,
                      color: colorScheme.primary.withValues(alpha: 0.19),
                    ),
                  ),
                ),
                Positioned(
                  top: 450,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Icon(
                      Icons.spa,
                      size: 42,
                      color: colorScheme.secondary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 350,
                  right: 45,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 46,
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                // == FLORES PEQUENAS (originais) ==
                // Canto superior esquerdo
                Positioned(
                  top: 80,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Icon(
                      Icons.local_florist,
                      size: 32,
                      color: colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 60,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 24,
                      color: colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Canto superior direito
                Positioned(
                  top: 100,
                  right: 30,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: Icon(
                      Icons.spa,
                      size: 28,
                      color: colorScheme.primary.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  right: 70,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Icon(
                      Icons.eco,
                      size: 22,
                      color: colorScheme.secondary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // Meio esquerdo
                Positioned(
                  top: 320,
                  left: 15,
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 26,
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Meio direito
                Positioned(
                  top: 280,
                  right: 25,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.local_florist,
                      size: 30,
                      color: colorScheme.secondary.withValues(alpha: 0.24),
                    ),
                  ),
                ),
                Positioned(
                  top: 400,
                  right: 50,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Icon(
                      Icons.spa,
                      size: 20,
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Inferior esquerdo
                Positioned(
                  bottom: 200,
                  left: 40,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Icon(
                      Icons.eco,
                      size: 24,
                      color: colorScheme.secondary.withValues(alpha: 0.19),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 280,
                  left: 10,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 18,
                      color: colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                // Inferior direito
                Positioned(
                  bottom: 150,
                  right: 20,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Icon(
                      Icons.local_florist,
                      size: 28,
                      color: colorScheme.primary.withValues(alpha: 0.21),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 240,
                  right: 80,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.spa,
                      size: 22,
                      color: colorScheme.secondary.withValues(alpha: 0.17),
                    ),
                  ),
                ),
                // Centro espalhado
                Positioned(
                  top: 520,
                  left: 80,
                  child: Transform.rotate(
                    angle: 0.9,
                    child: Icon(
                      Icons.eco,
                      size: 20,
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top: 600,
                  right: 40,
                  child: Transform.rotate(
                    angle: -0.7,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 26,
                      color: colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Mais flores adicionais
                Positioned(
                  top: 220,
                  left: 30,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: Icon(
                      Icons.spa,
                      size: 18,
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  top: 480,
                  left: 50,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Icon(
                      Icons.local_florist,
                      size: 22,
                      color: colorScheme.secondary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top: 720,
                  left: 25,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 20,
                      color: colorScheme.primary.withValues(alpha: 0.13),
                    ),
                  ),
                ),
                Positioned(
                  top: 350,
                  right: 60,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Icon(
                      Icons.eco,
                      size: 24,
                      color: colorScheme.secondary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned(
                  top: 680,
                  right: 25,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Icon(
                      Icons.local_florist,
                      size: 20,
                      color: colorScheme.primary.withValues(alpha: 0.11),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 70,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Icon(
                      Icons.spa,
                      size: 22,
                      color: colorScheme.secondary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: 60,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Icons.eco,
                      size: 18,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 850,
                  left: 45,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Icon(
                      Icons.filter_vintage,
                      size: 16,
                      color: colorScheme.secondary.withValues(alpha: 0.09),
                    ),
                  ),
                ),
                Positioned(
                  top: 920,
                  right: 35,
                  child: Transform.rotate(
                    angle: -0.8,
                    child: Icon(
                      Icons.local_florist,
                      size: 20,
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ],
              // --- DECORAÇÕES DE HALLOWEEN 🎃 ---
              if (isHalloweenTheme) ...[
                // == DECORAÇÕES GRANDES (60-80) ==
                Positioned(
                  top: 30,
                  right: -20,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 82,
                        color: colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 230,
                  left: -35,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('👻', style: TextStyle(fontSize: 76))),
                  ),
                ),
                Positioned(
                  bottom: 90,
                  right: -25,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🦇', style: TextStyle(fontSize: 84))),
                  ),
                ),
                // == DECORAÇÕES MÉDIAS (35-50) ==
                Positioned(
                  top: 50,
                  left: 85,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🕸️', style: TextStyle(fontSize: 52))),
                  ),
                ),
                Positioned(
                  top: 210,
                  right: 65,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: const Opacity(
                        opacity: 0.18,
                        child: Text('🎃', style: TextStyle(fontSize: 48))),
                  ),
                ),
                Positioned(
                  top: 440,
                  left: 35,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('💀', style: TextStyle(fontSize: 46))),
                  ),
                ),
                Positioned(
                  bottom: 340,
                  right: 50,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('👻', style: TextStyle(fontSize: 50))),
                  ),
                ),
                // == DECORAÇÕES PEQUENAS (originais) ==
                // Canto superior esquerdo
                Positioned(
                  top: 70,
                  left: 25,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 36,
                        color: colorScheme.primary.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 130,
                  left: 65,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: const Opacity(
                        opacity: 0.18,
                        child: Text('🦇', style: TextStyle(fontSize: 28))),
                  ),
                ),
                // Canto superior direito
                Positioned(
                  top: 90,
                  right: 35,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: const Opacity(
                        opacity: 0.20,
                        child: Text('🕸️', style: TextStyle(fontSize: 32))),
                  ),
                ),
                Positioned(
                  top: 170,
                  right: 75,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: const Opacity(
                        opacity: 0.18,
                        child: Text('🎃', style: TextStyle(fontSize: 26))),
                  ),
                ),
                // Meio esquerdo
                Positioned(
                  top: 310,
                  left: 20,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: const Opacity(
                        opacity: 0.17,
                        child: Text('💀', style: TextStyle(fontSize: 30))),
                  ),
                ),
                // Meio direito
                Positioned(
                  top: 270,
                  right: 30,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 34,
                        color: colorScheme.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 390,
                  right: 55,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🦇', style: TextStyle(fontSize: 24))),
                  ),
                ),
                // Inferior esquerdo
                Positioned(
                  bottom: 190,
                  left: 45,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: const Opacity(
                        opacity: 0.18,
                        child: Text('🎃', style: TextStyle(fontSize: 28))),
                  ),
                ),
                Positioned(
                  bottom: 270,
                  left: 15,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('👻', style: TextStyle(fontSize: 22))),
                  ),
                ),
                // Inferior direito
                Positioned(
                  bottom: 140,
                  right: 25,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 32,
                        color: colorScheme.primary.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 230,
                  right: 85,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🕸️', style: TextStyle(fontSize: 26))),
                  ),
                ),
                // Centro espalhado
                Positioned(
                  top: 510,
                  left: 85,
                  child: Transform.rotate(
                    angle: 0.8,
                    child: const Opacity(
                        opacity: 0.14,
                        child: Text('💀', style: TextStyle(fontSize: 24))),
                  ),
                ),
                Positioned(
                  top: 590,
                  right: 45,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 30,
                        color: colorScheme.secondary.withValues(alpha: 0.21),
                      ),
                    ),
                  ),
                ),
                // Mais decorações adicionais
                Positioned(
                  top: 210,
                  left: 35,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: const Opacity(
                        opacity: 0.13,
                        child: Text('🦇', style: TextStyle(fontSize: 22))),
                  ),
                ),
                Positioned(
                  top: 470,
                  left: 55,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🎃', style: TextStyle(fontSize: 26))),
                  ),
                ),
                Positioned(
                  top: 710,
                  left: 30,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: const Opacity(
                        opacity: 0.13,
                        child: Text('💀', style: TextStyle(fontSize: 24))),
                  ),
                ),
                Positioned(
                  top: 340,
                  right: 65,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 28,
                        color: colorScheme.secondary.withValues(alpha: 0.17),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 670,
                  right: 30,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: const Opacity(
                        opacity: 0.12,
                        child: Text('👻', style: TextStyle(fontSize: 24))),
                  ),
                ),
                Positioned(
                  bottom: 110,
                  left: 75,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: const Opacity(
                        opacity: 0.15,
                        child: Text('🦇', style: TextStyle(fontSize: 26))),
                  ),
                ),
                Positioned(
                  bottom: 70,
                  right: 65,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: const Opacity(
                        opacity: 0.11,
                        child: Text('🎃', style: TextStyle(fontSize: 22))),
                  ),
                ),
                Positioned(
                  top: 840,
                  left: 50,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: const Opacity(
                        opacity: 0.10,
                        child: Text('💀', style: TextStyle(fontSize: 20))),
                  ),
                ),
                Positioned(
                  top: 910,
                  right: 40,
                  child: Transform.rotate(
                    angle: -0.7,
                    child: Text(
                      '🎃',
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.primary.withValues(alpha: 0.13),
                      ),
                    ),
                  ),
                ),
              ],

              // --- CONTEÚDO PRINCIPAL ---
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          // --- AVATAR COM GLASSMORPHISM ---
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.onSurface.withValues(alpha: 0.1),
                                  colorScheme.onSurface.withValues(alpha: 0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colorScheme.shadow.withValues(alpha: 0.9),
                                  blurRadius: 35,
                                  spreadRadius: 3,
                                ),
                              ],
                              border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const ProfileAvatarSection(),
                          ),

                          const SizedBox(height: 24),

                          // --- SEÇÃO DE INFORMAÇÕES DO PERFIL ---
                          const ProfileInfoSection(),

                          const SizedBox(height: 18),

                          // --- BOTÕES DE AÇÃO EM LINHA ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // MINHA CONTA
                              Expanded(
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1F2937),
                                        Color(0xFF374151)
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.person_outline,
                                        size: 22),
                                    label: const Text(
                                      'Minha conta',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    onPressed: () => _showAccountOptions(
                                        context, authService),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // TEMA
                              const Expanded(child: ThemeButton()),
                            ],
                          ),

                          const SizedBox(height: 24),

                          if (!authService.isAuthenticated) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'Faça login para salvar seu progresso!',
                                style: TextStyle(
                                  color: colorScheme.tertiary,
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

                          const SizedBox(height: 12),

                          // --- BOTÃO CONQUISTAS ---
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.9),
                                  colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 36),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRouter.myProgress);
                              },
                              icon:
                                  const Icon(Icons.bar_chart_rounded, size: 26),
                              label: const Text(
                                'CONQUISTAS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
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
            ],
          ),
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 1),
      ),
    );
  }
}
