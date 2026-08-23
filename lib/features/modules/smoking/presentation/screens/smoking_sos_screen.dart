import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_craving_record.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_breathing_screen.dart';
import 'package:disciplinum/features/modules/smoking/presentation/screens/smoking_diary_screen.dart';

class SmokingSosScreen extends ConsumerStatefulWidget {
  const SmokingSosScreen({super.key});

  @override
  ConsumerState<SmokingSosScreen> createState() => _SmokingSosScreenState();
}

class _SmokingSosScreenState extends ConsumerState<SmokingSosScreen> {
  int _currentStep = 1; // 1 = Intensidade, 2 = Gatilho, 3 = Intervenção (Timer), 4 = Desfecho

  int _intensity = 3;
  String _selectedTrigger = 'Estresse';
  String? _strategyUsed;

  // Timer da fissura (3 minutos = 180s)
  static const int _totalTimerSeconds = 180;
  int _secondsRemaining = _totalTimerSeconds;
  Timer? _timer;
  bool _isTimerRunning = false;

  final List<Map<String, String>> _triggersList = [
    {'name': 'Estresse / Ansiedade', 'icon': '😡'},
    {'name': 'Café', 'icon': '☕'},
    {'name': 'Bebida Alcoólica', 'icon': '🍺'},
    {'name': 'Momento Social', 'icon': '👥'},
    {'name': 'Pós-refeição', 'icon': '🍽️'},
    {'name': 'Cansaço', 'icon': '😴'},
    {'name': 'Hábito / Tédio', 'icon': '🧠'},
    {'name': 'Outro Motivo', 'icon': '✍️'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        _timer?.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isTimerRunning = false;
          _currentStep = 4; // Vai para desfecho
        });
        HapticFeedback.heavyImpact();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _finishWithOutcome(String outcome) async {
    final cravingService = ref.read(smokingCravingServiceProvider);
    final now = DateTime.now();

    final record = SmokingCravingRecord(
      id: 'craving_${now.millisecondsSinceEpoch}',
      timestamp: now,
      intensity: _intensity,
      trigger: _selectedTrigger,
      outcome: outcome,
      durationSeconds: _totalTimerSeconds - _secondsRemaining,
      strategyUsed: _strategyUsed,
    );

    await cravingService.saveRecord(record);
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    if (outcome == 'overcome') {
      EnhancedSnackBarHelper.showSuccess(
        context,
        'Parabéns! Você resistiu a mais uma onda de vontade com bravura!',
      );
    } else if (outcome == 'persisted') {
      EnhancedSnackBarHelper.showInfo(
        context,
        'Crise registrada. Mantenha o foco, cada minuto sem fumar é uma vitória!',
      );
    } else {
      EnhancedSnackBarHelper.showWarning(
        context,
        'Não desanime. Um deslize não apaga sua força. Recomece agora mesmo!',
      );
    }

    Navigator.pop(context);
  }

