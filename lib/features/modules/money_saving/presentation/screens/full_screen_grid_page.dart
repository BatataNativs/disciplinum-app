import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/challenge_cell.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/savings_overview_card.dart';

class FullScreenGridPage extends ConsumerStatefulWidget {
  final MoneySavingChallengeModel challenge;

  const FullScreenGridPage({super.key, required this.challenge});

  @override
  ConsumerState<FullScreenGridPage> createState() => _FullScreenGridPageState();
}

class _FullScreenGridPageState extends ConsumerState<FullScreenGridPage> {
  late MoneySavingChallengeModel _currentChallenge;
  bool _isProcessing = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentChallenge = widget.challenge;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _toggleCell(int index) async {
    if (_isProcessing) return;
    if (!_currentChallenge.isActive) {
      SnackBarHelper.showWarning(context, 'Ative o desafio para marcar células!');
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      final service = ref.read(moneySavingChallengeServiceProvider);
      final updated = await service.toggleCell(index);

      if (mounted && updated != null) {
        setState(() {
          _currentChallenge = updated;
          _isProcessing = false;
        });

        if (updated.isComplete) {
          HapticFeedback.heavyImpact();
          _confettiController.play();
          SnackBarHelper.showSuccess(context, '🎉 Parabéns! Você completou o desafio!');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meu Desafio da Poupança',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
              children: [
                Text(
                  'Meta: ${_currentChallenge.currency} ${_currentChallenge.targetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                SavingsOverviewCard(challenge: _currentChallenge, isDark: isDark),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _currentChallenge.totalCells,
                  itemBuilder: (context, index) {
                    final isMarked =
                        _currentChallenge.markedCells.contains(index);
                    final value = index < _currentChallenge.cellValues.length
                        ? _currentChallenge.cellValues[index]
                        : 0.0;

                    return ChallengeCell(
                      index: index,
                      value: value,
                      isMarked: isMarked,
                      isDark: isDark,
                      gridSize: 5,
                      onTap: _toggleCell,
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: _drawStar,
          ),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
