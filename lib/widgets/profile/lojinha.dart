import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/widgets/home/scroll_indicator_arrow.dart';

class Lojinha extends StatelessWidget {
  const Lojinha({super.key});

  @override
  Widget build(BuildContext context) {
    // --- [CONFIGURAÇÃO DE FONTES E CORES DA LOJINHA] ---
    const double shopTitleFontSize = 15.0;
    const double shopDescFontSize = 12.0;
    const double shopAcquiredStatusFontSize = 11.0;
    const double shopPreviewButtonFontSize = 11.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iap = Provider.of<IapService>(context);
    final ScrollController shopScrollController = ScrollController();

    return Align(
      // Move o dialog mais para cima (-0.35 no eixo Y)
      alignment: const Alignment(0.0, -0.35),
      child: AlertDialog(
        // Ajuste fino do padding para "colar" o conteúdo nos botões
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

        title: const Text('🛒 Bem-vindo(a) à lojinha do Disciplinum:'),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark
              ? const Color(0xFF6366F1)
              : const Color(0xFF4F46E5), // cor do título da lojinha
        ),
        // SizedBox com altura fixa para garantir a "janelinha" e permitir scroll interno
        content: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: shopScrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // AdFree Permanente
                      _buildShopItem(
                        context,
                        title: '🚫 AdFree (Sem anúncios)',
                        description:
                            'Remova todos os anúncios do app permanentemente.',
                        isAcquired: iap.isAdFreePermanent,
                        titleColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937),
                        descColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                        acquiredColor: Colors.green,
                        previewColor: Colors.blueAccent,
                        onTap: iap.isAdFreePermanent
                            ? null
                            : () => iap.buyAdFree(),
                        titleSize: shopTitleFontSize,
                        descriptionSize: shopDescFontSize,
                        acquiredSize: shopAcquiredStatusFontSize,
                        previewSize: shopPreviewButtonFontSize,
                      ),
                      const Divider(),

                      // AdFree Lite (7 Dias)
                      _buildShopItem(
                        context,
                        title: '⏳ AdFree Lite (7 dias)',
                        description: iap.isAdFreeLiteActive
                            ? 'Ativo até: ${_formatDate(iap.adFreeLiteExpiration)}'
                            : 'Remover anúncios por apenas 7 dias.',
                        isAcquired: iap.isAdFreeLiteActive,
                        titleColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937),
                        descColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                        acquiredColor: Colors.green,
                        previewColor: Colors.blueAccent,
                        onTap: iap.isAdFree ? null : () => iap.buyAdFreeLite(),
                        titleSize: shopTitleFontSize,
                        descriptionSize: shopDescFontSize,
                        acquiredSize: shopAcquiredStatusFontSize,
                        previewSize: shopPreviewButtonFontSize,
                      ),
                      const Divider(),

                      // Dark Mode
                      _buildShopItem(
                        context,
                        title: '🌙 Dark Mode (Tema escuro)',
                        description:
                            'Você poderá usar o app no incrível tema escuro! Podendo usar modo claro e modo escuro.',
                        isAcquired: iap.isDarkModeUnlocked,
                        titleColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937),
                        descColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                        acquiredColor: Colors.green,
                        previewColor: Colors.blueAccent,
                        onTap: iap.isDarkModeUnlocked
                            ? null
                            : () => iap.buyDarkMode(),
                        titleSize: shopTitleFontSize,
                        descriptionSize: shopDescFontSize,
                        acquiredSize: shopAcquiredStatusFontSize,
                        previewSize: shopPreviewButtonFontSize,
                        onPreviewTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/screenshots/print_tela_escura.jpg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 16,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onPressed: () => Navigator.pop(ctx),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),

                      // Notificações Customizadas
                      _buildShopItem(
                        context,
                        title: '🔔 Notificações Customizadas',
                        description:
                            'Personalize a mensagem de check-in diário para cada módulo!',
                        isAcquired: iap.isCustomNotifUnlocked,
                        titleColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937),
                        descColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                        acquiredColor: Colors.green,
                        previewColor: Colors.blueAccent,
                        onTap: iap.isCustomNotifUnlocked
                            ? null
                            : () => iap.buyCustomNotif(),
                        titleSize: shopTitleFontSize,
                        descriptionSize: shopDescFontSize,
                        acquiredSize: shopAcquiredStatusFontSize,
                        previewSize: shopPreviewButtonFontSize,
                      ),
                      const Divider(),

                      // Apoie o Desenvolvedor
                      _buildShopItem(
                        context,
                        title: '☕ Apoie o desenvolvedor',
                        description:
                            'Contribua com o projeto pagando um "café" (Pix).',
                        isAcquired: false,
                        titleColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF1F2937),
                        descColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                        acquiredColor: Colors.green,
                        previewColor: Colors.blueAccent,
                        onTap: () {
                          Navigator.pop(context); // Fecha Lojinha
                          _mostrarModalCafezinho(context);
                        },
                        titleSize: shopTitleFontSize,
                        descriptionSize: shopDescFontSize,
                        acquiredSize: shopAcquiredStatusFontSize,
                        previewSize: shopPreviewButtonFontSize,
                      ),
                    ],
                  ),
                ),
              ),
              ScrollIndicatorArrow(controller: shopScrollController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              iap.restorePurchases();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscando compras anteriores...')),
              );
            },
            child: Text('Restaurar compras',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Depois',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required String title,
    required String description,
    required bool isAcquired,
    VoidCallback? onTap,
    VoidCallback? onPreviewTap,
    required double titleSize,
    required double descriptionSize,
    required double acquiredSize,
    required double previewSize,
    Color? titleColor,
    Color? descColor,
    Color? acquiredColor,
    Color? previewColor,
  }) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: isAcquired ? null : onTap,
      child: Opacity(
        opacity: isAcquired ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                        color: titleColor,
                      ),
                    ),
                  ),
                  if (onPreviewTap != null)
                    InkWell(
                      onTap: onPreviewTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'Prévia',
                          style: TextStyle(
                            fontSize: previewSize,
                            fontWeight: FontWeight.bold,
                            color: previewColor ??
                                (isDark
                                    ? const Color.fromARGB(255, 59, 183, 232)
                                    : const Color(
                                        0xFF4F46E5)), // cor do texto do botão de prévia
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 16),
                child: Text(
                  description,
                  style: TextStyle(
                    color:
                        isDark ? Colors.grey : (descColor ?? Colors.grey[600]),
                    fontSize: descriptionSize,
                  ),
                ),
              ),
              if (isAcquired)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Produto já adquirido',
                    style: TextStyle(
                      color: acquiredColor ??
                          (isDark
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF4F46E5)),
                      fontSize: acquiredSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarModalCafezinho(BuildContext context) {
    const String chavePix = 'f3b7c116-1d53-4a51-a6a2-5de1f36e688e';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Apoie o Projeto ☕',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF1F2937), // cor do título do modal
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'O Disciplinum é um app independente.\nSe ele te ajuda, considere pagar um "café"!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copie a chave Pix (chave aleatória) abaixo\npara fazer uma doação pelo seu app bancário:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.amberAccent
                        : const Color.fromARGB(255, 43, 33, 188),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.indigo.withValues(alpha: 0.3)
                        : Colors.blue.withValues(
                            alpha: 0.1), // cor de fundo da caixa da chave pix
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chavePix,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            color: isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF4F46E5)),
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: chavePix),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pix copiado!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
