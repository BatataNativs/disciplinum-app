import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class ProfileInfoSection extends ConsumerWidget {
  const ProfileInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userName = authService.isAuthenticated
        ? (authService.userProfile?['name'] ?? 'Usuário')
        : 'Usuário Anônimo';
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
    );
  }
}
