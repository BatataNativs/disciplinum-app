import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/utils/enhanced_snackbar_helper.dart';

class EditProfileDialog extends StatefulWidget {
  final AuthService authService;
  final String initialName;
  final String initialBio;
  final bool initialShowEmail;
  final bool initialShowAvatar;

  const EditProfileDialog({
    super.key,
    required this.authService,
    required this.initialName,
    required this.initialBio,
    required this.initialShowEmail,
    required this.initialShowAvatar,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late bool _showEmail;
  late bool _showAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _showEmail = widget.initialShowEmail;
    _showAvatar = widget.initialShowAvatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<String?> _showBioDialog() async {
    final TextEditingController tempBioController =
        TextEditingController(text: _bioController.text);

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sua frase'),
        content: TextField(
          controller: tempBioController,
          maxLines: 3,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Escreva algo sobre você...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.grey),
              tooltip: 'Limpar texto',
              onPressed: () {
                tempBioController.clear();
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx, tempBioController.text);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    HapticFeedback.vibrate();
    setState(() => _isLoading = true);

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);

    final success = await widget.authService.updateProfile(
      name: _nameController.text,
      showEmail: _showEmail,
      showAvatar: _showAvatar,
      bio: _bioController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        EnhancedSnackBarHelper.showSuccess(context, 'Perfil atualizado com sucesso!');
        navigator.pop(true);
      } else {
        EnhancedSnackBarHelper.showError(
          context,
          widget.authService.errorMessage ?? 'Erro ao atualizar perfil',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: const Alignment(0, -0.2),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Icon(Icons.edit_note_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo de Nome
              const Text('NOME',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 2.0)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Como quer ser chamado?',
                  hintStyle:
                      TextStyle(color: subtitleColor.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.person_outline,
                      size: 20, color: subtitleColor),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Configurações
              const Text('VISIBILIDADE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 2.0)),
              const SizedBox(height: 8),
              _buildSwitchOption(
                title: 'Exibir e-mail',
                value: _showEmail,
                icon: Icons.alternate_email_rounded,
                onChanged: (val) => setState(() => _showEmail = val),
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildSwitchOption(
                title: 'Exibir minha foto',
                value: _showAvatar,
                icon: Icons.face_unlock_rounded,
                onChanged: (val) => setState(() => _showAvatar = val),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Frase
              const Text('FRASE DO PERFIL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 2.0)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final updatedBio = await _showBioDialog();
                  if (updatedBio != null) {
                    setState(() => _bioController.text = updatedBio);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.format_quote_rounded,
                          size: 20, color: subtitleColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _bioController.text.isEmpty
                              ? 'Adicionar uma frase...'
                              : _bioController.text,
                          style: TextStyle(
                            color: _bioController.text.isEmpty
                                ? subtitleColor.withValues(alpha: 0.6)
                                : textColor,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.edit, size: 16, color: subtitleColor),
                    ],
                  ),
                ),
              ),

              if (widget.authService.isEmailUser) ...[
                const SizedBox(height: 24),
                const Text('SEGURANÇA',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2.0)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.resetPassword);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset_rounded,
                            size: 20, color: textColor),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Alterar Senha',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: subtitleColor, size: 20),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                            color: subtitleColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Salvar',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSwitchOption({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        value: value,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        secondary: Icon(icon, size: 20),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}
