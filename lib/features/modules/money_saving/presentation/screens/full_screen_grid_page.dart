import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/challenge_cell.dart';
import 'package:disciplinum/features/modules/money_saving/presentation/widgets/savings_overview_card.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_celebration_service.dart';

class FullScreenGridPage extends ConsumerStatefulWidget {
  final MoneySavingChallengeModel challenge;

  const FullScreenGridPage({super.key, required this.challenge});

  @override
  ConsumerState<FullScreenGridPage> createState() => _FullScreenGridPageState();
}

class _FullScreenGridPageState extends ConsumerState<FullScreenGridPage> {
  late MoneySavingChallengeModel _currentChallenge;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentChallenge = widget.challenge;
  }

  Future<void> _loadChallengeData() async {
    try {
      final service = ref.read(moneySavingChallengeServiceProvider);
      final updatedChallenge = service.getActiveChallenge();
      
      if (updatedChallenge != null && mounted) {
        setState(() {
          _currentChallenge = updatedChallenge;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Erro ao carregar dados: $e');
      }
    }
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
      await service.toggleCell(_currentChallenge.id, index);
      
      // Recarrega os dados para obter o desafio atualizado
      await _loadChallengeData();
      
      // Verifica se o desafio foi completado após a atualização
      if (_currentChallenge.isComplete && mounted) {
        // Usa o CelebrationService padronizado
        await MoneySavingCelebrationService.instance.celebrarDesafioCompleto(
          desafioId: _currentChallenge.id,
          desafioName: _currentChallenge.title,
          valorTotal: _currentChallenge.totalSaved,
        );
        if (mounted) {
          SnackBarHelper.showSuccess(context, '🎉 Parabéns! Você completou o desafio!');
        }
      }
      
      setState(() => _isProcessing = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        SnackBarHelper.showError(context, 'Erro ao marcar célula: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meu Desafio da Poupança',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          children: [
            Text(
              'Meta: ${_currentChallenge.currency} ${_currentChallenge.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            SavingsOverviewCard(challenge: _currentChallenge),
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
                  gridSize: 5,
                  onTap: _toggleCell,
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
