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
  late bool showEmail;
  late bool showAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    showEmail = widget.initialShowEmail;
    showAvatar = widget.initialShowAvatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Toggle para mostrar/ocultar email
            SwitchListTile(
              title: const Text('Exibir e-mail'),
              subtitle: const Text('Mostrar seu e-mail no perfil'),
              value: showEmail,
              onChanged: (value) {
                setState(() {
                  showEmail = value;
                });
              },
            ),

            // Toggle para mostrar/ocultar avatar
            SwitchListTile(
              title: const Text('Exibir foto de perfil'),
              subtitle: const Text('Mostrar sua foto no perfil'),
              value: showAvatar,
              onChanged: (value) {
                setState(() {
                  showAvatar = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => _save(context),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    try {
      // Atualiza name, bio, show_email e show_avatar no authService (tabela users - Supabase cloud)
      final profileSuccess = await widget.authService.updateProfile(
        name: _nameController.text,
        bio: _bioController.text,
        showEmail: showEmail,
        showAvatar: showAvatar,
      );

      // Usamos apenas profileSuccess como critério primário pois authService garante persistência cloud
      if (profileSuccess && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao atualizar perfil: ${widget.authService.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
