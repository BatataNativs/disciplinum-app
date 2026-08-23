import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';
import 'package:disciplinum/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:disciplinum/features/settings/presentation/screens/sync_backup_screen.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/theme/app_theme.dart';

class AccountOptionsDialog extends ConsumerStatefulWidget {
  final AuthController authService;

  const AccountOptionsDialog({
    super.key,
    required this.authService,
  });

  @override
  ConsumerState<AccountOptionsDialog> createState() =>
      _AccountOptionsDialogState();
}

class _AccountOptionsDialogState extends ConsumerState<AccountOptionsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    final colorScheme = Theme.of(context).colorScheme;

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
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(colorScheme),
                    const Divider(height: 1),
                    _buildStandardActions(colorScheme),
                    const Divider(height: 1),
                    _buildDangerZone(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ref.watch(themeControllerProvider) == AppTheme.halloween
              ? FaIcon(FontAwesomeIcons.skull, size: 42)
              : const Icon(Icons.person_rounded, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minha Conta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gerencie perfil e configurações',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              color: colorScheme.onSurfaceVariant,
              splashRadius: 24,
              tooltip: 'Fechar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildListTile(
            icon: FontAwesomeIcons.filePen,
            title: 'Editar Perfil',
            subtitle: 'Nome, bio e visibilidade',
            iconColor: colorScheme.primary,
            iconBgColor: colorScheme.primaryContainer,
            onTap: () {
              Navigator.pop(context);
              _showEditProfileDialog(context);
            },
          ),
          _buildListTile(
            icon: FontAwesomeIcons.database,
            title: 'Backup e Sincronização',
            subtitle: 'Salvar local (JSON) ou na nuvem',
            iconColor: Colors.teal.shade700,
            iconBgColor: Colors.teal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncBackupScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            icon: FontAwesomeIcons.rightFromBracket,
            title: 'Sair',
            subtitle: 'Fazer logout',
            iconColor: Colors.orange.shade700,
            iconBgColor: Colors.orange.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              widget.authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.authWrapper,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 8, bottom: 4),
            child: Text(
              'ZONA DE PERIGO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colorScheme.error,
              ),
            ),
          ),
          _buildListTile(
            icon: FontAwesomeIcons.trash,
            title: 'Deletar Conta',
            subtitle: 'Esta ação não pode ser desfeita',
            iconColor: colorScheme.error,
            iconBgColor: colorScheme.errorContainer,
            textColor: colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required FaIconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryTextColor = textColor ?? colorScheme.onSurface;
    final secondaryTextColor = textColor?.withValues(alpha: 0.8) ?? colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              FaIcon(icon, color: iconColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final userProfile = widget.authService.userProfile;

    LoggerService.instance
        .d('🔐 AccountOptionsDialog - userProfile completo: $userProfile');
    LoggerService.instance.d(
        '🔐 AccountOptionsDialog - show_email: ${userProfile?['show_email']}, show_avatar: ${userProfile?['show_avatar']}');

    showDialog<bool>(
      context: context,
      builder: (ctx) => EditProfileDialog(
        authService: widget.authService,
        initialName: userProfile?['name'] ?? '',
        initialBio: userProfile?['bio'] ?? '',
        initialShowEmail: userProfile?['show_email'] ?? true,
        initialShowAvatar: userProfile?['show_avatar'] ?? true,
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