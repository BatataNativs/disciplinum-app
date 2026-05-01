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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // NOME DO USUÁRIO
          Center(
            child: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 26,
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
              padding: const EdgeInsets.only(top: 14.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF6366F1).withValues(alpha: 0.25),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                          ]
                        : [
                            const Color(0xFF4F46E5).withValues(alpha: 0.12),
                            const Color(0xFF7C3AED).withValues(alpha: 0.12),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                        : const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  authService.userProfile?['email'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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
              padding: const EdgeInsets.only(top: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.06),
                            Colors.white.withValues(alpha: 0.02),
                          ]
                        : [
                            Colors.black.withValues(alpha: 0.025),
                            Colors.black.withValues(alpha: 0.01),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  authService.userProfile!['bio'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.6,
                    letterSpacing: 0.2,
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
