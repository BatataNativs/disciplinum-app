import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/niche_id.dart';
import '../../../models/niche.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import '../../../widgets/home/neon_card.dart';
import '../../../widgets/profile/lojinha.dart';

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
        // Se não tiver nada salvo, inicia com 1 slot padrão (para não ficar vazio)
        // Mas o usuário pode apagar se quiser depois.
        _slots.add(PhraseSlot(
          text: getModuleMessage(_niche.id),
          time: const TimeOfDay(hour: 9, minute: 0),
        ));
      } else {
        for (int i = 0; i < serverTimes.length; i++) {
          final t = serverTimes[i];

          String phraseText;
          if (iap.isMotivationPhrasesUnlocked) {
            // Se for premium, tenta pegar a frase customizada salva
            phraseText = (i < customPhrases.length)
                ? customPhrases[i]
                : getModuleMessage(_niche.id);
          } else {
            // Se for free, FORÇA a frase padrão, mesmo que tenha algo customizado salvo
            phraseText = getModuleMessage(_niche.id);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  void _addSlot() {
    if (_slots.length >= 8) return;
    setState(() {
      _slots.add(PhraseSlot(
        text: getModuleMessage(_niche.id),
        time: const TimeOfDay(hour: 12, minute: 0),
      ));
    });
  }

  void _removeSlot(int index) {
    // SEM restrição de mínimo. Pode zerar a lista.
    setState(() {
      _slots.removeAt(index);
    });
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

    // Define se o usuário pode EDITAR O TEXTO
    final bool canEditText = iap.isMotivationPhrasesUnlocked;

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
          title: const Text('Frases Motivacionais'),
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
                      'Personalize seus lembretes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Defina frases que te ajudem a manter o foco nos momentos de maior fissura.',
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
                                      // Se não for premium, fica ReadOnly (não abre teclado)
                                      readOnly: !canEditText,
                                      maxLines: 2,
                                      onChanged: (val) => slot.text = val,
                                      // Se tocar no campo ReadOnly (Free), abre o dialog
                                      onTap: !canEditText
                                          ? _showPremiumFeatureDialog
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

  void _showPremiumFeatureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recurso pago 💰'),
        content: const Text(
          'A personalização de mensagens é um recurso pago. '
          '\nDeseja conhecer nossa lojinha?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                builder: (_) => const Lojinha(),
              );
            },
            child: const Text('Ir para Lojinha'),
          ),
        ],
      ),
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
