import 'package:flutter/material.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

class DeleteAccountDialog extends StatelessWidget {
  final AuthService authService;

  const DeleteAccountDialog({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppDialog(
      title: 'Deletar Conta',
      content: 'Tem certeza que deseja deletar sua conta?\nEsta ação é irreversível e todos os seus dados serão perdidos.',
      customContent: Column(
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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
            ),
            child: const Text(
              'Deletar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
