import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/features/auth/data/datasources/avatar_service.dart';
import 'package:disciplinum/core/di/providers.dart';

import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class ProfileAvatarSection extends ConsumerStatefulWidget {
  const ProfileAvatarSection({super.key});

  @override
  ConsumerState<ProfileAvatarSection> createState() =>
      _ProfileAvatarSectionState();
}

class _ProfileAvatarSectionState extends ConsumerState<ProfileAvatarSection> {
  bool _loadingAvatar = false;

  Future<void> _changeAvatar() async {
    if (_loadingAvatar) return;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    final file = await AvatarService.pickAvatar();

    if (file != null) {
      setState(() => _loadingAvatar = true);
      final ok = await AvatarService.uploadAvatar(userId: userId, file: file);

      if (!mounted) return;
      await ref.read(authServiceProvider.notifier).loadUserProfile();

      if (!mounted) return;
      setState(() {
        _loadingAvatar = false;
      });

      if (ok) {
        EnhancedSnackBarHelper.showSuccess(
            context, 'Foto de perfil atualizada!');
      } else {
        EnhancedSnackBarHelper.showError(
            context, 'Erro ao enviar foto de perfil!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    final theme = Theme.of(context);
    final userName = authService.isAuthenticated
        ? (authService.userProfile?['name'] ?? 'Usuário')
        : 'Usuário Anônimo';

    // Usa userProfile diretamente (persiste na tabela users)
    final showAvatarConfig = authService.userProfile?['show_avatar'] ?? true;
    final String? currentAvatarUrl = authService.userProfile?['avatar_url'];
    const double avatarRadius = 70.0;

    return Stack(
      children: [
        GestureDetector(
          onTap: (authService.isAuthenticated && !_loadingAvatar)
              ? _changeAvatar
              : null,
          child: _loadingAvatar
              ? const CircleAvatar(
                  radius: avatarRadius,
                  child: CircularProgressIndicator(),
                )
              : Builder(builder: (context) {
                  if (!showAvatarConfig) {
                    return CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.person, size: 40),
                    );
                  }

                  return CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    backgroundImage: (currentAvatarUrl != null &&
                            currentAvatarUrl.isNotEmpty)
                        ? NetworkImage(currentAvatarUrl)
                        : null,
                    child:
                        (currentAvatarUrl == null || currentAvatarUrl.isEmpty)
                            ? Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                  );
                }),
        ),
        if (authService.isAuthenticated && !_loadingAvatar)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.photo_camera,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
