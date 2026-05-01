import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
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

  Widget _buildNicheCard(
      Niche niche, bool isDark, TextTheme textTheme, String heroTag) {
    return SizedBox(
      height: 195,
      child: GestureDetector(
        onTap: () => _handleNicheTap(niche, heroTag),
        child: Material(
          color: Colors.transparent,
          elevation: 20,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                        const Color.fromARGB(255, 230, 235, 255),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(164, 255, 255, 255)
                    : Colors.black,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Container com altura fixa para garantir que todos os ícones fiquem alinhados
                // horizontalmente, independente do número de linhas do texto abaixo.
                SizedBox(
                  height: 110,
                  child: Center(
                    child: Transform.scale(
                      scale: niche.scale,
                      child: Hero(
                        tag: heroTag,
                        child: niche.isEmojiIcon
                            ? Text(
                                niche.iconPath,
                                style: const TextStyle(fontSize: 48),
                              )
                            : Image.asset(
                                niche.iconPath,
                                height: 60, // Aumentado tamanho base
                                fit: BoxFit.contain,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      niche.homePhrase,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 9.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = NicheCategoryRepository.getCategories(); // Mudar para NicheCategory
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmokingCelebrationWidget(
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
                isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
              ],
            ),
          ),
          child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -180,
              right: -180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: isDark ? 0.05 : 0.02),
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
                      if (isDark)
                        Text(
                          'Disciplinum',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 1.3,
                            color: Colors.white,
                          ),
                        )
                      else
                        Stack(
                          children: [
                            Text(
                              'Disciplinum',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 1.3,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 1.2
                                  ..color = Colors.black,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 0, 0, 0),
                                  Color.fromARGB(255, 67, 67, 67)
                                ],
                              ).createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'Disciplinum',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  letterSpacing: 1.3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                              activeModules, isDark, textTheme);
                          },
                        );
                      }

                      final category = categories[index - 1];
                      return _buildCategorySection(category, isDark, textTheme);
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
    );
  }

  Widget _buildCategorySection(
      NicheCategory category, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
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
                isDark,
                textTheme,
                heroTag,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActiveModulesSection(
      List<NicheId> activeNiches, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos Ativos',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (activeNiches.isEmpty)
          _buildEmptyStateCard(isDark, textTheme)
        else
          // Usar Wrap para layout de duas colunas
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activeNiches.map((nicheId) {
              final niche = NicheRepository.getById(nicheId);
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2, // Largura exata para 2 colunas
                child: _buildNicheCard(
                  niche,
                  isDark,
                  textTheme,
                  'active_${niche.id}',
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyStateCard(bool isDark, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 195,
            child: Material(
              color: Colors.transparent,
              elevation: 20,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                            const Color.fromARGB(255, 230, 235, 255),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? const Color.fromARGB(164, 255, 255, 255)
                        : Colors.black,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: SizedBox.expand(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🚫',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sem módulos ativos',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color.fromARGB(85, 255, 255, 255)
                              : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()), // Espaço vazio para manter alinhamento
      ],
    );
  }
}
