import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget para rodapé legal com termos e privacidade
/// Widget reutilizável para todo o app
class LegalFooter extends StatelessWidget {
  final TextStyle? textStyle;

  const LegalFooter({
    super.key,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = textStyle ?? 
        TextStyle(
          fontSize: 12,
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white60 
              : Colors.black54,
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ao usar este aplicativo, você concorda com nossos',
            style: defaultStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextLink(
                context,
                'Termos de Uso',
                defaultStyle,
                () => _launchUrl('https://disciplinum.app/terms'),
              ),
              Text(' e ', style: defaultStyle),
              _buildTextLink(
                context,
                'Política de Privacidade',
                defaultStyle,
                () => _launchUrl('https://disciplinum.app/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2024 Disciplinum - Todos os direitos reservados',
            style: defaultStyle.copyWith(
              fontSize: 10,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white38 
                  : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextLink(
    BuildContext context,
    String text,
    TextStyle style,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style.copyWith(
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
