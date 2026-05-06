import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class DarkModePurchaseDialog extends ConsumerStatefulWidget {
  const DarkModePurchaseDialog({super.key});

  @override
  ConsumerState<DarkModePurchaseDialog> createState() => _DarkModePurchaseDialogState();
}

class _DarkModePurchaseDialogState extends ConsumerState<DarkModePurchaseDialog> {
  Timer? _errorTimeout;
  IapService? _iapService;

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
          EnhancedSnackBarHelper.showSuccess(context, 'Dark Mode desbloqueado com sucesso!');
        } else {
          EnhancedSnackBarHelper.showError(context, 'A compra foi cancelada ou ocorreu um erro.');
        }
        
        // Fecha o dialog após o resultado
        Navigator.of(context).pop();
      };
    });
  }

  @override
  void dispose() {
    _errorTimeout?.cancel();
    // Limpa o callback ao sair
    if (_iapService != null && _iapService!.onPurchaseResult != null) {
      _iapService!.onPurchaseResult = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone e título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 12),
                  Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  Text('Recurso Pago',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Conteúdo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.dark_mode_outlined,
                    size: 48,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personalize seu app com o tema escuro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, 
                            color: Color(0xFF10B981), size: 16),
                        SizedBox(width: 4),
                        Text('Compra única',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Depois',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Não fecha o dialog ainda - espera o resultado
                      final iapService = ref.read(iapServiceProvider.notifier);
                      
                      // Mostra snackbar de início da compra
                      EnhancedSnackBarHelper.showInfo(context, 'Iniciando compra de Dark Mode...');
                      
                      // Cria timeout para mostrar erro se não receber resposta
                      _errorTimeout = Timer(const Duration(seconds: 3), () {
                        if (mounted) {
                          EnhancedSnackBarHelper.showError(context, 'Erro ao processar compra. Verifique sua conexão ou tente novamente.');
                          _errorTimeout = null;
                          // Limpa o callback e fecha o dialog em caso de timeout
                          iapService.onPurchaseResult = null;
                          Navigator.of(context).pop();
                        }
                      });
                      
                      // Executa a compra
                      iapService.buyByProductId(IapService.productIdDarkMode);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Comprar agora',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
