import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/utils/snackbar_helper.dart';

class LojinhaScreen extends StatefulWidget {
  const LojinhaScreen({super.key});

  @override
  State<LojinhaScreen> createState() => _LojinhaScreenState();
}

class _LojinhaScreenState extends State<LojinhaScreen> {
  Timer? _errorTimeout;
  
  @override
  void initState() {
    super.initState();
    // Configura o callback para mostrar snackbars de resultado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iap = Provider.of<IapService>(context, listen: false);
      iap.onPurchaseResult = (success) {
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
    final iap = Provider.of<IapService>(context, listen: false);
    if (iap.onPurchaseResult != null) {
      iap.onPurchaseResult = null;
    }
    super.dispose();
  }

  void _handleBuyAction(VoidCallback buyAction, String productName) {
    SnackBarHelper.showInfo(context, 'Iniciando compra de $productName...');
    
    // Adiciona um timeout para capturar erros que não disparam o callback
    _errorTimeout = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Se não houve resposta em 3 segundos, assume que deu erro
        SnackBarHelper.showError(context, 'Erro ao processar compra. Verifique sua conexão ou tente novamente.');
        _errorTimeout = null;
      }
    });
    
    buyAction();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iap = Provider.of<IapService>(context);

    // Cores do gradiente (Mantive o fundo escuro no dark mode)
    final gradientColors = isDark
        ? [const Color(0xFF0F0F0F), const Color(0xFF1A1A2E)]
        : [const Color(0xFFF5F7FA), const Color(0xFFE3EAF5)];

    return Scaffold(
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            // --- DESTAQUE: APOIE O DEV ---
            _buildSupportDevCard(context, isDark),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () {
                    iap.restorePurchases();
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
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.restore_rounded,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
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
              price: iap.isAdFreePermanent ? "Adquirido" : "R\$ 19,99",
              icon: Icons.block_flipped,
              color: Colors.redAccent,
              isAcquired: iap.isAdFreePermanent,
              onTap: () =>
                  _handleBuyAction(iap.buyAdFree, "AdFree (Vitalício)"),
            ),
            const SizedBox(height: 12),

            // --- ITEM 2: AdFree Lite (7 dias) ---
            _buildProductItem(
              context,
              title: "AdFree Lite (7 dias)",
              description: iap.isAdFreeLiteActive
                  ? "Ativo até: ${_formatDate(iap.adFreeLiteExpiration)}"
                  : "Sem anúncios por uma semana.",
              price: iap.isAdFreeLiteActive ? "Ativo" : "R\$ 2,99",
              icon: Icons.hourglass_top_rounded,
              color: Colors.orangeAccent,
              isAcquired: iap.isAdFreeLiteActive,
              onTap: () => _handleBuyAction(iap.buyAdFreeLite, "AdFree Lite"),
              isDisabled: iap.isAdFreePermanent,
            ),
            const SizedBox(height: 12),

            // --- ITEM 3: Dark Mode ---
            _buildProductItem(
              context,
              title: "Dark Mode 🌙",
              description: "Desbloqueie o tema escuro.",
              price: iap.isDarkModeUnlocked ? "Adquirido" : "R\$ 4,99",
              icon: Icons.dark_mode_rounded,
              color: Colors.indigoAccent,
              isAcquired: iap.isDarkModeUnlocked,
              onTap: () => _handleBuyAction(iap.buyDarkMode, "Dark Mode"),
              onPreviewTap: () => _showPreview(context),
            ),
            const SizedBox(height: 12),

            // --- ITEM 4: Tema Rosa ---
            _buildProductItem(
              context,
              title: "Tema Rosa 🌸",
              description: "Desbloqueie o tema rosa. (Em breve)",
              price: "Em breve",
              icon: Icons.palette,
              color: Colors.pinkAccent,
              isAcquired: false, // Sempre não adquirido por enquanto
              onTap: () {}, // Não implementado ainda
              onPreviewTap: () => _showPreview(context), // Usa mesmo preview do dark mode
            ),
            const SizedBox(height: 12),

            // --- ITEM 5: Tema Halloween ---
            _buildProductItem(
              context,
              title: "Tema Halloween 🎃",
              description: "Desbloqueie o tema Halloween. (Em breve)",
              price: "Em breve",
              icon: Icons.palette,
              color: Colors.orangeAccent,
              isAcquired: false, // Sempre não adquirido por enquanto
              onTap: () {}, // Não implementado ainda
              onPreviewTap: () => _showPreview(context), // Usa mesmo preview do dark mode
            ),
            const SizedBox(height: 12),

            // --- ITEM 6: Notificações ---
            _buildProductItem(
              context,
              title: "Notificações Personalizáveis",
              description: "Personalize os textos das notificações.",
              price: iap.isCustomNotifUnlocked ? "Adquirido" : "R\$ 2,99",
              icon: Icons.notifications_active_rounded,
              color: Colors.teal,
              isAcquired: iap.isCustomNotifUnlocked,
              onTap: () => _handleBuyAction(iap.buyCustomNotif, "Notificações"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 2),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSupportDevCard(BuildContext context, bool isDark) {
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
    required IconData icon,
    required Color color,
    required bool isAcquired, // Removi o isDark daqui pois forçaremos o branco
    required VoidCallback onTap,
    VoidCallback? onPreviewTap,
    bool isDisabled = false,
  }) {
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
                child: Icon(isAcquired ? Icons.check_rounded : icon,
                    color: color, size: 28),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se o Disciplinum te ajuda, considere apoiar o desenvolvimento com qualquer valor via Pix!\n(chave aleatória)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 70, 64, 255)
                            .withValues(alpha: 0.1)
                        : const Color.fromARGB(255, 70, 64, 255)
                            .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                            color: const Color.fromARGB(255, 70, 64, 255),
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
                          color: isDark ? Colors.white : Colors.black87,
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
