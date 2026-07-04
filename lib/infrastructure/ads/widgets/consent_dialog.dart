import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:disciplinum/infrastructure/ads/consent_service.dart';

/// Dialog de consentimento de anúncios personalizados
/// Aparece na home screen antes da sincronização
class ConsentDialog extends ConsumerStatefulWidget {
  const ConsentDialog({super.key});

  @override
  ConsumerState<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends ConsumerState<ConsentDialog> {
  bool _personalizedAds = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreference();
  }

  Future<void> _loadCurrentPreference() async {
    final enabled = await ConsentService.instance.arePersonalizedAdsEnabled();
    if (mounted) {
      setState(() => _personalizedAds = enabled);
    }
  }

  Future<void> _savePreference() async {
    setState(() => _isLoading = true);
    
    try {
      await ConsentService.instance.setPersonalizedAdsEnabled(_personalizedAds);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar preferência: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Personalizar sua experiência',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            
            // Checkbox de propaganda personalizada
            Row(
              children: [
                Checkbox(
                  value: _personalizedAds,
                  onChanged: (value) {
                    setState(() => _personalizedAds = value ?? true);
                  },
                  activeColor: colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'Propaganda Personalizada',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Nota explicativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Desabilitar propaganda personalizada nas configurações do dispositivo não impedirá que você veja anúncios gerais.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Links para políticas de privacidade
            Text(
              'Políticas de privacidade dos parceiros:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildPrivacyLink('AWS', 'https://aws.amazon.com/privacy/', colorScheme),
                _buildPrivacyLink('Mintegral', 'https://mintegral.com/privacy/', colorScheme),
                _buildPrivacyLink('Pangle', 'https://www.pangleglobal.com/privacy/', colorScheme),
                _buildPrivacyLink('Moloco', 'https://moloco.com/privacy/', colorScheme),
              ],
            ),
            const SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'VOLTAR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePreference,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'SALVAR',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildPrivacyLink(String name, String url, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Função helper para mostrar o dialog de consentimento
Future<void> showConsentDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const ConsentDialog(),
  );
}
