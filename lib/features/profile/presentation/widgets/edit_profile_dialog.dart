import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final AuthController authService;
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
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        // Adiciona um padding extra na base se o teclado estiver aberto
        margin: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 0),
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nome',
                      hint: 'Seu nome de exibição',
                      icon: Icons.person_outline_rounded,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Fale um pouco sobre você',
                      icon: Icons.description_outlined,
                      colorScheme: colorScheme,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'VISIBILIDADE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      title: 'Exibir e-mail',
                      subtitle: 'Mostrar seu e-mail no perfil público',
                      value: _showEmail,
                      onChanged: (val) => setState(() => _showEmail = val),
                      colorScheme: colorScheme,
                    ),
                    _buildSwitchTile(
                      title: 'Exibir foto de perfil',
                      subtitle: 'Mostrar seu avatar no perfil público',
                      value: _showAvatar,
                      onChanged: (val) => setState(() => _showAvatar = val),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              color: colorScheme.onSurfaceVariant,
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: !_isLoading,
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: colorScheme.onSurfaceVariant, size: 20)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 48), // Alinha o ícone no topo para multiline
                    child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
                  ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: _isLoading ? null : onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _isLoading ? null : () => _save(context),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final profileSuccess = await widget.authService.updateProfile(
        name: _nameController.text,
        bio: _bioController.text,
        showEmail: _showEmail,
        showAvatar: _showAvatar,
      );

      if (!context.mounted) return;

      if (profileSuccess) {
        _showSnackBar(
          context,
          'Perfil atualizado com sucesso!',
          Colors.teal.shade600,
          Icons.check_circle_outline_rounded,
        );
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar(
          context,
          'Erro ao atualizar perfil: ${widget.authService.errorMessage}',
          Theme.of(context).colorScheme.error,
          Icons.error_outline_rounded,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'Erro inesperado ao atualizar perfil.',
        Theme.of(context).colorScheme.error,
        Icons.error_outline_rounded,
      );
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}