import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'module_progress_widget.dart';

/// Aliases para widgets específicos de progresso de módulos
/// Mantém compatibilidade com código existente while usa nova arquitetura

/// Progress widget para Binge Eating
class MyProgressBingeEating extends StatelessWidget {
  const MyProgressBingeEating({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.bingeEating,
      customTitle: 'Progresso - Compulsão Alimentar',
    );
  }
}

/// Progress widget para Diet
class MyProgressDiet extends StatelessWidget {
  const MyProgressDiet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.diet,
      customTitle: 'Progresso - Dieta',
    );
  }
}

/// Progress widget para Focus
class MyProgressFocus extends StatelessWidget {
  const MyProgressFocus({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.focus,
      customTitle: 'Progresso - Foco',
    );
  }
}

/// Progress widget para Money Saving Challenge
class MyProgressMoneySavingChallenge extends StatelessWidget {
  const MyProgressMoneySavingChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.moneySavingChallenge,
      customTitle: 'Progresso - Economia de Dinheiro',
    );
  }
}

/// Progress widget para Procrastination
class MyProgressProcrastination extends StatelessWidget {
  const MyProgressProcrastination({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.procrastination,
      customTitle: 'Progresso - Procrastinação',
    );
  }
}

/// Progress widget para Spending
class MyProgressSpending extends StatelessWidget {
  const MyProgressSpending({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.spending,
      customTitle: 'Progresso - Gastos',
    );
  }
}

/// Progress widget para Smoking
class MyProgressSmoking extends StatelessWidget {
  const MyProgressSmoking({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.smoking,
      customTitle: 'Progresso - Parar de Fumar',
    );
  }
}

/// Progress widget para Reading
class MyProgressReading extends StatelessWidget {
  const MyProgressReading({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.reading,
      customTitle: 'Progresso - Leitura',
    );
  }
}

/// Progress widget para Adult Content
class MyProgressAdultContent extends StatelessWidget {
  const MyProgressAdultContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleProgressWidget(
      nicheId: NicheId.adultContent,
      customTitle: 'Progresso - Jejum 18+',
    );
  }
}
