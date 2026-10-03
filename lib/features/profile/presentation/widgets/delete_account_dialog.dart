import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/auth/presentation/controllers/auth_controller.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

class DeleteAccountDialog extends ConsumerWidget {
  final AuthController authService;

  const DeleteAccountDialog({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppDialog(
      title: 'Deletar Conta ?',
      content:
          'Tem certeza que deseja deletar sua conta?\nEsta ação é irreversível e todos os seus dados serão perdidos.',
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de aviso
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEF4444),
                  Color.fromARGB(255, 183, 18, 18),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color.fromARGB(255, 247, 216, 40),
              size: 50,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outline,
              ),
            ),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Fecha o diálogo

            // Desativa bloqueio biométrico imediatamente
            try {
              await ref.read(biometricLockControllerProvider.notifier).setEnabled(false);
            } catch (_) {}

            final success =
                await authService.deleteAccount(); // ✅ Agora recebe um bool

            if (context.mounted) {
              if (success) {
                // ✅ Redireciona para a WelcomeScreen limpando toda a pilha
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.welcome,
                  (route) => false,
                );
              } else {
                // ✅ Mostra erro se a exclusão falhar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Falha ao deletar a conta. Tente novamente.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Deletar',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
