import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/di/providers.dart';

import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/common/niche_category.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/repositories/niche_category_repository.dart';

import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart' as smoking;
import 'package:disciplinum/features/modules/smoking/gamification/presentation/widgets/smoking_celebration_widget.dart';
import 'package:disciplinum/core/gamification/presentation/widgets/global_celebration_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  bool _isSyncing = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InstalledAppService().preload();
      _checkAndPerformInitialSync();
    });
  }

  Future<void> _checkAndPerformInitialSync({bool isLoginEvent = false}) async {
    // Sincronização controlada por SyncValidationService
    // Só ocorre em: nova build, nova instalação, novo usuário, ou login (novo/re-login)
    final stackTrace = StackTrace.current.toString().split('\n').take(3).join('\n');
    LoggerService.instance.d('🔍 _checkAndPerformInitialSync chamado de:\n$stackTrace');
    
    // Verifica se a HomeScreen é a rota ATIVA (não apenas construída em segundo plano)
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      LoggerService.instance.d('⏭️ Sync pulada: HomeScreen não é a rota ativa (provavelmente AuthWrapper está mostrando outra tela)');
      return;
    }
    
    // Verifica se já está sincronizando
    if (_isSyncing) {
      LoggerService.instance.d('⏭️ Sync pulada: já está sincronizando');
      return;
    }
    
    final authService = ref.read(authServiceProvider);
    final currentUserId = authService.currentUser?.id;
    
    LoggerService.instance.d('🔍 Usuário atual: $currentUserId');
    
    if (currentUserId == null) {
      LoggerService.instance.w('⚠️ Sem usuário logado no momento do sync - aguardando...');
      // NÃO redirecionar - deixar o AuthWrapper cuidar da navegação
      // O didChangeDependencies listener vai chamar novamente quando o usuário estiver disponível
      return;
    }
    
    // Verifica se deve sincronizar baseado nas regras de negócio
    final syncState = ref.read(initialSyncCompletedProvider.notifier);
    final checkResult = await syncState.checkShouldSync(currentUserId, isLoginEvent: isLoginEvent);
    
    LoggerService.instance.d('🔍 Verificação de sync: $checkResult');
    
    if (!checkResult.shouldSync) {
      LoggerService.instance.i('⏭️ Sync pulada: ${checkResult.skipReason}');
      // Marca como já sincronizado na sessão atual (mas não persiste nada novo)
      ref.read(initialSyncCompletedProvider.notifier).markSessionSynced();
      return;
    }
    
    LoggerService.instance.i('🔐 Iniciando sincronização - Motivo: ${checkResult.reason}');
    LoggerService.instance.i('   - Versão: ${checkResult.currentVersion}+${checkResult.currentBuild}');
    LoggerService.instance.i('   - Usuário: $currentUserId');
    LoggerService.instance.i('   - Rota ativa: ${route.settings.name}');
    
    await _performInitialSync(currentUserId);
  }

  Future<void> _performInitialSync(String userId) async {
    if (!mounted) return;
    
    setState(() => _isSyncing = true);
    
    try {
      LoggerService.instance.i('🔄 =========================================================');
      LoggerService.instance.i('🔄 INICIANDO SINCRONIZAÇÃO PARA USUÁRIO: $userId');
      LoggerService.instance.i('🔄 =========================================================');
      
      final cloudSync = ref.read(cloudSyncServiceProvider);
      
      LoggerService.instance.i('🔄 Chamando cloudSync.syncNow()...');
      final success = await cloudSync.syncNow();
      LoggerService.instance.i('🔄 cloudSync.syncNow() retornou: success=$success');
      
      if (!mounted) {
        LoggerService.instance.w('🔄 Widget desmontado após sync, abortando UI updates');
        return;
      }
      
      if (success) {
        LoggerService.instance.i('✅ Sincronização reportou SUCESSO');
        
        // Força refresh dos providers para pegar dados sincronizados
        LoggerService.instance.i('🔄 Invalidando providers dos módulos para recarregar dados sincronizados...');
        ref.invalidate(activeModulesProvider);
        ref.invalidate(smoking.smokingGamificationNotifierProvider);
        await Future.delayed(const Duration(milliseconds: 500)); // Aguarda tempo suficiente para recarregar
        
        // Verifica se algum módulo foi ativado
        final activeModules = ref.read(activeModulesProvider);
        final hasActiveModules = activeModules.isNotEmpty;
        
        LoggerService.instance.i('📊 APÓS SYNC: activeModules=$activeModules, count=${activeModules.length}');
        
        if (hasActiveModules) {
          LoggerService.instance.i('✅ MÓDULOS ATIVOS ENCONTRADOS: ${activeModules.map((m) => m.name).join(", ")}');
          _showSnack('Dados sincronizados.', isSuccess: true);
        } else {
          LoggerService.instance.w('⚠️ NENHUM MÓDULO ATIVO APÓS SYNC! Isso é um problema!');
          _showSnack('Sincronização concluída, mas nenhum módulo ativo foi encontrado.');
        }
        
        LoggerService.instance.i('🔄 =========================================================');
        LoggerService.instance.i('🔄 FIM DA SINCRONIZAÇÃO');
        LoggerService.instance.i('🔄 =========================================================');
      } else {
        LoggerService.instance.w('⚠️ Sincronização retornou FALHA (success=false)');
        _showSnack('Não foi possível sincronizar. Tente manualmente nas configurações.', isError: true);
      }
    } catch (e, stackTrace) {
      LoggerService.instance.e('❌ ERRO CRÍTICO na sincronização', error: e);
      LoggerService.instance.d('StackTrace: $stackTrace');
      if (mounted) {
        _showSnack('Erro ao sincronizar dados.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        // Marca como sincronizado no provider global (persiste build, usuário, etc)
        await ref.read(initialSyncCompletedProvider.notifier).markSynced(userId);
      }
    }
  }

  void _showSnack(String message, {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    
    final isWhite = !isSuccess && !isError;
    final backgroundColor = isError 
      ? Colors.red 
      : (isSuccess ? const Color(0xFF10B981) : Colors.white);
    final foregroundColor = isWhite ? Colors.black87 : Colors.white;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : (isSuccess ? Icons.cloud_done : Icons.cloud),
              color: foregroundColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foregroundColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PermissionService.verifyPermissionAfterReturn(context);
      _checkPendingMedals();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Escuta mudanças no auth state
    ref.listenManual(authServiceProvider, (previous, next) {
      final hadUser = previous?.currentUser != null;
      final hasUser = next.currentUser != null;
      final hasSynced = ref.read(initialSyncCompletedProvider);
      
      LoggerService.instance.d('🎧 Auth state mudou: hadUser=$hadUser, hasUser=$hasUser, hasSynced=$hasSynced');
      
      if (!hadUser && hasUser) {
        // Usuário acabou de logar (transição de deslogado -> logado)
        // Sempre verifica sync, mesmo que já tenha syncado antes
        // Isso garante sync após logout + login, mesmo com mesmo usuário
        LoggerService.instance.i('🔐 Usuário logou na HomeScreen. Forçando verificação de sync...');
        
        // Reseta estado da sessão e chama sync com flag de login
        ref.read(initialSyncCompletedProvider.notifier).resetSessionOnly();
        
        // Passa isLoginEvent: true para garantir sync mesmo com mesmo usuário/build
        _checkAndPerformInitialSync(isLoginEvent: true);
      } else if (hadUser && !hasUser) {
        // Usuário fez logout - reseta estado para próximo login
        LoggerService.instance.i('👤 Usuário deslogou. Resetando estado de sync...');
        ref.read(initialSyncCompletedProvider.notifier).resetSessionOnly();
      } else {
        LoggerService.instance.d('⏭️ Auth listener ignorado: condições não atendidas');
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_permissionsChecked) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        _permissionsChecked = true;

        // Verifica medalhas pendentes assim que a tela monta
        _checkPendingMedals();
      }
    });
  }

  Future<void> _checkPendingMedals() async {
    final pendingAsync = ref.read(pendingMedalsProvider);
    final pending = await pendingAsync;

    if (pending.isNotEmpty) {
      // Pega a primeira e mostra
      final medalName = pending.first;
      _showMedalDialog(medalName);
    }
  }

  void _showMedalDialog(String medalName) {
    showDialog(
      context: context,
      barrierDismissible: false, // Força clicar no OK
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nova Conquista! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Image.asset(
                'assets/logo.png', // Exibe o logo como fallback já que medalData agora é apenas string
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Você ganhou a medalha de $medalName!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Continue assim para alcançar novos objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Consumir medalha localmente (remover da lista visualizada)
                    Navigator.pop(context);
                    Navigator.of(ctx).pop();

                    // Pequeno delay para animação de fechar e abrir a próxima
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) _checkPendingMedals();
                    });
                  },
                  child: const Text('Incrível!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNicheTap(Niche niche, String heroTag) async {
    HapticFeedback.lightImpact();

    if (!mounted) return;

    // Se for stopSmoking, mantemos a lógica (mas agora passando heroTag se quiser,
    // embora o AppRouter para stopSmoking use pushNamed direto sem args no case 'stopSmoking'
    // Mas para consistência, vamos usar a rota detalhada se for possível, ou ajustar.
    // O AppRouter tem um case específico para NicheId.smoking dentro do nicheDetail.
    // Então vamos usar nicheDetail para tudo para aproveitar a heroTag.

    Navigator.pushNamed(
      context,
      AppRouter.nicheDetail,
      arguments: {'niche': niche, 'heroTag': heroTag},
    );
  }

  /// Cores modernas por categoria de nicho
  Color _getNicheColor(int nicheId) {
    switch (nicheId) {
      // Saúde & Bem-estar - Verde esmeralda
      case 1: // smoking
      case 2: // bingeEating
      case 3: // diet
        return const Color(0xFF10B981);
      // Produtividade - Azul royal
      case 8: // procrastination
      case 5: // focus
        return const Color(0xFF3B82F6);
      // Finanças - Âmbar/Dourado
      case 4: // spending
      case 7: // moneySavingChallenge
        return const Color(0xFFF59E0B);
      // Conteúdo Adulto - Roxo vibrante
      case 6: // adultContent
        return const Color(0xFF8B5CF6);
      // Leitura - Coral/Laranja suave
      case 9: // reading
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Widget _buildNicheCard(
      Niche niche, TextTheme textTheme, String heroTag) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _getNicheColor(niche.id);
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return SizedBox(
      height: 195,
      child: GestureDetector(
        onTap: () => _handleNicheTap(niche, heroTag),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark
                    ? colorScheme.surface.withValues(alpha: 0.9)
                    : colorScheme.surface,
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(
              color: isDark
                  ? accentColor.withValues(alpha: 0.6)
                  : accentColor.withValues(alpha: 0.25),
              width: isDark ? 2 : 1.5,
            ),
            boxShadow: [
              // Sombra colorida intensa no tema escuro
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.35 : 0.15),
                blurRadius: isDark ? 20 : 12,
                spreadRadius: isDark ? 2 : 0,
                offset: const Offset(0, 6),
              ),
              // Sombra de profundidade escura
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isDark ? 16 : 8,
                spreadRadius: isDark ? 2 : -2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Container com altura fixa para garantir que todos os ícones fiquem alinhados
              SizedBox(
                height: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? accentColor.withValues(alpha: 0.2)
                          : accentColor.withValues(alpha: 0.12),
                      border: isDark
                          ? Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Transform.scale(
                      scale: niche.scale,
                      child: Hero(
                        tag: heroTag,
                        child: niche.isEmojiIcon
                            ? Text(
                                niche.iconPath,
                                style: const TextStyle(fontSize: 42),
                              )
                            : Image.asset(
                                niche.iconPath,
                                height: 48,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Área de texto com altura flexível mas alinhada
              Text(
                niche.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    niche.homePhrase,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = NicheCategoryRepository.getCategories(); // Mudar para NicheCategory
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;

    final isDark = colorScheme.brightness == Brightness.dark;

    return GlobalCelebrationWidget(
      child: SmokingCelebrationWidget(
        child: Scaffold(
        extendBody: true,
        body: Container(
          color: isDark ? Colors.black : colorScheme.surface,
          child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
            if (isPinkTheme) ...[
              // == FLORES GRANDES (60-80) ==
              Positioned(
                top: 80,
                right: -10,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.local_florist,
                    size: 72,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                top: 280,
                left: -25,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 68,
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -15,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.spa,
                    size: 76,
                    color: colorScheme.primary.withValues(alpha: 0.13),
                  ),
                ),
              ),
              // == FLORES MÉDIAS (30-45) ==
              Positioned(
                top: 45,
                left: 60,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.eco,
                    size: 42,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: 80,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Icon(
                    Icons.local_florist,
                    size: 38,
                    color: colorScheme.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Positioned(
                top: 480,
                left: 45,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Icon(
                    Icons.spa,
                    size: 35,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                bottom: 320,
                right: 65,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 40,
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // == FLORES PEQUENAS (15-25) - Originais ==
              Positioned(
                top: 100,
                left: 30,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.local_florist,
                    size: 28,
                    color: colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Positioned(
                top: 160,
                left: 70,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                right: 40,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.spa,
                    size: 26,
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                top: 350,
                left: 20,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                right: 30,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.local_florist,
                    size: 26,
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: 250,
                left: 50,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.eco,
                    size: 20,
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: 40,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.spa,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // == FLORES PEQUENAS EXTRA ==
              Positioned(
                top: 550,
                left: 100,
                child: Transform.rotate(
                  angle: 0.9,
                  child: Icon(
                    Icons.eco,
                    size: 18,
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                top: 650,
                right: 60,
                child: Transform.rotate(
                  angle: -0.7,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 750,
                left: 25,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.local_florist,
                    size: 16,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 90,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 20,
                    color: colorScheme.secondary.withValues(alpha: 0.13),
                  ),
                ),
              ),
            ],
            Positioned(
              top: -180,
              right: -180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 12),
                Center(
                  child: Column(
                    children: [
                      RepaintBoundary(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Disciplinum',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: 1.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 100, left: 16, right: 16),
                    itemCount: categories.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final activeModules = ref.watch(activeModulesProvider);
                            return _buildActiveModulesSection(
                              activeModules, textTheme);
                          },
                        );
                      }

                      final category = categories[index - 1];
                      return _buildCategorySection(category, textTheme);
                    },
                  ),
                ),
              ],
            ),
            // Overlay de sincronização inicial (esmaece a tela e bloqueia interações)
            if (_isSyncing)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sincronizando dados...',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aguarde enquanto recuperamos seus dados da nuvem',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 0),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      NicheCategory category, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // Usar Wrap para layout de duas colunas como nos módulos ativos
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: category.nicheIds.map((nicheId) {
            final niche = NicheRepository.getById(nicheId);
            final heroTag = '${category.idPrefix}_${niche.id}';
            
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 44) / 2, // Largura exata para 2 colunas
              child: _buildNicheCard(
                niche,
                textTheme,
                heroTag,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Glow suave para cards ativos - mais elegante e menos intenso
  static const Color _activeGlowColor = Color(0xFF22C55E); // Verde mais suave
  static const double _activeBlurRadius = 8.0;
  static const double _activeSpreadRadius = 1.0;

  Widget _buildActiveModulesSection(
      List<NicheId> activeNiches, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos Ativos',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (activeNiches.isEmpty)
          _buildEmptyStateCard(textTheme)
        else
          // Usar Wrap para layout de duas colunas
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activeNiches.map((nicheId) {
              final niche = NicheRepository.getById(nicheId);
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2, // Largura exata para 2 colunas
                child: _buildActiveNicheCard(
                  niche,
                  textTheme,
                  'active_${niche.id}',
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Card para módulos ativos com glow sutil e elegante
  Widget _buildActiveNicheCard(
      Niche niche, TextTheme textTheme, String heroTag) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return SizedBox(
      height: 195,
      child: GestureDetector(
        onTap: () => _handleNicheTap(niche, heroTag),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark
                    ? colorScheme.surface.withValues(alpha: 0.95)
                    : colorScheme.surface,
                isDark
                    ? _activeGlowColor.withValues(alpha: 0.2)
                    : _activeGlowColor.withValues(alpha: 0.06),
              ],
            ),
            // Glow suave e elegante para indicar ativação
            boxShadow: [
              // Glow externo mais intenso no tema escuro
              BoxShadow(
                color: _activeGlowColor.withValues(alpha: isDark ? 0.5 : 0.25),
                blurRadius: isDark ? 16 : _activeBlurRadius,
                spreadRadius: isDark ? 3 : _activeSpreadRadius,
              ),
              // Sombra de profundidade escura
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isDark ? 14 : 6,
                spreadRadius: isDark ? 2 : 0,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: _activeGlowColor.withValues(alpha: isDark ? 0.8 : 0.5),
              width: isDark ? 2.5 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Container com altura fixa para garantir que todos os ícones fiquem alinhados
              SizedBox(
                height: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activeGlowColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      border: Border.all(
                        color: _activeGlowColor.withValues(alpha: isDark ? 0.5 : 0.35),
                        width: isDark ? 1.5 : 1,
                      ),
                    ),
                    child: Transform.scale(
                      scale: niche.scale,
                      child: Hero(
                        tag: heroTag,
                        child: niche.isEmojiIcon
                            ? Text(
                                niche.iconPath,
                                style: const TextStyle(fontSize: 42),
                              )
                            : Image.asset(
                                niche.iconPath,
                                height: 48,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Área de texto com altura flexível mas alinhada
              Text(
                niche.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    niche.homePhrase,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 195,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 36,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ative um módulo',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sem módulos ativos',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

// Extensão para facilitar o acesso ao contexto do GlobalCelebrationWidget
extension GlobalCelebrationContext on BuildContext {
  /// Dispara verificação manual de conquistas pendentes
  void checkPendingAchievements() {
    // O GlobalCelebrationWidget verifica automaticamente no initState
    // Esta extensão pode ser usada para forçar re-verificação se necessário
  }
}
