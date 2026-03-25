import 'package:flutter/material.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

class AccountOptionsDialog extends StatelessWidget {
  final AuthService authService;

  const AccountOptionsDialog({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppDialog(
      title: 'Minha Conta',
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Editar Perfil
          _buildOptionRow(
            icon: Icons.edit_rounded,
            iconColor: const Color(0xFF6366F1),
            title: 'Editar perfil',
            onTap: () {
              Navigator.pop(context);
              _showEditProfileDialog(context);
            },
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Sair da Conta
          _buildOptionRow(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Sair da conta',
            onTap: () {
              Navigator.pop(context);
              authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.authWrapper,
                (route) => false,
              );
            },
            isDark: isDark,
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.black12),
          const SizedBox(height: 12),

          // Deletar Conta
          _buildOptionRow(
            icon: Icons.delete_forever_rounded,
            iconColor: const Color(0xFFEF4444),
            title: 'Deletar conta',
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
            isDark: isDark,
            isDestructive: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Fechar',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => EditProfileDialog(
        authService: authService,
        initialName: authService.userProfile?['name'] ?? '',
        initialBio: authService.userProfile?['bio'] ?? '',
        initialShowEmail: authService.userProfile?['show_email'] ?? true,
        initialShowAvatar: authService.userProfile?['show_avatar'] ?? true,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteAccountDialog(authService: authService),
    );
  }
}
