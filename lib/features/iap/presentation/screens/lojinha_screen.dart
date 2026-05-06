import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/core/utils/snackbar_helper.dart';

class LojinhaScreen extends ConsumerStatefulWidget {
  const LojinhaScreen({super.key});

  @override
  ConsumerState<LojinhaScreen> createState() => _LojinhaScreenState();
}

class _LojinhaScreenState extends ConsumerState<LojinhaScreen> {
  IapService? _iapService;
  Timer? _errorTimeout;

  @override
  void initState() {
    super.initState();
    // Configura o callback para mostrar snackbars de resultado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _iapService = ref.read(iapServiceProvider.notifier);
      _iapService?.onPurchaseResult = (productId, success) {
        if (!mounted) return;

        // Cancela o timeout de erro se receber resposta
        _errorTimeout?.cancel();
        _errorTimeout = null;

        if (success) {
          SnackBarHelper.showSuccess(context, 'Compra realizada com sucesso!');
        } else {
          SnackBarHelper.showError(
              context, 'A compra foi cancelada ou ocorreu um erro.');
        }
      };
    });
  }

  @override
  void dispose() {
    // Cancela o timeout se existir
    _errorTimeout?.cancel();

    // Limpa o callback ao sair da tela para evitar chamadas com context inválido
    if (_iapService != null && _iapService!.onPurchaseResult != null) {
      _iapService!.onPurchaseResult = null;
    }
    super.dispose();
  }

  void _handleBuyAction(VoidCallback buyAction, String productName) {
    SnackBarHelper.showInfo(context, 'Iniciando compra de $productName...');

    // Adiciona um timeout para capturar erros que não disparam o callback
    _errorTimeout = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Se não houve resposta em 3 segundos, assume que deu erro
        SnackBarHelper.showError(context,
            'Erro ao processar compra. Verifique sua conexão ou tente novamente.');
        _errorTimeout = null;
      }
    });

    buyAction();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iapState = ref.watch(iapServiceProvider);
    final iapNotifier = ref.read(iapServiceProvider.notifier);

    // Cores do gradiente usando colorScheme
    final gradientColors = [
      colorScheme.surface,
      colorScheme.surfaceContainerHighest,
    ];

    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          title: const Text(
            'Loja Disciplinum',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle:
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
        ),
        body: Stack(
          children: [
            // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
            if (isPinkTheme) ...[
              // == FLORES GRANDES (60-80) ==
              Positioned(
                top: 60,
                right: -15,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.local_florist,
                    size: 70,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                top: 260,
                left: -20,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 66,
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                right: -10,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.spa,
                    size: 74,
                    color: colorScheme.primary.withValues(alpha: 0.13),
                  ),
                ),
              ),
              // == FLORES MÉDIAS (30-45) ==
              Positioned(
                top: 80,
                left: 60,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.eco,
                    size: 40,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 220,
                right: 70,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Icon(
                    Icons.local_florist,
                    size: 36,
                    color: colorScheme.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Positioned(
                top: 450,
                left: 40,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Icon(
                    Icons.spa,
                    size: 34,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                bottom: 350,
                right: 55,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 38,
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // == FLORES PEQUENAS (originais) ==
              // Canto superior esquerdo
              Positioned(
                top: 120,
                left: 30,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.local_florist,
                    size: 26,
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                top: 180,
                left: 70,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 20,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              // Canto superior direito
              Positioned(
                top: 140,
                right: 40,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.spa,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Meio esquerdo
              Positioned(
                top: 400,
                left: 20,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              // Meio direito
              Positioned(
                top: 500,
                right: 30,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.local_florist,
                    size: 24,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Inferior esquerdo
              Positioned(
                bottom: 300,
                left: 50,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.eco,
                    size: 18,
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              // Inferior direito
              Positioned(
                bottom: 250,
                right: 40,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.spa,
                    size: 22,
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ],
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              children: [
            // --- DESTAQUE: APOIE O DEV ---
            _buildSupportDevCard(context, colorScheme),
            const SizedBox(height: 24),

            // --- HEADER: Disponíveis + Restaurar ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Funcionalidades",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  onTap: () {
                    iapNotifier.restorePurchases();
                    SnackBarHelper.showInfo(
                        context, 'Buscando compras anteriores...');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(
                          "Restaurar compras",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.restore_rounded,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- ITEM 1: AdFree Permanente ---
            _buildProductItem(
              context,
              title: "AdFree (Vitalício)",
              description: "Remova anúncios do app permanentemente.",
              price: iapNotifier.isAdFreePermanent ? "Adquirido" : "R\$ 19,99",
              icon: Icons.block_flipped,
              color: Colors.redAccent,
              isAcquired: iapNotifier.isAdFreePermanent,
              onTap: () =>
                  _handleBuyAction(() => iapNotifier.buyAdFree(), "AdFree (Vitalício)"),
            ),
            const SizedBox(height: 12),

            // --- ITEM 2: AdFree Lite (7 dias) ---
            _buildProductItem(
              context,
              title: "AdFree Lite (7 dias)",
              description: iapNotifier.isAdFreeLiteActive
                  ? "Ativo até: ${_formatDate(iapNotifier.adFreeLiteExpiration)}"
                  : "Sem anúncios por uma semana.",
              price: iapNotifier.isAdFreeLiteActive ? "Ativo" : "R\$ 2,99",
              icon: Icons.hourglass_top_rounded,
              color: Colors.orangeAccent,
              isAcquired: iapNotifier.isAdFreeLiteActive,
              onTap: () => _handleBuyAction(() => iapNotifier.buyAdFreeLite(), "AdFree Lite"),
              isDisabled: iapNotifier.isAdFreePermanent,
            ),
            const SizedBox(height: 12),

            // --- ITEM 3: Dark Mode ---
            _buildProductItem(
              context,
              title: "Dark Mode 🌙",
              description: "Desbloqueie o tema escuro.",
              price: iapState.isDarkModeUnlocked ? "Adquirido" : "R\$ 2,99",
              icon: Icons.dark_mode_rounded,
              color: Colors.indigoAccent,
              isAcquired: iapState.isDarkModeUnlocked,
              onTap: () => _handleBuyAction(() => iapNotifier.buyDarkMode(), "Dark Mode"),
              onPreviewTap: () => _showPreview(context),
            ),
            const SizedBox(height: 12),

            // --- ITEM 4: Tema Rosa ---
            _buildProductItem(
              context,
              title: "Tema Rosa 🌸",
              description: "Desbloqueie o tema rosa vibrante e elegante.",
              price: iapState.isPinkThemeUnlocked ? "Adquirido" : "R\$ 2,99",
              emoji: " 🌸",
              color: Colors.pinkAccent,
              isAcquired: iapState.isPinkThemeUnlocked,
              onTap: () => _handleBuyAction(() => iapNotifier.buyPinkTheme(), "Tema Rosa"),
              onPreviewTap: () => _showPreview(context),
            ),
            const SizedBox(height: 12),

            // --- ITEM 5: Tema Halloween ---
            _buildProductItem(
              context,
              title: "Tema Halloween 🎃",
              description: "Desbloqueie o tema assustadoramente divertido.",
              price: iapState.isHalloweenThemeUnlocked ? "Adquirido" : "R\$ 2,99",
              emoji: " 🎃",
              color: Colors.orangeAccent,
              isAcquired: iapState.isHalloweenThemeUnlocked,
              onTap: () => _handleBuyAction(() => iapNotifier.buyHalloweenTheme(), "Tema Halloween"),
              onPreviewTap: () => _showPreview(context),
            ),
          ],
            ),
          ],
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 2),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSupportDevCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 36, 29, 224),
            Color.fromARGB(255, 97, 97, 240)
          ], // Cores vibrantes (Rosa)
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                const Color.fromARGB(255, 36, 29, 224).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text("🤝", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 8),
              const Text(
                "Apoie o Projeto",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Gosta do App? Pague um Café! ☕",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Sua ajuda mantém o Disciplinum vivo e independente.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _mostrarModalCafezinho(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 70, 64, 255),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Fazer um Pix 🤩",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    IconData? icon,
    String? emoji,
    required Color color,
    required bool isAcquired, // Removi o isDark daqui pois forçaremos o branco
    required VoidCallback onTap,
    VoidCallback? onPreviewTap,
    bool isDisabled = false,
  }) {
    assert(icon != null || emoji != null, 'Deve fornecer icon ou emoji');
    final bool canInteract = !isAcquired && !isDisabled;

    return GestureDetector(
      onTap: canInteract ? onTap : null,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, // FORÇADO BRANCO SEMPRE
            borderRadius: BorderRadius.circular(20),
            border: isAcquired
                ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5)
                : null,
            boxShadow: [
              // Sombra suave sempre, já que o fundo é branco
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isAcquired
                    ? Icon(Icons.check_rounded, color: color, size: 28)
                    : emoji != null
                        ? Text(emoji, style: const TextStyle(fontSize: 28))
                        : Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87, // FORÇADO ESCURO
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (onPreviewTap != null)
                          GestureDetector(
                            onTap: onPreviewTap,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                "Ver",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54, // FORÇADO CINZA ESCURO
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAcquired
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey[100], // Fundo do preço cinza claro
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isAcquired ? color : Colors.black87, // Preço escuro
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UTILITÁRIOS ---

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/screenshots/print_tela_dark_mode.png',
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalCafezinho(BuildContext context) {
    const String chavePix = 'f3b7c116-1d53-4a51-a6a2-5de1f36e688e';
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🤩", style: TextStyle(fontSize: 30)),
                const SizedBox(height: 16),
                Text(
                  'Apoie o Projeto 🤝',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se o Disciplinum te ajuda, considere apoiar o desenvolvimento com qualquer valor via Pix!\n(chave aleatória)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                            color: colorScheme.primary,
                            width: 1,
                            style: BorderStyle.solid)
                        .scale(0.3),
                  ),
                  child: Column(
                    children: [
                      Text(
                        chavePix,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                const ClipboardData(text: chavePix));
                            Navigator.pop(ctx);
                            SnackBarHelper.showSuccess(
                                context, 'Chave Pix copiada com sucesso!');
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text("Copiar Chave Pix"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 70, 64, 255),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
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
