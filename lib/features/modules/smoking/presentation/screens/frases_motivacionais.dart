import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart' show NicheId;
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/infrastructure/services/gamification_messages.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/providers/module_unlock_providers.dart';

class FrasesMotivacionaisScreen extends ConsumerStatefulWidget {
  const FrasesMotivacionaisScreen({super.key});

  @override
  ConsumerState<FrasesMotivacionaisScreen> createState() =>
      _FrasesMotivacionaisScreenState();
}

class _FrasesMotivacionaisScreenState extends ConsumerState<FrasesMotivacionaisScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.smoking);
  bool _isLoading = true;
  List<PhraseSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final smokingGamification = ref.read(smokingGamificationServiceProvider);
    await smokingGamification.initialize();
    
    final iap = ref.read(iapServiceProvider);

    // Niche ID + 100 para motivação
    final nicheIdMotivation = _niche.id + 100;
    final serverTimes =
        await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(nicheId: nicheIdMotivation);
    // Carrega frases customizadas do serviço local
    final customPhrases = smokingGamification.getCustomMessages();

    // Verificar desbloqueio local uma vez para todos os slots
    final localUnlock = await ref.read(moduleUnlockRepositoryProvider).isUnlocked(
      _niche.nicheId.id.toString(), 
      'motivation_phrases',
    );
    final canCustomize = iap.isMotivationPhrasesUnlocked || localUnlock;

    setState(() {
      _slots = [];

      if (serverTimes.isEmpty) {
        // Se não tiver nada salvo, NÃO cria slot padrão automaticamente
        // Isso evita o problema do horário 09:00 "preso"
        // O usuário pode adicionar manualmente se quiser
      } else {
        for (int i = 0; i < serverTimes.length; i++) {
          final t = serverTimes[i];

          String phraseText;
          final nichePhrases = customPhrases[_niche.nicheId.id.toString()] ?? [];
          
          if (canCustomize) {
            // Se for Personalização, tenta pegar a frase customizada salva
            phraseText = (i < nichePhrases.length)
                ? nichePhrases[i]
                : GamificationMessages.getModuleMessage(
                    _niche.nicheId,
                    isUnlocked: canCustomize,
                    customMessages: {},
                  );
          } else {
            // Se for free, FORÇA a frase padrão, mesmo que tenha algo customizado salvo
            phraseText = GamificationMessages.getModuleMessage(
              _niche.nicheId,
              isUnlocked: canCustomize,
              customMessages: {},
            );
          }

          _slots.add(PhraseSlot(
            text: phraseText,
            time: TimeOfDay(hour: t.hour, minute: t.minute),
          ));
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final smokingGamification = ref.read(smokingGamificationServiceProvider);
    final iap = ref.read(iapServiceProvider);

    setState(() => _isLoading = true);
    final nicheIdMotivation = _niche.id + 100;

    // 1. Limpa horários antigos no Supabase
    await ref.read(cloudSyncServiceProvider).removeAllTimesForNiche(nicheId: nicheIdMotivation);

    // 2. Salva novos horários e frases
    for (final slot in _slots) {
      await ref.read(cloudSyncServiceProvider).addUserNicheTime(
        nicheId: nicheIdMotivation,
        hour: slot.time.hour,
        minute: slot.time.minute,
        // Salva o texto que está no slot (seja o padrão ou editado)
        phrase: slot.text,
      );
    }

    // Salva cache de frases no storage local
    final phrases = _slots.map((s) => s.text).toList();
    if (iap.isMotivationPhrasesUnlocked) {
      await smokingGamification.setCustomMessages(_niche.nicheId.id.toString(), phrases);
    }

    // Salva a primeira frase como mensagem principal customizada
    if (phrases.isNotEmpty) {
      await smokingGamification.setCustomMessage(_niche.nicheId, phrases.first);
    }

    // Recarrega sessões de monitoramento (Reagendar notificações)
    await smokingGamification.reloadMonitoringSession();

    if (mounted) {
      setState(() => _isLoading = false);
      SnackBarHelper.showSuccess(context, 'Configurações salvas com sucesso!');
      Navigator.pop(context);
    }
  }

  void _addSlot() async {
    if (_slots.length >= 8) return;
    final iap = ref.read(iapServiceProvider);
    
    // Verificar desbloqueio local
    final localUnlock = await ref.read(moduleUnlockRepositoryProvider).isUnlocked(
      _niche.nicheId.id.toString(), 
      'motivation_phrases',
    );
    final canCustomize = iap.isMotivationPhrasesUnlocked || localUnlock;
    
    setState(() {
      _slots.add(PhraseSlot(
        text: GamificationMessages.getModuleMessage(
          _niche.nicheId,
          isUnlocked: canCustomize,
          customMessages: {},
        ),
        time: const TimeOfDay(hour: 12, minute: 0),
      ));
    });
  }

  void _removeSlot(int index) {
    // SEM restrição de mínimo. Pode zerar a lista.
    setState(() {
      _slots.removeAt(index);
    });

    // Auto-salvar quando a lista fica vazia para evitar recriação do 09:00
    if (_slots.isEmpty) {
      _saveData();
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slots[index].time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _slots[index].time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iap = ref.watch(iapServiceProvider);
    // Verificar desbloqueio local via provider
    final localUnlockAsync = ref.watch(moduleUnlockStatusProvider(
      (moduleId: _niche.nicheId.id.toString(), unlockType: 'motivation_phrases'),
    ));
    
    final bool canEditText = localUnlockAsync.when(
      data: (localUnlock) => iap.isMotivationPhrasesUnlocked || localUnlock,
      loading: () => iap.isMotivationPhrasesUnlocked,
      error: (_, __) => iap.isMotivationPhrasesUnlocked,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notificações'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/icons/frasesmotivacionais.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Personalize suas notificações motivacionais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Defina frases que te ajudem a manter o foco nos momentos de maior fissura (você pode configurar até 8 horários).',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card de aviso/upsell (Só mostra se não for Premium)
                    if (!canEditText) _buildPurchaseCard(isDark),

                    const SizedBox(height: 16),

                    if (_slots.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            "Nenhum horário definido.\nToque em '+' para adicionar.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ),
                      ),

                    ...List.generate(_slots.length, (index) {
                      final slot = _slots[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NeonCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      // --- CORREÇÃO AQUI ---
                                      key: ValueKey(
                                          'phrase_${index}_$canEditText'),
                                      initialValue: slot.text,
                                      // Se não for Personalização, fica ReadOnly (não abre teclado)
                                      readOnly: !canEditText,
                                      maxLines: 2,
                                      onChanged: (val) => slot.text = val,
                                      // Se tocar no campo ReadOnly (Free), abre o dialog
                                      onTap: !canEditText
                                          ? _showUnlockDialog
                                          : null,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: !canEditText
                                            ? FontStyle.italic
                                            : null,
                                        color: !canEditText
                                            ? (isDark
                                                ? Colors.white60
                                                : Colors.black54)
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Digite sua frase...',
                                        border: InputBorder.none,
                                        // Ícone de cadeado discreto no campo se for Free
                                        suffixIcon: !canEditText
                                            ? const Icon(Icons.lock_outline,
                                                size: 16, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: "Alterar horário",
                                        icon: Icon(
                                          Icons.access_time_rounded,
                                          color: colorScheme.primary,
                                        ),
                                        onPressed: () => _pickTime(index),
                                      ),
                                      Text(
                                        _formatTime(slot.time),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // --- LIXEIRA LIVRE PARA TODOS ---
                                  IconButton(
                                    tooltip: "Remover horário",
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () => _removeSlot(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // --- BOTÃO ADICIONAR LIVRE PARA TODOS (até 8) ---
                    if (_slots.length < 8)
                      Center(
                        child: TextButton.icon(
                          onPressed: _addSlot,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Frase'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: const Text('Salvar Tudo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPurchaseCard(bool isDark) {
    return NotificationMessageEditor(nicheId: _niche.nicheId);
  }

  void _showUnlockDialog() {
    final adService = ref.read(adServiceProvider.notifier);
    final unlockNotifier = ref.read(moduleUnlockNotifierProvider(
      (moduleId: _niche.nicheId.id.toString(), unlockType: 'motivation_phrases'),
    ).notifier);

    adService.loadRewardedAd();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear Personalização'),
        content: const Text(
          'Você pode assistir a um rápido vídeo para liberar a personalização de motivação DESTE módulo, '
          'ou conhecer nossa Lojinha para comprar as Notificações Personalizáveis e liberar TODOS de uma vez.',
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 18),
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleAdUnlock(adService, unlockNotifier);
                },
                label: const Text('Assistir Vídeo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.diamond_outlined, size: 18),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/lojinha');
                },
                label: const Text('Ir para Lojinha'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAdUnlock(AdService adService, ModuleUnlockNotifier unlockNotifier) {
    SnackBarHelper.showInfo(context, 'Carregando anúncio...');

    adService.showRewardedAd(
      onUserEarnedReward: () async {
        // Desbloqueia via provider local
        await unlockNotifier.unlock(method: 'ad');
        if (mounted) {
          SnackBarHelper.showSuccess(
              context, 'Personalização desbloqueada! 🎉');
          setState(() {}); // Recarrega para atualizar UI
        }
      },
      onAdDismissed: () {
        // Nada de extra precisa ser feito ao fechar o ad
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class PhraseSlot {
  String text;
  TimeOfDay time;
  PhraseSlot({required this.text, required this.time});
}
