import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/widgets/user_privacy_and_terms/legal_footer.dart'; //

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com Gradiente Sutil (mesmo estilo da sua Home)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark
                      ? Colors.black
                      : const Color.fromARGB(255, 255, 255, 255),
                  isDark ? Colors.black : const Color.fromARGB(255, 16, 16, 16)
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // LOGO E TÍTULO
                  Image.asset(
                    'assets/logo.png', // Garanta que o path está certo
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Disciplinum',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Te ajudando a ser mais disciplinado.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.grey[400]
                          : const Color.fromARGB(255, 249, 249, 249),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 16),

                  // BOTÕES DE AÇÃO

                  // 1. Criar Conta (Destaque)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // PASSA O ARGUMENTO 1 PARA ABRIR NA ABA "CRIAR CONTA"
                        Navigator.pushNamed(
                          context,
                          AppRouter.auth,
                          arguments: 1, // 1 = Signup
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 14, 180, 180),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Começar Agora - Criar Conta',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Já tenho conta
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // PASSA O ARGUMENTO 0 PARA ABRIR NA ABA "LOGIN"
                        Navigator.pushNamed(
                          context,
                          AppRouter.auth,
                          arguments: 0, // 0 = Login
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : const Color.fromARGB(221, 0, 0, 0),
                        backgroundColor: isDark ? Colors.black : Colors.white,
                        side: BorderSide(
                            color: isDark
                                ? Colors.grey[800]!
                                : const Color.fromARGB(255, 0, 0, 0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Já tenho uma conta - Login',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Continuar como Convidado (Texto discreto)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      // AQUI É O PULO DO GATO JURÍDICO
                      // Ao clicar aqui, ele vai pra Home e aceita os termos implicitamente
                      Navigator.pushReplacementNamed(
                          context, AppRouter.homeGuest);
                    },
                    child: Text(
                      'Experimentar sem conta\n    (sem salvamentos)',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[500]
                            : const Color.fromARGB(255, 172, 172, 172),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Rodapé Legal
                  const LegalFooter(),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
