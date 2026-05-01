import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:disciplinum/features/profile/presentation/widgets/theme_button.dart';
import 'package:disciplinum/features/profile/presentation/widgets/account_options_dialog.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';

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

  void _showAccountOptions(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AccountOptionsDialog(authService: authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F0F1A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ]
              : [
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 10, 60, 131),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
          stops: const [0.0, 0.5, 1.0],
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
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),

                      // --- AVATAR COM GLASSMORPHISM ---
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.05),
                                  ]
                                : [
                                    Colors.white,
                                    Colors.white,
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.3),
                              blurRadius: 35,
                              spreadRadius: 6,
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : const Color.fromARGB(255, 38, 38, 38).withValues(alpha: 0.9),
                            width: 2,
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
                                  colors: [Color(0xFF1F2937), Color(0xFF374151)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.person_outline, size: 22),
                                label: const Text(
                                  'Minha conta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                onPressed: () => _showAccountOptions(context, authService),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
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

                      const SizedBox(height: 12),

                      // --- BOTÃO CONQUISTAS ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF6366F1).withValues(alpha: 0.9),
                                    const Color(0xFF8B5CF6).withValues(alpha: 0.9),
                                    const Color(0xFFA855F7).withValues(alpha: 0.9),
                                  ]
                                : [
                                    const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                                    const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                                    const Color(0xFFFFFFFF).withValues(alpha: 0.75),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.7),
                            width: 2,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: isDark ? Colors.white : const Color(0xFF1F2937),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.myProgress);
                          },
                          icon: const Icon(Icons.bar_chart_rounded, size: 26),
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
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 1),
      ),
    );
  }
}
