import 'dart:async';
import 'dart:io'; // Para Platform
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:provider/provider.dart'; // Import necessário para Auth
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:disciplinum/services/auth/auth_service.dart'; // Import do seu serviço de Auth

class SecretMenuScreen extends StatefulWidget {
  const SecretMenuScreen({super.key});

  @override
  State<SecretMenuScreen> createState() => _SecretMenuScreenState();
}

enum ScreenStage { normal, fringeLock, terminal }

class _SecretMenuScreenState extends State<SecretMenuScreen> {
  // Estado da Tela
  ScreenStage _currentStage = ScreenStage.normal;

  // Variáveis do Contador de Toques
  int _tapCount = 0;
  Timer? _tapResetTimer;

  // Variáveis do Lock (Fringe)
  final List<String> _inputSequence = [];
  final List<String> _correctSequence = ['G', 'G', 'G', 'R'];

  // Variáveis do Terminal
  String _terminalText = "";
  bool _showCursor = true;
  Timer? _cursorTimer;
  int _countdownSeconds = 160; // Timer ajustado para 160s
  bool _dialogShown = false;

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE EXPORTAÇÃO ---
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _exportarDados() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final String emailBody =
        'Olá,\n\nGostaria de solicitar uma cópia/exportação dos meus dados vinculados à minha conta no app Disciplinum.\n\nE-mail da conta: \n\nObrigado!';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'disciplinum.app@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Solicitação de relatório de dados - Disciplinum',
        'body': emailBody,
      }),
    );

    try {
      await AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: emailLaunchUri.toString(),
      ).launch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível abrir o app de e-mail.')),
        );
      }
    }
  }

  // --- LÓGICA DO TRIGGER ---
  void _handleTap() {
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _tapCount = 0;
    });

    setState(() {
      _tapCount++;
    });

    if (_tapCount > 3 && _tapCount < 7) {
      int remaining = 7 - _tapCount;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Faltam $remaining toques...",
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF202020),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }

    if (_tapCount == 7) {
      _activateFringeLock();
    }
  }

  void _activateFringeLock() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _currentStage = ScreenStage.fringeLock;
    });
  }

  // --- LÓGICA DOS BOTÕES ---
  void _handleButtonPress(String colorCode) async {
    _inputSequence.add(colorCode);

    bool isCorrectSoFar = true;
    for (int i = 0; i < _inputSequence.length; i++) {
      if (_inputSequence[i] != _correctSequence[i]) {
        isCorrectSoFar = false;
        break;
      }
    }

    if (!isCorrectSoFar) {
      HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.vibrate();
      setState(() {
        _inputSequence.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sequência incorreta. Resetando..."),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red));
      }
    } else {
      if (_inputSequence.length == _correctSequence.length) {
        await Future.delayed(const Duration(milliseconds: 500));
        _startTerminalMode();
      }
    }
  }

  // --- TERMINAL MODE ---
  void _startTerminalMode() {
    setState(() {
      _currentStage = ScreenStage.terminal;
    });

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });

    _runTerminalSequence();
  }

  Future<void> _typeText(String text, {int speed = 30}) async {
    for (int i = 0; i < text.length; i++) {
      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: speed));
      setState(() {
        _terminalText += text[i];
      });
      if (i % 3 == 0) HapticFeedback.selectionClick();
    }
  }

  Future<void> _spinnerEffect({int loops = 2}) async {
    const chars = ['\\', '|', '/', '-'];
    for (int i = 0; i < loops * 4; i++) {
      if (!mounted) return;
      setState(() {
        _terminalText += chars[i % 4];
      });
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        _terminalText = _terminalText.substring(0, _terminalText.length - 1);
      });
    }
  }

  Future<void> _runTerminalSequence() async {
    // Parte 1: Conexão
    await _typeText(">> connection lost; error #mip test \n", speed: 5);
    await _typeText(">> reconnecting user account...\n", speed: 5);
    await _typeText(">> connection expired\n", speed: 5);
    await _typeText(">> trying random connection...\n", speed: 5);
    await _spinnerEffect(loops: 4);

    // Parte 2: Conta encontrada
    await _typeText(">> new network found! as user: Army-663725bH\n", speed: 5);
    await _typeText(">> reading OTA messages....\n", speed: 5);
    await _spinnerEffect(loops: 2);
    await _typeText(">> found: textFile 11082025 military chat\n", speed: 5);
    await _typeText(
        ">> ### sys dump decrypt: using 'TextFileReader.pitLock' .......\n",
        speed: 5);
    await _typeText(">> wait sys token ..........\n", speed: 5);
    await _typeText(">> (dense21.dll) auto load credentials...\n", speed: 5);
    await _spinnerEffect(loops: 4);

    await Future.delayed(const Duration(seconds: 2));

    // Parte 3: Acesso
    await _typeText(">> access granted .:.\n\n", speed: 5);
    await _typeText(">> message classification: top secret\n\n", speed: 5);
    await _typeText("** Military encrypted messages system **\n", speed: 5);
    await _typeText(">> set language: pt-br\n", speed: 5);
    await _typeText(
        ">> Atenção!\nVocê está acessando área confidencial militar de comunicação. Necessário credencial estratégica.\n\n",
        speed: 5);

    await _typeText(">> apresente sua credencial nível 'Aura3':\n\n", speed: 5);
    await _spinnerEffect(loops: 2);
    await _typeText(">> password_Autoload/anonymousGuest.:dense21.dll\n",
        speed: 5);

    await _typeText("senha: ", speed: 30);
    await _typeText("**********\n\n", speed: 60);

    await _typeText(">> checando credenciais............\n", speed: 5);
    await _spinnerEffect(loops: 5);
    await _typeText(">> acesso permitido! <...>\n\n", speed: 5);

    await _typeText(">> transcrição de mensagem autorizada:\n\n", speed: 5);

    // Parte 4: A História
    String messageBody = """
// Boa tarde, Cel Machado.
Informo que a missão de exploração da caverna da Colina Alta, do interior do estado, precisou ser interrompida, pois quatro dos nossos soldados morreram subitamente, causas ainda não determinadas pelos legistas. 

Eles, em depoimento colhido pelo Oficial-de-Dia na tarde do dia 11 de agosto de 2025, às 1809Z, horas após retornarem do nível baixo da gruta, relataram ter segurado com as mãos, sem luvas, uma criatura de cerca de 1,20m - estatura semelhante a de uma criança, mas com braços e dedos bem longos, e bastante força física - e cabeça desproporcionalmente grande. 

A criatura emitiu um tipo de zumbido, como uma abelha, causando-lhes tontura e certa confusão mental em três deles. No dia seguinte, à noite, os quatro vieram a óbito. E, segundo familiares próximos, eles chegaram a gravar fitas de áudio que podem conter detalhes sobre a criatura e sobre o caso. Coletaremos o material hoje à noite, para que não precisemos "conversar" com a mídia sobre não tocar no assunto. Designaremos os agentes Número #02 e Número #37, em veículo descaracterizado da divisão de abordagem de testemunhas, e em trajes visualmente intimidatórios (terno e chapéu pretos), respeitando as normas da publicação de linguagem corporal e sugestividade. Aguardo parecer do senhor para demais diligências necessárias. 

Respeitosamente, 
Maj P. Herivelto
Chefe da Seção Regional de Criptozoologia (CSRC-BR)
""";

    await _typeText(messageBody, speed: 2);
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownSeconds--;
      });

      // LÓGICA DO DIALOG CORRIGIDA PARA SEU AUTH SERVICE
      if (_countdownSeconds == 30 && !_dialogShown) {
        _showEasterEggDialog();
      }

      if (_countdownSeconds <= 0) {
        timer.cancel();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void _showEasterEggDialog() {
    setState(() => _dialogShown = true);

    final auth = Provider.of<AuthService>(context, listen: false);

    // LÓGICA CORRIGIDA PARA ACESSAR OS DADOS DO SEU AUTH SERVICE
    String userName = "Visitante";
    if (auth.userProfile != null && auth.userProfile!['name'] != null) {
      userName = auth.userProfile!['name'];
    } else if (auth.currentUser?.email != null) {
      userName = auth.currentUser!.email!.split('@').first;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Parabéns!", style: TextStyle(color: Colors.green)),
        content: Text(
          "Parabéns, $userName!\n\n"
          "Você, não só encontrou esse Easter Egg, como também resolveu o pequeno puzzle de luz! "
          "(Isso indica que já assistiu a série Fringe. Tem bom gosto haha).\n\n"
          "Obviamente, tudo isso é falso.\n\n"
          "Ou será que não ......",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    switch (_currentStage) {
      case ScreenStage.normal:
        return _buildNormalView(context);
      case ScreenStage.fringeLock:
        return _buildFringeView(context);
      case ScreenStage.terminal:
        return _buildTerminalView(context);
    }
  }

  Widget _buildNormalView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _handleTap,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Disciplinum",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    Text(
                      " 👉🏻 v 1.0.0 👈🏻",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 22, 22, 22)
                            .withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              title: const Text("Licenças de terceiros e créditos"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Disciplinum',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Batata Dev',
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: LegalFooter(
          onExportTap: _exportarDados,
        ),
      ),
    );
  }

  Widget _buildFringeView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Assistiu a série Fringe?",
                style: TextStyle(color: Colors.white54, letterSpacing: 2),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FringeButton(
                    color: Colors.green,
                    code: 'G',
                    onPress: _handleButtonPress,
                    assetOn: "assets/secret_menu/green_button_on.png",
                    assetOff: "assets/secret_menu/green_button_off.png",
                  ),
                  const SizedBox(width: 40),
                  _FringeButton(
                    color: Colors.red,
                    code: 'R',
                    onPress: _handleButtonPress,
                    assetOn: "assets/secret_menu/red_button_on.png",
                    assetOff: "assets/secret_menu/red_button_off.png",
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Text.rich(TextSpan(
                    text: _terminalText,
                    style: const TextStyle(
                      color: Color(0xFF00FF00),
                      fontFamily: 'Courier',
                      fontSize: 14,
                      height: 1.4,
                    ),
                    children: [
                      if (_showCursor)
                        const TextSpan(
                          text: "█",
                          style: TextStyle(color: Color(0xFF00FF00)),
                        )
                    ])),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "AUTO-DESTRUCT IN: ${_countdownSeconds}s",
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DO RODAPÉ (LegalFooter) ---
class LegalFooter extends StatelessWidget {
  final Color? color;
  final VoidCallback onExportTap;

  const LegalFooter({super.key, this.color, required this.onExportTap});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.grey;
    final linkColor = color ?? Colors.blue;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onExportTap,
            child: Text(
              "Exportar dados gerais",
              style: TextStyle(
                color: linkColor,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.7),
                    height: 1.3),
                children: [
                  const TextSpan(text: 'Ao continuar, você concorda com os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      color: linkColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
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
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DOS BOTÕES FRINGE ---
class _FringeButton extends StatefulWidget {
  final Color color;
  final String code;
  final Function(String) onPress;
  final String? assetOn;
  final String? assetOff;

  const _FringeButton({
    required this.color,
    required this.code,
    required this.onPress,
    this.assetOn,
    this.assetOff,
  });

  @override
  State<_FringeButton> createState() => _FringeButtonState();
}

class _FringeButtonState extends State<_FringeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPress(widget.code);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (widget.assetOn != null && widget.assetOff != null) {
      return Image.asset(
        _isPressed ? widget.assetOn! : widget.assetOff!,
        width: 120, // tamanho do botão
        height: 120, // tamanho do botão
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      width: 120, // tamanho do botão
      height: 120, // tamanho do botão
      decoration: BoxDecoration(
        color: _isPressed ? widget.color : widget.color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          if (_isPressed)
            BoxShadow(
              color: widget.color.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 5,
            )
        ],
        border: Border.all(
          color: widget.color.withValues(alpha: 0.8),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.power_settings_new,
          color:
              _isPressed ? Colors.white : widget.color.withValues(alpha: 0.5),
          size: 30,
        ),
      ),
    );
  }
}
