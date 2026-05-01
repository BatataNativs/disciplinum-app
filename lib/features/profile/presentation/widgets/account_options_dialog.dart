import 'package:flutter/material.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:disciplinum/features/settings/presentation/screens/sync_backup_screen.dart';
import 'package:disciplinum/app/router/app_router.dart';

class AccountOptionsDialog extends StatefulWidget {
  final AuthService authService;

  const AccountOptionsDialog({
    super.key,
    required this.authService,
  });

  @override
  State<AccountOptionsDialog> createState() => _AccountOptionsDialogState();
}

class _AccountOptionsDialogState extends State<AccountOptionsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A2E).withValues(alpha: 0.98),
                            const Color(0xFF16213E).withValues(alpha: 0.98),
                          ]
                        : [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.98),
                            const Color(0xFFF0F7FF).withValues(alpha: 0.98),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFF0A3D83).withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.7)
                          : const Color(0xFF0A3D83).withValues(alpha: 0.2),
                      blurRadius: 60,
                      offset: const Offset(0, 30),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HEADER MODERNO COM AVATAR
                      _buildModernHeader(isDark),

                      // GRID DE AÇÕES PRINCIPAIS
                      _buildActionGrid(isDark),

                      // SEÇÃO DE PERIGO (DELETAR)
                      _buildDangerZone(isDark),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF6366F1).withValues(alpha: 0.15),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                ]
              : [
                  const Color(0xFF0A3D83).withValues(alpha: 0.08),
                  const Color(0xFF3B82F6).withValues(alpha: 0.02),
                ],
        ),
      ),
      child: Row(
        children: [
          // AVATAR/ÍCONE PRINCIPAL
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        const Color(0xFFA855F7),
                      ]
                    : [
                        const Color(0xFF0A3D83),
                        const Color(0xFF1E5AA8),
                        const Color(0xFF3B82F6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                      : const Color(0xFF0A3D83).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minha Conta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gerencie perfil e configurações',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF0A3D83).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // BOTÃO FECHAR ELEGANTE
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          const Color(0xFF0A3D83).withValues(alpha: 0.1),
                          const Color(0xFF0A3D83).withValues(alpha: 0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFF0A3D83).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF0A3D83),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // CARD PRINCIPAL - EDITAR PERFIL (MAIOR)
          _buildMainActionCard(
            isDark: isDark,
            icon: Icons.edit_rounded,
            title: 'Editar Perfil',
            subtitle: 'Nome, bio e visibilidade',
            colors: isDark
                ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                : [const Color(0xFF0A3D83), const Color(0xFF3B82F6)],
            onTap: () {
              Navigator.pop(context);
              _showEditProfileDialog(context);
            },
          ),

          const SizedBox(height: 16),

          // ROW COM DOIS BOTÕES MENORES
          Row(
            children: [
              Expanded(
                child: _buildSmallActionCard(
                  isDark: isDark,
                  icon: Icons.logout_rounded,
                  title: 'Sair',
                  subtitle: 'Fazer logout',
                  colors: isDark
                      ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]
                      : [const Color(0xFF0A3D83), const Color(0xFF1E5AA8)],
                  onTap: () {
                    Navigator.pop(context);
                    widget.authService.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.authWrapper,
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallActionCard(
                  isDark: isDark,
                  icon: Icons.cloud_sync_outlined,
                  title: 'Sincronizar',
                  subtitle: 'Backup na nuvem',
                  colors: isDark
                      ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                      : [const Color(0xFF059669), const Color(0xFF10B981)],
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SyncBackupScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.02),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.first.withValues(alpha: isDark ? 0.3 : 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: isDark ? 0.2 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : colors.first.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors.first.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.02),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.85),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.85),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.first.withValues(alpha: isDark ? 0.25 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: isDark ? 0.15 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : colors.first.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL ZONA DE PERIGO
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'ZONA DE PERIGO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // CARD DE DELETAR CONTA
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFFEF4444).withValues(alpha: 0.15),
                          const Color(0xFFEF4444).withValues(alpha: 0.05),
                        ]
                      : [
                          const Color(0xFFFEE2E2).withValues(alpha: 0.8),
                          const Color(0xFFFEF2F2).withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.4 : 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deletar Conta',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Esta ação não pode ser desfeita',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFFCA5A5).withValues(alpha: 0.7)
                                : const Color(0xFFDC2626).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => EditProfileDialog(
        authService: widget.authService,
        initialName: widget.authService.userProfile?['name'] ?? '',
        initialBio: widget.authService.userProfile?['bio'] ?? '',
        initialShowEmail: widget.authService.userProfile?['show_email'] ?? true,
        initialShowAvatar: widget.authService.userProfile?['show_avatar'] ?? true,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteAccountDialog(authService: widget.authService),
    );
  }
}
