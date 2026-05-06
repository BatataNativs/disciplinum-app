import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:intl/intl.dart';

class SyncBackupScreen extends ConsumerStatefulWidget {
  const SyncBackupScreen({super.key});

  @override
  ConsumerState<SyncBackupScreen> createState() => _SyncBackupScreenState();
}

class _SyncBackupScreenState extends ConsumerState<SyncBackupScreen> {
  bool _isProcessing = false;
  String? _lastSyncDate;

  @override
  void initState() {
    super.initState();
    _loadLastSyncDate();
  }

  Future<void> _loadLastSyncDate() async {
    DateTime? lastSyncDateTime;
    String? source;
    
    // 1. Tenta carregar da NUVEM primeiro (para continuidade entre dispositivos)
    try {
      final cloudTimestamp = await ref.read(cloudSyncServiceProvider).loadLastSyncTimestamp();
      if (cloudTimestamp != null) {
        lastSyncDateTime = cloudTimestamp;
        source = 'nuvem';
        LoggerService.instance.d('☁️ Data de sync carregada da nuvem: $cloudTimestamp');
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao carregar timestamp da nuvem: $e');
    }
    
    // 2. Se não achou na nuvem, tenta carregar do LOCAL
    if (lastSyncDateTime == null) {
      final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      final lastSync = await prefs.getString('last_sync_timestamp');
      if (lastSync != null) {
        lastSyncDateTime = DateTime.parse(lastSync);
        source = 'local';
        LoggerService.instance.d('💾 Data de sync carregada do local: $lastSyncDateTime');
      }
    }
    
    // 3. Atualiza a UI se encontrou alguma data
    if (lastSyncDateTime != null && mounted) {
      setState(() {
        _lastSyncDate = DateFormat('dd/MM/yyyy HH:mm').format(lastSyncDateTime!);
      });
      LoggerService.instance.i('📅 Data de sync exibida (fonte: $source): $_lastSyncDate');
    }
  }

  Future<void> _saveLastSyncDate() async {
    final now = DateTime.now().toIso8601String();
    final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    await prefs.setString('last_sync_timestamp', now);
    _loadLastSyncDate();
  }

  Future<void> _handleAction(String type, Future<bool> Function() action) async {
    setState(() => _isProcessing = true);
    
    try {
      LoggerService.instance.i('Iniciando operação de $type...');
      final success = await action();
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        await _saveLastSyncDate();
        if (!mounted) return;
        EnhancedSnackBarHelper.showSuccess(
          context, 
          type == 'backup' 
            ? 'Backup realizado com sucesso!' 
            : 'Dados sincronizados com sucesso!'
        );
      } else {
        if (!mounted) return;
        EnhancedSnackBarHelper.showError(context, 'Falha na operação. Verifique sua conexão.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        EnhancedSnackBarHelper.showError(context, 'Erro inesperado: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sincronização'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradiente decorativo
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(colorScheme),
                  const SizedBox(height: 40),
                  _buildSyncCard(
                    title: 'Fazer Backup Agora',
                    description: 'Envia seus dados locais para a nuvem de forma segura e criptografada.',
                    icon: Icons.cloud_upload_outlined,
                    gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    onTap: () => _handleAction('backup', () => ref.read(cloudSyncServiceProvider).syncNow()),
                  ),
                  const SizedBox(height: 16),
                  _buildSyncCard(
                    title: 'Sincronizar com Nuvem',
                    description: 'Mescla dados locais com a nuvem. Ideal para múltiplos dispositivos.',
                    icon: Icons.sync_rounded,
                    gradientColors: const [Color(0xFF10B981), Color(0xFF14B8A6)],
                    onTap: () => _handleAction('sync', () => ref.read(cloudSyncServiceProvider).syncNow()),
                  ),
                  const Spacer(),
                  _buildStatusFooter(),
                ],
              ),
            ),
          ),
          // Overlay de loading fullscreen com esmaecimento
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: colorScheme.surface.withValues(alpha: 0.7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card do loading
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Loading indicator grande
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Texto principal bem visível
                              Text(
                                'Sincronizando...',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Subtítulo
                              Text(
                                'Aguarde enquanto seus dados são salvos na nuvem',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ícone principal com efeito de brilho
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.3),
                const Color(0xFF10B981).withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.cloud_done_outlined,
            size: 40,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Salve e sincronize \nseus dados',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Seus dados são sincronizados de forma segura via Supabase.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: gradientColors[0].withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFooter() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          if (_isProcessing) ...[
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sincronizando...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _lastSyncDate != null
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _lastSyncDate != null
                      ? const Color(0xFF10B981).withValues(alpha: 0.25)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _lastSyncDate != null ? Icons.check_circle_outline : Icons.info_outline,
                    color: _lastSyncDate != null
                        ? const Color(0xFF10B981)
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _lastSyncDate != null
                        ? 'Sincronizado em $_lastSyncDate'
                        : 'Nenhuma sincronização ainda',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _lastSyncDate != null
                          ? const Color(0xFF10B981)
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Info de segurança
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.24),
              ),
              const SizedBox(width: 6),
              Text(
                'Dados sincronizados de forma segura',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
