import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/services/auth/avatar_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/app_router.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/widgets/profile/edit_profile_dialog.dart';

import 'package:disciplinum/widgets/profile/lojinha.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  IapService? _iapService; // Armazena referência para o dispose seguro
  bool _loadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _nameController.text = authService.userProfile?['name'] ?? '';
      _bioController.text = authService.userProfile?['bio'] ?? '';

      // Configura o feedback visual para as compras nesta tela
      _iapService = Provider.of<IapService>(context, listen: false);
      _iapService!.onPurchaseResult = (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '🛒 Compra realizada com sucesso!'
                : '❌ Compra não concluída.'),
            backgroundColor: success ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      };
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context, listen: false);
    if (_nameController.text.isEmpty) {
      _nameController.text = authService.userProfile?['name'] ?? '';
    }
    if (_bioController.text.isEmpty) {
      _bioController.text = authService.userProfile?['bio'] ?? '';
    }
  }

  Future<void> _changeAvatar() async {
    if (_loadingAvatar) return;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    final file = await AvatarService.pickAvatar();

    if (file != null) {
      setState(() => _loadingAvatar = true);
      final ok = await AvatarService.uploadAvatar(userId: userId, file: file);

      if (!mounted) return;
      await Provider.of<AuthService>(context, listen: false).loadUserProfile();

      if (!mounted) return;
      setState(() {
        _loadingAvatar = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Foto de perfil atualizada!'
                : 'Erro ao enviar foto de perfil!',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Limpa o callback usando a referência salva, sem precisar do context
    if (_iapService != null && _iapService!.onPurchaseResult != null) {
      _iapService!.onPurchaseResult = null;
    }
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _showEditProfileDialog(
      BuildContext context, AuthService authService) async {
    final profile = authService.userProfile;

    // Aguarda o resultado do diálogo
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => EditProfileDialog(
        authService: authService,
        initialName: _nameController.text,
        initialBio: _bioController.text,
        initialShowEmail: profile?['show_email'] ?? true,
        initialShowAvatar: profile?['show_avatar'] ?? true,
      ),
    );

    // Se retornou true, significa que salvou com sucesso
    if (result == true && mounted) {
      // Atualiza os controladores locais para refletir a mudança imediata
      final updatedProfile = authService.userProfile;
      setState(() {
        _nameController.text = updatedProfile?['name'] ?? '';
        _bioController.text = updatedProfile?['bio'] ?? '';
      });
    }
  }

  void _showAccountOptions(BuildContext context, AuthService authService) {
    if (!authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para acessar esta opção.')),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Puxador visual (opcional)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                'Minha Conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Editar Perfil
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar perfil'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditProfileDialog(context, authService);
                },
              ),

              // Sair da Conta
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair da conta'),
                onTap: () {
                  Navigator.pop(ctx);
                  authService.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.authWrapper,
                    (route) => false,
                  );
                },
              ),

              const Divider(),

              // Deletar Conta
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Deletar conta',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteAccountDialog(context, authService);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar Conta'),
        content: const Text(
          'Tem certeza que deseja deletar sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final rootNavigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(ctx);

              dialogNavigator.pop();

              final success = await authService.deleteAccount();

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Conta deletada com sucesso')),
                );
                rootNavigator.pushNamedAndRemoveUntil(
                  AppRouter.authWrapper,
                  (route) => false,
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro: ${authService.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLojinhaDialog(BuildContext context, IapService iap) {
    showDialog(
      context: context,
      builder: (ctx) => const Lojinha(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final iap = context.watch<IapService>();
    final theme = Theme.of(context);

    final userName = authService.isAuthenticated
        ? (authService.userProfile?['name'] ?? 'Usuário')
        : 'Usuário Anônimo';

    final String? currentAvatarUrl = authService.userProfile?['avatar_url'];
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
              const double avatarRadius = 60.0;

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
                            flex: 4,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: (authService.isAuthenticated &&
                                              !_loadingAvatar)
                                          ? _changeAvatar
                                          : null,
                                      child: _loadingAvatar
                                          ? const CircleAvatar(
                                              radius: avatarRadius,
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : Builder(builder: (context) {
                                              final profile =
                                                  authService.userProfile;
                                              final bool showAvatarConfig =
                                                  profile?['show_avatar'] ??
                                                      true;

                                              if (!showAvatarConfig) {
                                                return CircleAvatar(
                                                  radius: avatarRadius,
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .primaryContainer,
                                                  foregroundColor: theme
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                  child: const Icon(
                                                      Icons.person,
                                                      size: 40),
                                                );
                                              }

                                              return CircleAvatar(
                                                radius: avatarRadius,
                                                backgroundColor: theme
                                                    .colorScheme
                                                    .primaryContainer,
                                                foregroundColor: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                backgroundImage:
                                                    (currentAvatarUrl != null &&
                                                            currentAvatarUrl
                                                                .isNotEmpty)
                                                        ? NetworkImage(
                                                            currentAvatarUrl,
                                                          )
                                                        : null,
                                                child: (currentAvatarUrl ==
                                                            null ||
                                                        currentAvatarUrl
                                                            .isEmpty)
                                                    ? Text(
                                                        userName.isNotEmpty
                                                            ? userName[0]
                                                                .toUpperCase()
                                                            : 'U',
                                                        style: const TextStyle(
                                                          fontSize: 32,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              );
                                            }),
                                    ),
                                    if (authService.isAuthenticated &&
                                        !_loadingAvatar)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  theme.scaffoldBackgroundColor,
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
                                ),
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
                                // ESPAÇAMENTO PARA MANTER POSIÇÃO VISUAL (Substituindo Edit e Logout)
                                const SizedBox(height: 88),

                                // MINHA CONTA
                                _buildProfileActionButton(
                                  context,
                                  label: 'Minha conta',
                                  icon: Icons.person_outline,
                                  onPressed: () =>
                                      _showAccountOptions(context, authService),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 8),

                                // LOJA DO APP
                                _buildProfileActionButton(
                                  context,
                                  label: 'Loja do app',
                                  icon: Icons.storefront,
                                  onPressed: () =>
                                      _showLojinhaDialog(context, iap),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // NOME E BIO
                      Center(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      // EMAIL
                      if (authService.isAuthenticated &&
                          (authService.userProfile?['show_email'] ?? true))
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Center(
                            child: Text(
                              authService.userProfile?['email'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color.fromARGB(255, 44, 45, 47),
                              ),
                            ),
                          ),
                        ),

                      if (authService.userProfile?['bio'] != null &&
                          authService.userProfile!['bio'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Center(
                            child: Text(
                              authService.userProfile!['bio'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color.fromARGB(255, 44, 45, 47),
                              ),
                            ),
                          ),
                        ),

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
                                ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                                : const Color(0xFF4F46E5)
                                    .withValues(alpha: 0.1),
                            foregroundColor: isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF4F46E5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF4F46E5),
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
                            'MEU PROGRESSO',
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

  Widget _buildProfileActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isDestructive = false,
    required bool isDark,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? (isDark
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.1))
              : (isDark
                  ? const Color(0xFF1E3A8A)
                  : const Color.fromARGB(255, 85, 87, 90)),
          foregroundColor: isDestructive
              ? Colors.red
              : (isDark
                  ? const Color(0xFFDBEAFE)
                  : const Color.fromARGB(255, 239, 240, 241)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