  String _formatTimer(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showGroundingExerciseModal() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Color(0xFF6366F1), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Técnica 5-4-3-2-1 de Ancoragem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Ocupe seu córtex pré-frontal para dissipar o impulso automático:',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildGroundingItem('5', 'Coisas que você consegue VER ao seu redor agora.'),
            _buildGroundingItem('4', 'Coisas que você consegue TOCAR (roupa, mesa, chão).'),
            _buildGroundingItem('3', 'Sons que você consegue OUVIR neste exato momento.'),
            _buildGroundingItem('2', 'Cheiros que você consegue SENTIR ou lembrar.'),
            _buildGroundingItem('1', 'Coisa pela qual você é GRATO hoje na sua jornada.'),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _strategyUsed = 'Distração 5-4-3-2-1');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Concluído'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundingItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('SOS Vontade'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: _buildCurrentStepView(),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Intensity();
      case 2:
        return _buildStep2Trigger();
      case 3:
        return _buildStep3InterventionTimer();
      case 4:
      default:
        return _buildStep4Outcome();
    }
  }

  // --- ETAPA 1: INTENSIDADE ---
  Widget _buildStep1Intensity() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF97316).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Text('🚨', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vamos atravessar isso juntos.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A vontade intensa dura em média apenas 3 a 5 minutos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Text(
          'Qual a intensidade da vontade agora?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // 5 Botões de Intensidade
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = _intensity == level;
            Color levelColor;
            if (level <= 2) {
              levelColor = const Color(0xFF10B981);
            } else if (level <= 3) {
              levelColor = const Color(0xFFF59E0B);
            } else {
              levelColor = const Color(0xFFEF4444);
            }

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _intensity = level);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 54,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? levelColor
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? levelColor
                        : colorScheme.outline.withValues(alpha: 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: levelColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🔥' * (level > 3 ? 2 : 1),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),
        Center(
          child: Text(
            _intensity <= 2
                ? 'Leve / Manejável'
                : (_intensity <= 4 ? 'Moderada / Desconfortável' : 'Extrema / Vontade Aguda'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),

        const SizedBox(height: 36),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Próximo: Identificar Gatilho',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- ETAPA 2: GATILHO ---
  Widget _buildStep2Trigger() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'O que desencadeou essa vontade?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Identificar o estímulo ajuda seu cérebro a desassociar o hábito.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Grid de Gatilhos
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _triggersList.map((t) {
            final isSelected = _selectedTrigger == t['name'];
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 36 - 10) / 2,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTrigger = t['name']!);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : colorScheme.outline.withValues(alpha: 0.1),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(t['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _currentStep = 3;
                _secondsRemaining = _totalTimerSeconds;
              });
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Iniciar Intervenção (3 min)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- ETAPA 3: INTERVENÇÃO / TIMER ---
  Widget _buildStep3InterventionTimer() {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_totalTimerSeconds - _secondsRemaining) / _totalTimerSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Respire fundo e aguente firme.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'O pico da vontade vai diminuir nos próximos minutos.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Círculo Regressivo Central
        Center(
          child: SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      _isTimerRunning ? 'em andamento' : 'pausado',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botão Pausar/Continuar Timer
        Center(
          child: TextButton.icon(
            onPressed: () {
              if (_isTimerRunning) {
                _pauseTimer();
              } else {
                _startTimer();
              }
            },
            icon: Icon(_isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_isTimerRunning ? 'Pausar Timer' : 'Continuar Timer'),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Escolha como atravessar essa vontade:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // Ações de Intervenção
        _buildActionTile(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFF06B6D4),
          title: 'Exercício de Respiração Guiada',
          subtitle: 'Desacelere o pulso e normalize a oxigenação',
          onTap: () {
            setState(() => _strategyUsed = 'Respiração');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmokingBreathingScreen()),
            );
          },
        ),
        const SizedBox(height: 8),

        _buildActionTile(
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: 'Beber 1 Copo de Água Gelada',
          subtitle: 'Alívio sensorial oral e hidratação imediata',
          onTap: () {
            setState(() => _strategyUsed = 'Água');
            EnhancedSnackBarHelper.showInfo(
              context,
              'Beba devagar, sentindo a temperatura da água na garganta.',
            );
          },
        ),
        const SizedBox(height: 8),

        _buildActionTile(
          icon: Icons.psychology_outlined,
          iconColor: const Color(0xFF6366F1),
          title: 'Distração Mental (5-4-3-2-1)',
          subtitle: 'Exercício sensorial para desviar o foco da vontade',
          onTap: _showGroundingExerciseModal,
        ),
        const SizedBox(height: 8),

        _buildActionTile(
          icon: Icons.edit_note_rounded,
          iconColor: const Color(0xFF10B981),
          title: 'Desabafar no Diário',
          subtitle: 'Escreva seus pensamentos sem julgamento',
          onTap: () {
            setState(() => _strategyUsed = 'Diário');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmokingDiaryScreen()),
            );
          },
        ),

        const SizedBox(height: 24),

        // Botão Concluir Antecipadamente
        OutlinedButton(
          onPressed: () {
            _timer?.cancel();
            setState(() => _currentStep = 4);
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Finalizar Intervenção'),
        ),
      ],
    );
  }

  // --- ETAPA 4: DESFECHO ---
  Widget _buildStep4Outcome() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          'A vontade passou?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Seu registro é essencial para entender seus padrões de gatilho.',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Opção 1: Superei
        _buildOutcomeCard(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF10B981),
          title: 'Sim, superei a vontade!',
          subtitle: 'Mais uma vitória registrada na sua jornada sem cigarro.',
          onTap: () => _finishWithOutcome('overcome'),
        ),
        const SizedBox(height: 12),

        // Opção 2: Ainda sinto
        _buildOutcomeCard(
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: 'Ainda sinto um pouco de vontade',
          subtitle: 'A vontade está diminuindo gradualmente.',
          onTap: () => _finishWithOutcome('persisted'),
        ),
        const SizedBox(height: 12),

        // Opção 3: Acabei fumando
        _buildOutcomeCard(
          icon: Icons.replay_rounded,
          iconColor: const Color(0xFFEF4444),
          title: 'Acabei fumando',
          subtitle: 'Sem culpa. Aprenda com o gatilho e retome o compromisso agora.',
          onTap: () => _finishWithOutcome('relapsed'),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
