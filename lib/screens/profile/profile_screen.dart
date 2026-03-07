import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/services/auth/avatar_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/app_router.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/widgets/profile/edit_profile_dialog.dart';
import 'package:disciplinum/utils/enhanced_snackbar_helper.dart';

import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/misc/system_stuff/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  IapService? _iapService;
  bool _loadingAvatar = false;
  Timer? _errorTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _nameController.text = authService.userProfile?['name'] ?? '';
      _bioController.text = authService.userProfile?['bio'] ?? '';

      // Configura o feedback visual para as compras nesta tela
      _iapService = Provider.of<IapService>(context, listen: false);
      _iapService!.onPurchaseResult = (success) {
        print('Callback onPurchaseResult chamado! success: $success');
        if (!mounted) return;
        
        if (success) {
          // Cancela o timeout apenas se for sucesso
          print('Cancelando timeout (sucesso)...');
          _errorTimeout?.cancel();
          _errorTimeout = null;
          
          EnhancedSnackBarHelper.showSuccess(
              context, '🛒 Compra realizada com sucesso!');
        }
        // Se não for sucesso, NÃO cancela o timeout - deixa ele mostrar erro de conexão
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

      if (ok) {
        EnhancedSnackBarHelper.showSuccess(context, 'Foto de perfil atualizada!');
      } else {
        EnhancedSnackBarHelper.showError(context, 'Erro ao enviar foto de perfil!');
      }
    }
  }

  @override
  void dispose() {
    // Cancela o timeout se existir
    _errorTimeout?.cancel();
    
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
      EnhancedSnackBarHelper.showWarning(
          context, 'Faça login para acessar esta opção.');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: const Alignment(0, -0.6),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color.fromARGB(255, 30, 30, 40),
                        const Color.fromARGB(255, 15, 15, 20),
                      ]
                    : [
                        Colors.white,
                        const Color.fromARGB(255, 230, 235, 240),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(164, 255, 255, 255)
                    : Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Minha Conta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Editar Perfil
                _buildPremiumOptionRow(
                  icon: Icons.edit_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Editar perfil',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditProfileDialog(context, authService);
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 12),

                // Sair da Conta
                _buildPremiumOptionRow(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Sair da conta',
                  onTap: () {
                    Navigator.pop(ctx);
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
                _buildPremiumOptionRow(
                  icon: Icons.delete_forever_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Deletar conta',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteAccountDialog(context, authService);
                  },
                  isDark: isDark,
                  isDestructive: true,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Fechar',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumOptionRow({
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

  // Removido _buildPremiumOption não utilizado

  void _showDeleteAccountDialog(BuildContext context, AuthService authService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? const Color(0xFF1F2937) : Colors.white,
                isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de aviso
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEF4444),
                      const Color(0xFFDC2626),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 20),

              // Título
              Text(
                'Deletar Conta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Mensagem
              Text(
                'Tem certeza que deseja deletar sua conta?\nEsta ação é irreversível e todos os seus dados serão perdidos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await authService.deleteAccount();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRouter.authWrapper,
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Deletar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoLoja() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1F2937),
                      const Color(0xFF111827),
                    ]
                  : [
                      const Color(0xFFFFFFFF),
                      const Color(0xFFF9FAFB),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone e título
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 12),
                    Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text('Recurso Pago',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Conteúdo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.dark_mode_outlined,
                      size: 48,
                      color: isDark
                          ? const Color.fromARGB(255, 29, 29, 29)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Experiência visual elegante e confortável aos olhos com o tema escuro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, 
                              color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 4),
                          Text('Compra única',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Depois',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF6B7280),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        final iapService =
                            Provider.of<IapService>(context, listen: false);
                        
                        // Mostra snackbar de início da compra
                        EnhancedSnackBarHelper.showInfo(context, 'Iniciando compra de Dark Mode...');
                        
                        // Cria timeout para mostrar erro se não receber resposta
                        print('Criando timeout de 3 segundos...');
                        _errorTimeout = Timer(const Duration(seconds: 3), () {
                          print('Timeout disparado! Mostrando erro de conexão...');
                          if (mounted) {
                            EnhancedSnackBarHelper.showError(context, 'Erro ao processar compra. Verifique sua conexão ou tente novamente.');
                            _errorTimeout = null;
                          }
                        });
                        
                        // Executa a compra
                        iapService.buyByProductId(IapService.productIdDarkMode);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Comprar agora',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeOptionsDialog(BuildContext context, IapService iap) {
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    final isDark = themeController.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: const Alignment(0, -0.2),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color.fromARGB(255, 30, 30, 40),
                        const Color.fromARGB(255, 15, 15, 20),
                      ]
                    : [
                        Colors.white,
                        const Color.fromARGB(255, 230, 235, 240),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(164, 255, 255, 255)
                    : Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  Row(
                    children: [
                      Icon(Icons.palette_rounded,
                          color: isDark ? Colors.white : Colors.black87),
                      const SizedBox(width: 12),
                      Text(
                        'Temas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Opção Claro
                  _buildThemeOption(
                    title: 'Tema Claro',
                    isSelected: !isDark,
                    onTap: () {
                      if (isDark) {
                        themeController.toggleTheme();
                      }
                      Navigator.pop(ctx);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Opção Escuro
                  _buildThemeOption(
                    title: 'Tema Escuro',
                    isSelected: isDark,
                    onTap: () {
                      if (!isDark) {
                        if (iap.isDarkModeUnlocked) {
                          themeController.toggleTheme();
                        } else {
                          Navigator.pop(ctx);
                          _mostrarDialogoLoja();
                        }
                      } else {
                        Navigator.pop(ctx);
                      }
                    },
                    isDark: isDark,
                    showLock: !iap.isDarkModeUnlocked,
                  ),
                  const SizedBox(height: 12),

                  // Opção Rosa
                  _buildThemeOption(
                    title: 'Tema Rosa',
                    isSelected: false,
                    isComingSoon: true,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Opção Halloween
                  _buildThemeOption(
                    title: 'Tema Halloween',
                    isSelected: false,
                    isComingSoon: true,
                    onTap: () {},
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Botão Fechar
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Fechar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    bool isComingSoon = false,
    bool showLock = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white24 : Colors.black12)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white54 : Colors.black38)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button imitado
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isComingSoon
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isDark ? Colors.white : Colors.black87),
                        fontStyle:
                            isComingSoon ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '(Disponível em breve)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showLock && !isComingSoon)
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: isDark ? Colors.white54 : Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  void _showLojinhaDialog(BuildContext context, IapService iap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: const Alignment(0,
              -0.6), // Movendo ainda mais pra cima para não conflitar com Snackbars
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark // degradê de fundo da lojinha
                    ? [
                        const Color.fromARGB(255, 30, 30, 40),
                        const Color.fromARGB(255, 15, 15, 20),
                      ]
                    : [
                        const Color.fromARGB(255, 255, 255, 255),
                        const Color.fromARGB(255, 248, 250, 252),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(164, 255, 255, 255)
                    : Colors.black,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),

                  // Título premium
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          color: const Color(0xFF6366F1),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loja do App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Descrição
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Desbloqueie recursos pagos e apoie o desenvolvimento do aplicativo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Conteúdo da Lojinha
                  const Flexible(child: Lojinha()),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
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
              const double avatarRadius = 70.0; // tamanho da foto de perfil

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
                                // ESPAÇAMENTO PARA ALINHAR COM ALTURA DA FOTO DE PERFIL
                                const SizedBox(height: 38),

                                // BOTÃO DE TEMA
                                _buildThemeButton(context, iap, isDark),
                                const SizedBox(height: 8),

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

                      const SizedBox(height: 20),

                      // SEÇÃO DE INFORMAÇÕES DO PERFIL
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF6366F1).withValues(alpha: 0.1),
                                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  ]
                                : [
                                    const Color(0xFF4F46E5).withValues(alpha: 0.05),
                                    const Color(0xFF7C3AED).withValues(alpha: 0.05),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                                : const Color(0xFF4F46E5).withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // NOME DO USUÁRIO
                            Center(
                              child: Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: isDark
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF1F2937),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            // EMAIL
                            if (authService.isAuthenticated &&
                                (authService.userProfile?['show_email'] ?? true))
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                        : const Color(0xFF4F46E5).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    authService.userProfile?['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF818CF8)
                                          : const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ),

                            // BIO
                            if (authService.userProfile?['bio'] != null &&
                                authService.userProfile!['bio'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.02),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    authService.userProfile!['bio'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      height: 1.4,
                                      color: isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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

  Widget _buildThemeButton(
    BuildContext context,
    IapService iap,
    bool isDark,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Mais borderRadius que os outros
        color: Colors.black, // Cor preta como solicitado
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Text('🎨', style: TextStyle(fontSize: 20)),
        label: const Text(
          'Temas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _showThemeOptionsDialog(context, iap),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isDestructive
            ? LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.8),
                  Colors.red.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF6366F1).withValues(alpha: 0.8),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                      ]
                    : [
                        const Color(0xFF4F46E5),
                        const Color(0xFF7C3AED),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (isDestructive ? Colors.red : const Color(0xFF6366F1))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
