import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalFooter extends StatelessWidget {
  final Color? color;
  const LegalFooter({super.key, this.color});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detecta se o tema é escuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = color ??
        (isDarkMode
            ? Colors.white70
            : const Color.fromARGB(255, 234, 233, 233));

    final linkColor = color ??
        (isDarkMode
            ? Colors.lightBlueAccent
            : const Color.fromARGB(255, 30, 118, 191));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 1.0),
              height: 1.3),
          children: [
            const TextSpan(text: 'Ao continuar, você concorda com os '),
            TextSpan(
              text: 'Termos de Uso',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                // decorationColor para o sublinhado acompanhar a cor do link
                decorationColor: linkColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(
                    'https://batatanativs.github.io/disciplinum-legal/termos'),
            ),
            const TextSpan(text: ' e confirma que leu a '),
            TextSpan(
              text: 'Política de Privacidade',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(
                    'https://batatanativs.github.io/disciplinum-legal/privacidade'),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
