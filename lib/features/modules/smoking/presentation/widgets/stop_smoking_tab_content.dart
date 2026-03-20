import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/shared/widgets/sections/niche_checkin_section.dart';
import 'package:disciplinum/features/modules/smoking/presentation/widgets/smoking_consumption_settings.dart';

/// Widget de conteúdo das abas
class StopSmokingTabContent extends StatelessWidget {
  final int tabIndex;
  final bool isDark;
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
    required this.isDark,
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
        return _buildHowItWorksContent();
      case 1:
        return _buildStopSmokingContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHowItWorksContent() {
    return Column(
      children: [
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.settings_outlined,
          title: 'No topo da tela, preencha como é o seu consumo',
          content: 'Preencha os dados do seu consumo de cigarro no momento (ou de antes da tentativa atual de parada), salve, e ative o módulo.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.check_box_outlined,
          title: 'Em "Check-in diário", selecione horario para o Check-in diário',
          content: 'No horário configurado, você receberá uma notificação para que você faça o "check-in diário" da sua disciplina, informando se você fumou ou não no dia.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.notifications_outlined,
          title: 'Em "Notificações", configure notificações motivacionais',
          content: 'Insira até 8 horários para receber notificações motivacionais durante o dia. Pra te lembrar de manter a disciplina.',
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.bar_chart_rounded,
          title: 'Em "Estatisticas", veja estatisticas financeiras e de saude',
          content: 'Veja dados de quanto você pode economizar, e como sua saúde pode melhorar, caso mantenha a disciplina.',
        ),
      ],
    );
  }

  Widget _buildStopSmokingContent() {
    return Column(
      children: [
        SmokingConsumptionSettings(
          isDark: isDark,
          priceController: priceController,
          packsController: packsController,
          selectedCurrency: selectedCurrency,
          selectedDate: selectedDate,
          onCurrencyChanged: onCurrencyChanged,
          onPriceChanged: onPriceChanged,
          onDateTap: onDateTap,
        ),
        const SizedBox(height: 24),
        NicheCheckinSection(
          checkinTime: checkinTime,
          isDark: isDark,
          onDeleteTime: onDeleteTime,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
