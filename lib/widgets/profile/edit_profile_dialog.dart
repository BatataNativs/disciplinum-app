import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/app_router.dart';

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

    final messenger = ScaffoldMessenger.of(context);
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
        messenger.showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
                widget.authService.errorMessage ?? 'Erro ao atualizar perfil'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Definição de cores para reutilizar e garantir consistência
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text('Editar Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('NOME',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor), // Cor do texto digitado
              decoration: InputDecoration(
                hintText: 'Como quer ser chamado?',
                hintStyle:
                    TextStyle(color: subtitleColor.withValues(alpha: 0.5)),
                prefixIcon:
                    Icon(Icons.person_outline, size: 20, color: subtitleColor),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CONFIGURAÇÕES',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1)),
            const SizedBox(height: 4),
            SwitchListTile(
              activeThumbColor: isDark ? Colors.white : Colors.black,
              activeTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              title: Text('Exibir e-mail',
                  style: TextStyle(fontSize: 14, color: textColor)),
              subtitle: Text(
                  'Caso desmarcado,\nseu e-mail não será exibido publicamente',
                  style: TextStyle(fontSize: 11, color: subtitleColor)),
              value: _showEmail,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _showEmail = val);
              },
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.alternate_email_rounded,
                  size: 20, color: textColor),
            ),
            SwitchListTile(
              activeThumbColor: isDark ? Colors.white : Colors.black,
              activeTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              title: Text('Exibir minha foto',
                  style: TextStyle(fontSize: 14, color: textColor)),
              subtitle: Text(
                  'Caso desmarcado,\nsua foto não será exibida publicamente',
                  style: TextStyle(fontSize: 11, color: subtitleColor)),
              value: _showAvatar,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _showAvatar = val);
              },
              contentPadding: EdgeInsets.zero,
              secondary:
                  Icon(Icons.face_unlock_rounded, size: 20, color: textColor),
            ),
            const Divider(),
            ListTile(
              title: Text('Frase a ser exibida\nno seu perfil:',
                  style: TextStyle(fontSize: 14, color: textColor)),
              subtitle: Text(
                _bioController.text.isEmpty
                    ? 'Clique para adicionar uma frase'
                    : _bioController.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),
              trailing: Icon(Icons.edit, size: 16, color: subtitleColor),
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.format_quote_rounded, size: 20, color: textColor),
              onTap: () async {
                HapticFeedback.lightImpact();
                final updatedBio = await _showBioDialog();
                if (updatedBio != null) {
                  setState(() {
                    _bioController.text = updatedBio;
                  });
                }
              },
            ),
            if (widget.authService.isEmailUser) ...[
              const Divider(),
              ListTile(
                title: Text('Alterar Senha',
                    style: TextStyle(fontSize: 14, color: textColor)),
                subtitle: Text('Redefina sua senha de acesso',
                    style: TextStyle(fontSize: 11, color: subtitleColor)),
                trailing: Icon(Icons.chevron_right_rounded,
                    size: 20, color: textColor),
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.lock_reset_rounded, size: 20, color: textColor),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.resetPassword);
                },
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: textColor,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor:
                Colors.white, // Texto do botão primary geralmente é branco
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white))
              : const Text('Confirmar',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white)), // Forçando branco no botão primary
        ),
      ],
    );
  }
}
