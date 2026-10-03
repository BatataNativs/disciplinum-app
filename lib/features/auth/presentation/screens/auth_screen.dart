import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/core/auth/password_validation_service.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final int initialAuthMode;

  const AuthScreen({
    super.key,
    this.initialAuthMode = 0,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late int _authMode; // 0 = Login, 1 = Criar Conta

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = const [
    'Masculino',
    'Feminino',
    'Não-binário',
    'Outro',
    'Prefiro não informar',
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Estados de Biometria
  bool _isBiometricSupported = false;
  bool _biometricLoginEnabled = true;
  bool _hasBiometricAccount = false;

  static const _primaryCyan = Color(0xFF67CDF3);
  static const _primaryCyanDark = Color(0xFF0EB4B4);
  static const _bgDark = Color(0xFF0A0A0A);
  static const _cardDark = Color(0xFF141414);
  static const _borderDark = Color(0x28FFFFFF);
  static const _textMuted = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialAuthMode;
    _selectedGender = 'Prefiro não informar';
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bioService = ref.read(biometricAuthServiceProvider);
      final isAvailable = await bioService.isBiometricAvailable();
      final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      final bioPref = await prefs.getBool('biometric_login_enabled');
      final storedId = await prefs.getString('local_profile_user_id');
      final storedEmail = await prefs.getString('local_profile_email');
      final hasValidAccount = storedId != null && storedId.isNotEmpty && storedEmail != null && storedEmail.isNotEmpty;

      if (mounted) {
        setState(() {
          _isBiometricSupported = isAvailable;
          _biometricLoginEnabled = bioPref ?? isAvailable;
          _hasBiometricAccount = isAvailable && (bioPref == true) && hasValidAccount;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    HapticFeedback.lightImpact();
    final authService = ref.read(authServiceProvider.notifier);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_authMode == 1) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _showSnack('Digite seu nome ou apelido');
        return;
      }
    }

    if (email.isEmpty) {
      _showSnack('Digite seu e-mail');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showSnack('Digite um e-mail válido');
      return;
    }
    if (password.isEmpty || password.length < 8) {
      _showSnack('A senha deve ter pelo menos 8 caracteres');
      return;
    }

    if (_authMode == 1) {
      if (password != _confirmPasswordController.text) {
        _showSnack('As senhas não conferem');
        return;
      }

      final validation = PasswordValidationService.validate(password);
      if (!validation.isValid) {
        _showSnack(validation.errorMessage!, isError: true);
        return;
      }
    }

    bool success;
    if (_authMode == 0) {
      success = await authService.login(email, password);
      if (success && mounted) {
        if (_isBiometricSupported && _biometricLoginEnabled) {
          try {
            final bioService = ref.read(biometricAuthServiceProvider);
            await bioService.setBiometricLockEnabled(true);
            final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
            await prefs.setBool('biometric_login_enabled', true);
          } catch (_) {}
        }
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.authWrapper,
            (route) => false,
          );
        }
      }
    } else {
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Usuário';
      final gender = _selectedGender ?? 'Prefiro não informar';

      success = await authService.signup(email, password, name);
      if (success && mounted) {
        try {
          final prefs =
              ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
          await prefs.setString('local_profile_name', name);
          await prefs.setString('local_profile_gender', gender);
          await prefs.setBool('seen_onboarding', true);

          if (_isBiometricSupported && _biometricLoginEnabled) {
            final bioService = ref.read(biometricAuthServiceProvider);
            await bioService.setBiometricLockEnabled(true);
            await prefs.setBool('biometric_login_enabled', true);
          }

          await authService.updateProfile(name: name, gender: gender);
          await authService.refreshUser();
        } catch (_) {}

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.authWrapper,
            (route) => false,
          );
        }
      }
    }

    if (!success && mounted) {
      final msg = authService.errorMessage ?? 'Erro na autenticação.';
      _showSnack(msg, isError: true);
    }
  }

  void _loginWithBiometrics() async {
    HapticFeedback.lightImpact();
    final bioService = ref.read(biometricAuthServiceProvider);
    final authenticated = await bioService.authenticate(
      localizedReason: 'Confirme sua identidade para entrar no Disciplinum',
    );

    if (authenticated && mounted) {
      final authService = ref.read(authServiceProvider.notifier);
      final success = await authService.loginWithBiometrics();
      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.authWrapper,
          (route) => false,
        );
      } else if (mounted) {
        _showSnack('Não foi possível entrar com biometria. Use seu e-mail e senha.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (isError) {
      SnackBarHelper.showError(context, msg);
    } else {
      SnackBarHelper.showInfo(context, msg);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _borderDark),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: _primaryCyan, size: 24),
            SizedBox(width: 10),
            Text(
              'Redefinir Senha',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Como suas credenciais são armazenadas de forma segura e 100% local no seu aparelho (sem envio para servidores externos), você pode gerenciar sua senha diretamente nas Configurações do seu Perfil ou entrar com sua biometria.',
          style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: _primaryCyan),
            child: const Text('Entendi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Iluminação ambiental suave no topo
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primaryCyan.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Barra de navegação superior
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),

                // Conteúdo rolável
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),

                        // Ícone centralizado
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _cardDark,
                              border: Border.all(
                                color: _primaryCyan.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryCyan.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: _primaryCyan,
                              size: 28,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Título e Subtítulo dinâmicos
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            key: ValueKey<int>(_authMode),
                            children: [
                              Text(
                                _authMode == 0 ? 'Bem-vindo de volta' : 'Crie sua Conta',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _authMode == 0
                                    ? 'Acesse seus objetivos e continue no foco'
                                    : 'Preencha seus dados para começar',
                                style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Seletor Toggle Elegante (Entrar / Criar Conta)
                        Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _cardDark,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _borderDark),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _authMode = 0);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: _authMode == 0
                                          ? _primaryCyan.withValues(alpha: 0.18)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: _authMode == 0
                                          ? Border.all(
                                              color: _primaryCyan.withValues(alpha: 0.5),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Entrar',
                                        style: TextStyle(
                                          fontWeight: _authMode == 0
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                          color: _authMode == 0
                                              ? _primaryCyan
                                              : Colors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _authMode = 1);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: _authMode == 1
                                          ? _primaryCyan.withValues(alpha: 0.18)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: _authMode == 1
                                          ? Border.all(
                                              color: _primaryCyan.withValues(alpha: 0.5),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Criar Conta',
                                        style: TextStyle(
                                          fontWeight: _authMode == 1
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                          color: _authMode == 1
                                              ? _primaryCyan
                                              : Colors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botão de Entrada Rápida com Biometria (se disponível e habilitada)
                        if (_authMode == 0 && _isBiometricSupported && _hasBiometricAccount) ...[
                          OutlinedButton(
                            onPressed: authService.isLoading ? null : _loginWithBiometrics,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _primaryCyan.withValues(alpha: 0.1),
                              side: BorderSide(
                                color: _primaryCyan.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fingerprint_rounded,
                                  color: _primaryCyan,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Entrar com Biometria',
                                  style: TextStyle(
                                    color: _primaryCyan,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OU COM E-MAIL',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Campos Nome e Gênero (apenas no modo Cadastro)
                        if (_authMode == 1) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Campo Nome (compacto)
                              Expanded(
                                flex: 6,
                                child: _buildLightField(
                                  controller: _nameController,
                                  label: 'Nome / Apelido',
                                  hintText: 'Como quer ser chamado',
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Select Gênero
                              Expanded(
                                flex: 5,
                                child: _buildGenderDropdown(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Campo Email
                        _buildLightField(
                          controller: _emailController,
                          label: 'E-mail',
                          hintText: 'seu.email@exemplo.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 12),

                        // Campo Senha
                        _buildLightField(
                          controller: _passwordController,
                          label: 'Senha',
                          hintText: 'Mínimo 8 caracteres',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),

                        // Campo Confirmar Senha (apenas no modo Cadastro)
                        if (_authMode == 1) ...[
                          const SizedBox(height: 12),
                          _buildLightField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar Senha',
                            hintText: 'Repita a senha digitada',
                            icon: Icons.lock_reset_rounded,
                            obscureText: _obscureConfirmPassword,
                            onToggleObscure: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                          ),
                        ],

                        // Opção de Biometria para os próximos acessos
                        if (_isBiometricSupported) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _biometricLoginEnabled = !_biometricLoginEnabled);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _biometricLoginEnabled,
                                      activeColor: _primaryCyanDark,
                                      checkColor: Colors.white,
                                      side: const BorderSide(color: Colors.white54, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _biometricLoginEnabled = v);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.fingerprint_rounded,
                                    color: _primaryCyan,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Entrar com biometria nas próximas vezes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // "Esqueceu a senha?" (somente no modo Login)
                        if (_authMode == 0) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              style: TextButton.styleFrom(
                                foregroundColor: _textMuted,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 14),
                        ],

                        const SizedBox(height: 6),

                        // Botão Principal de Ação (Entrar / Criar Conta)
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryCyanDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: authService.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _authMode == 0 ? 'Entrar' : 'Criar Conta',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Campo com fundo branco e letras pretas garantidas de alto contraste
  Widget _buildLightField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: _primaryCyanDark,
            // Texto digitado sempre preto/escuro de alto contraste
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                icon,
                color: _primaryCyanDark,
                size: 19,
              ),
              suffixIcon: onToggleObscure != null
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Select (Dropdown) de Gênero com fundo branco e letras pretas
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            'Gênero',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wc_rounded,
                color: _primaryCyanDark,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _genderOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedGender = newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
