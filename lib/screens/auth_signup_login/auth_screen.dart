import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/utils/snackbar_helper.dart';

class AuthScreen extends StatefulWidget {
  final int initialAuthMode;

  const AuthScreen({super.key, this.initialAuthMode = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _authMode;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialAuthMode;
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
    HapticFeedback.vibrate();
    final authService = Provider.of<AuthService>(context, listen: false);

    if (_authMode == 1 && _nameController.text.isEmpty) {
      _showSnack('Digite seu nome');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnack('Digite seu email');
      return;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      _showSnack('Senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (_authMode == 1 &&
        _passwordController.text != _confirmPasswordController.text) {
      _showSnack('As senhas não conferem');
      return;
    }

    bool success;
    if (_authMode == 0) {
      success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (success && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      }
    } else {
      success = await authService.signup(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (success && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _buildSuccessDialog(ctx),
        );
        setState(() {
          _authMode = 0;
        });
      }
    }

    if (!success && mounted) {
      final msg = authService.errorMessage ?? 'Erro na autenticação.';
      if (_authMode == 1 &&
          (msg.contains('Verifique') || msg.contains('ativar'))) {
        await showDialog(
          context: context,
          builder: (ctx) => _buildSuccessDialog(ctx),
        );
      } else {
        _showSnack(msg, isError: true);
      }
    }
  }

  void _googleAuth() async {
    HapticFeedback.vibrate();
    final authService = Provider.of<AuthService>(context, listen: false);
    final started = await authService.loginWithGoogle();

    if (!started && mounted) {
      _showSnack(authService.errorMessage ?? 'Erro ao iniciar Google Login',
          isError: true);
      return;
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (isError) {
      SnackBarHelper.showError(context, msg);
    } else {
      SnackBarHelper.showInfo(context, msg);
    }
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Conta Criada! 🚀'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 60, color: Colors.green),
          SizedBox(height: 16),
          Text('Verifique seu e-mail para confirmar o cadastro.',
              textAlign: TextAlign.center),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.email),
            label: const Text('Abrir App de E-mail'),
            onPressed: () async {
              try {
                final AndroidIntent intent = AndroidIntent(
                  action: 'android.intent.action.MAIN',
                  category: 'android.intent.category.APP_EMAIL',
                  flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                );
                await intent.launch();
              } catch (e) {
                debugPrint('Erro intent email: $e');
              }
            },
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ok, ir para Login'),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailResetController =
        TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redefinir Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite seu e-mail para receber o link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailResetController,
              decoration: const InputDecoration(
                  labelText: 'E-mail', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              final success = await authService
                  .resetPassword(emailResetController.text.trim());
              if (mounted) {
                _showSnack(
                    success
                        ? 'E-mail enviado!'
                        : (authService.errorMessage ?? 'Erro ao enviar.'),
                    isError: !success);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = const Color.fromARGB(255, 14, 180, 180);
    final Color toggleContainerColor =
        isDark ? Colors.white : const Color.fromARGB(255, 255, 255, 255);

    final Color activeToggleBg =
        isDark ? Colors.grey.shade200 : const Color.fromARGB(255, 30, 30, 30);
    final Color activeToggleText = isDark ? Colors.black : Colors.white;
    final Color inactiveToggleText =
        isDark ? Colors.black54 : const Color.fromARGB(255, 58, 58, 58);

    if (authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.home, (route) => route.isFirst);
      });
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 16, 16, 16)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: toggleContainerColor,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          alignment: _authMode == 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: activeToggleBg,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _authMode = 0),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _authMode == 0
                                          ? activeToggleText
                                          : inactiveToggleText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _authMode = 1),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text(
                                    'Criar conta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _authMode == 1
                                          ? activeToggleText
                                          : inactiveToggleText,
                                    ),
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
                const SizedBox(height: 32),
                Text(
                  _authMode == 0 ? 'Faça Login' : 'Crie sua Conta',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_authMode == 1) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 13),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                if (_authMode == 1) ...[
                  const SizedBox(height: 13),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ],
                if (_authMode == 0) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      child: Text('Esqueceu a senha?',
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color.fromARGB(255, 39, 38, 38))),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 13),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: authService.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _authMode == 0 ? 'Entrar' : 'Criar Conta',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: const Color.fromARGB(255, 255, 255, 255)
                                .withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Login com',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 13),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: const Color.fromARGB(255, 255, 255, 255)
                                .withValues(alpha: 0.3))),
                  ],
                ),
                const SizedBox(height: 30),
                _buildGoogleButton(isDark, authService.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16), // campos de preenchimento
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[500],
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isDark, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _googleAuth,
      child: Image.asset(
        isDark
            ? 'assets/Auth/android_dark_sq_na@2x.png'
            : 'assets/Auth/android_light_sq_na@2x.png',
        width: 60,
        height: 60,
      ),
    );
  }
}
