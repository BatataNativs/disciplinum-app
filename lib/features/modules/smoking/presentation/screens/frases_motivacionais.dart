import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_messages.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/shared/widgets/cards/neon_card.dart';
import 'package:disciplinum/shared/widgets/lojinha.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';

class FrasesMotivacionaisScreen extends StatefulWidget {
  const FrasesMotivacionaisScreen({super.key});

  @override
  State<FrasesMotivacionaisScreen> createState() =>
      _FrasesMotivacionaisScreenState();
}

class _FrasesMotivacionaisScreenState extends State<FrasesMotivacionaisScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.smoking);
  bool _isLoading = true;
  List<PhraseSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final iap = Provider.of<IapService>(context, listen: false);

    // Niche ID + 100 para motivação
    final nicheIdMotivation = _niche.id.id + 100;
    final serverTimes =
        await CloudSyncService.loadUserNicheTimes(nicheId: nicheIdMotivation);
    final customPhrases = gamification.customPhrases[_niche.id] ?? [];

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
          if (iap.isMotivationPhrasesUnlocked) {
            // Se for Personalização, tenta pegar a frase customizada salva
            phraseText = (i < customPhrases.length)
                ? customPhrases[i]
                : GamificationMessages.getModuleMessage(
                    _niche.id,
                    isUnlocked: iap.isCustomNotifUnlocked ||
                        gamification.isNotificationUnlocked(_niche.id),
                    customMessages: gamification.customMessages,
                  );
          } else {
            // Se for free, FORÇA a frase padrão, mesmo que tenha algo customizado salvo
            phraseText = GamificationMessages.getModuleMessage(
              _niche.id,
              isUnlocked: iap.isCustomNotifUnlocked ||
                  gamification.isNotificationUnlocked(_niche.id),
              customMessages: gamification.customMessages,
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
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    final iap = Provider.of<IapService>(context, listen: false);

    setState(() => _isLoading = true);
    final nicheIdMotivation = _niche.id.id + 100;

    // 1. Limpa horários antigos no Supabase
    await CloudSyncService.removeAllTimesForNiche(nicheId: nicheIdMotivation);

    // 2. Salva novos horários e frases
    for (final slot in _slots) {
      await CloudSyncService.addUserNicheTime(
        nicheId: nicheIdMotivation,
        hour: slot.time.hour,
        minute: slot.time.minute,
        // Salva o texto que está no slot (seja o padrão ou editado)
        phrase: slot.text,
      );
    }

    // 3. Salva cache de frases no GamificationService
    final phrases = _slots.map((s) => s.text).toList();
    if (iap.isMotivationPhrasesUnlocked) {
      await gamification.setCustomPhrases(_niche.id, phrases);
    }

    // Compatibilidade: Salva a primeira frase como mensagem principal customizada
    if (phrases.isNotEmpty) {
      await gamification.setCustomMessage(_niche.id, phrases.first);
    }

    // 4. Recarrega sessões de monitoramento (Reagendar notificações)
    await gamification.restoreMonitoringSession();

    if (mounted) {
      setState(() => _isLoading = false);
      SnackBarHelper.showSuccess(context, 'Configurações salvas com sucesso!');
      Navigator.pop(context);
    }
  }

  void _addSlot() {
    if (_slots.length >= 8) return;
    final iap = Provider.of<IapService>(context, listen: false);
    final gamification =
        Provider.of<GamificationService>(context, listen: false);
    setState(() {
      _slots.add(PhraseSlot(
        text: GamificationMessages.getModuleMessage(
          _niche.id,
          isUnlocked: iap.isCustomNotifUnlocked ||
              gamification.isNotificationUnlocked(_niche.id),
          customMessages: gamification.customMessages,
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
    final iap = Provider.of<IapService>(context);

    final gamification = Provider.of<GamificationService>(context);

    // Define se o usuário pode EDITAR O TEXTO (IAP Global ou Desbloqueio Local via Ad)
    final bool canEditText = iap.isMotivationPhrasesUnlocked ||
        gamification.isMotivationUnlocked(_niche.id);

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
    return NotificationMessageEditor(nicheId: _niche.id);
  }

  void _showUnlockDialog() {
    final adService = Provider.of<AdService>(context, listen: false);
    final gamification =
        Provider.of<GamificationService>(context, listen: false);

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
                  _handleAdUnlock(gamification, adService);
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
                  showDialog(
                    context: context,
                    builder: (_) => const Lojinha(),
                  );
                },
                label: const Text('Ir para Lojinha'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAdUnlock(GamificationService gamification, AdService adService) {
    SnackBarHelper.showInfo(context, 'Carregando anúncio...');

    adService.showRewardedAd(
      onUserEarnedReward: () {
        gamification.unlockMotivation(_niche.id);
        if (mounted) {
          SnackBarHelper.showSuccess(
              context, 'Personalização desbloqueada! 🎉');
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
