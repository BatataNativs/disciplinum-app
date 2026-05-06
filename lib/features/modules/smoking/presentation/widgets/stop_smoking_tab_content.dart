import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/sections/niche_checkin_section.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_consumption_settings.dart';

/// Widget de conteúdo das abas
class StopSmokingTabContent extends StatelessWidget {
  final int tabIndex;
  final bool isModuleActive;
  final TextEditingController priceController;
  final TextEditingController packsController;
  final String selectedCurrency;
  final DateTime selectedDate;
  final TimeOfDay? checkinTime;
  final Function(String?) onCurrencyChanged;
  final Function(String) onPriceChanged;
  final VoidCallback onDateTap;
  final VoidCallback onDeleteTime;

  const StopSmokingTabContent({
    super.key,
    required this.tabIndex,
    this.isModuleActive = false,
    required this.priceController,
    required this.packsController,
    required this.selectedCurrency,
    required this.selectedDate,
    required this.checkinTime,
    required this.onCurrencyChanged,
    required this.onPriceChanged,
    required this.onDateTap,
    required this.onDeleteTime,
  });

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 0:
        // 0: Parar de fumar (módulo)
        return _buildStopSmokingContent();
      case 1:
        // 1: Como funciona
        return _buildHowItWorksContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHowItWorksContent() {
    return Column(
      children: [
        NicheInfoCard(
          icon: Icons.settings_outlined,
          title: 'Configure seu consumo',
          content: 'Preencha o custo do maço de cigarro e quantos maços você fumava por dia. Esses dados são essenciais para calcular sua economia e progresso.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          icon: Icons.check_box_outlined,
          title: 'Check-in diário',
          content: 'Selecione um horário para receber uma notificação diária. No horário configurado, informe se você fumou ou não naquele dia para manter sua sequência de dias sem fumar.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          icon: Icons.notifications_outlined,
          title: 'Notificações motivacionais',
          content: 'Configure até 8 horários para receber notificações motivacionais ao longo do dia. As frases são adaptadas automaticamente baseadas no seu tempo sem fumar.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          icon: Icons.emoji_events_outlined,
          title: 'Conquistas e medalhas',
          content: 'Acesse "Meu Progresso" para ver suas insígnias e medalhas conquistadas. Complete dias sem fumar para desbloquear insígnias de Ferro, Bronze, Prata, Ouro, Diamante e Disciplinum!',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          icon: Icons.bar_chart_rounded,
          title: 'Economia e estatísticas',
          content: 'Acompanhe quanto você já economizou desde que parou de fumar, visualize projeções financeiras e veja estatísticas dos seus check-ins diários.',
        ),
      ],
    );
  }

  Widget _buildStopSmokingContent() {
    return Column(
      children: [
        SmokingConsumptionSettings(
          isModuleActive: isModuleActive,
          priceController: priceController,
          packsController: packsController,
          selectedCurrency: selectedCurrency,
          selectedDate: selectedDate,
          onCurrencyChanged: onCurrencyChanged,
          onPriceChanged: onPriceChanged,
          onDateTap: onDateTap,
        ),
        const SizedBox(height: 6),
        NicheCheckinSection(
          checkinTime: checkinTime,
          onDeleteTime: onDeleteTime,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
