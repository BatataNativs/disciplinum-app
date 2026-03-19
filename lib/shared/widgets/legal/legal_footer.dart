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
              : const Color.fromARGB(95, 255, 255, 255),
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ao usar este aplicativo, você concorda com nossos',
            style: defaultStyle.copyWith(fontSize: 9),
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
                () => _launchUrl(
                    'https://batatanativs.github.io/disciplinum-legal/termos'),
              ),
              Text(' e ', style: defaultStyle),
              _buildTextLink(
                context,
                'Política de Privacidade',
                defaultStyle,
                () => _launchUrl(
                    'https://batatanativs.github.io/disciplinum-legal/privacidade'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '2026 Disciplinum - desenvolvendo disciplina, foco e bons hábitos',
            style: defaultStyle.copyWith(
              fontSize: 9,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : const Color.fromARGB(95, 255, 255, 255),
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
