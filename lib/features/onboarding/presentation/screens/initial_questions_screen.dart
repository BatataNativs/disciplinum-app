import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class _DisciplinumDesign {
  static const primary = Color.fromARGB(255, 103, 205, 243);
  static const primaryDark = Color.fromARGB(255, 76, 179, 210);
  static const background = Color(0xFF0A0A0A);
  static const surfaceCard = Color(0xFF1A1A1A);
  static const border = Color(0x28FFFFFF);
  static const onBackground = Colors.white;
  static const onSurfaceVariant = Color(0xFFB0B0B0);
  static const accentGlow = Color(0x3367CDF3);
}

class InitialQuestionsScreen extends ConsumerStatefulWidget {
  const InitialQuestionsScreen({super.key});

  @override
  ConsumerState<InitialQuestionsScreen> createState() =>
      _InitialQuestionsScreenState();
}

class _InitialQuestionsScreenState
    extends ConsumerState<InitialQuestionsScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherGenderController = TextEditingController();

  int _currentPage = 0;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Masculino',
    'Feminino',
    'Não-binário',
    'Outro',
    'Prefiro não informar',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _otherGenderController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _completeSetup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final enteredName = _nameController.text.trim();
      final finalName = enteredName.isNotEmpty ? enteredName : 'Usuário';

      String finalGender = _selectedGender ?? 'Prefiro não informar';
      if (finalGender == 'Outro') {
        final customOther = _otherGenderController.text.trim();
        if (customOther.isNotEmpty) {
          finalGender = customOther;
        }
      }

      // Salva preferências no ObjectBox
      final prefs =
          ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      await prefs.setString('local_profile_name', finalName);
      await prefs.setString('local_profile_gender', finalGender);
      await prefs.setBool('seen_onboarding', true);

      // Atualiza o perfil no AuthController
      final authController = ref.read(authServiceProvider.notifier);
      await authController.updateProfile(name: finalName);
      await authController.refreshUser();

      LoggerService.instance.i(
          'Setup inicial concluído: nome="$finalName", genero="$finalGender"');

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    } catch (e) {
      LoggerService.instance
          .e('Erro ao finalizar perguntas iniciais', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao salvar informações. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DisciplinumDesign.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progresso visual neon no topo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _DisciplinumDesign.primary
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: isActive
                            ? [
                                const BoxShadow(
                                  color: _DisciplinumDesign.accentGlow,
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildNameStep(),
                  _buildGenderStep(),
                  _buildWelcomeStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PASSO 1: NOME ---
  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _DisciplinumDesign.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _DisciplinumDesign.primary.withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              'Algumas perguntas para começarmos:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _DisciplinumDesign.primary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Como você gostaria\nde ser chamado(a)?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.25,
              color: _DisciplinumDesign.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esse nome será usado para personalizar suas conquistas e relatórios.',
            style: TextStyle(
              fontSize: 14,
              color: _DisciplinumDesign.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          // Campo de texto estilizado
          Container(
            decoration: BoxDecoration(
              color: _DisciplinumDesign.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _DisciplinumDesign.primary.withValues(alpha: 0.5),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _DisciplinumDesign.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 18, 18, 18),
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu nome ou apelido',
                hintStyle: TextStyle(
                  color: _DisciplinumDesign.onSurfaceVariant
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: _DisciplinumDesign.primary,
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              onSubmitted: (_) {
                if (_nameController.text.trim().isNotEmpty) {
                  _nextPage();
                }
              },
            ),
          ),

          const SizedBox(height: 48),

          // Botão Avançar
          _buildNeonButton(
            text: 'Avançar',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                _nameController.text = 'Usuário';
              }
              _nextPage();
            },
          ),
        ],
      ),
    );
  }

  // --- PASSO 2: GÊNERO ---
  Widget _buildGenderStep() {
    final isOtherSelected = _selectedGender == 'Outro';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Gostaria de informar\nseu gênero?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.25,
              color: _DisciplinumDesign.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Essa informação é opcional e serve para adaptar textos motivacionais.',
            style: TextStyle(
              fontSize: 14,
              color: _DisciplinumDesign.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // Opções de gênero
          ..._genderOptions.map((option) {
            final isSelected = _selectedGender == option;
            final label = option == 'Outro' ? 'Outro (digite)' : option;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedGender = option;
                  });
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _DisciplinumDesign.primary.withValues(alpha: 0.15)
                        : _DisciplinumDesign.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? _DisciplinumDesign.primary
                          : _DisciplinumDesign.border,
                      width: isSelected ? 2 : 1.2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color:
                              _DisciplinumDesign.primary.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? _DisciplinumDesign.primary
                            : _DisciplinumDesign.onSurfaceVariant
                                .withValues(alpha: 0.5),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? _DisciplinumDesign.primary
                                : _DisciplinumDesign.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Campo extra se "Outro" for selecionado
          if (isOtherSelected) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _DisciplinumDesign.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _DisciplinumDesign.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _otherGenderController,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _DisciplinumDesign.onBackground,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite como se identifica',
                  hintStyle: TextStyle(
                    color: _DisciplinumDesign.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(
                    Icons.edit_outlined,
                    color: _DisciplinumDesign.primary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],

          const SizedBox(height: 36),

          // Botão Avançar
          _buildNeonButton(
            text: 'Avançar',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              _selectedGender ??= 'Prefiro não informar';
              _nextPage();
            },
          ),
        ],
      ),
    );
  }

  // --- PASSO 3: BOAS-VINDAS ---
  Widget _buildWelcomeStep() {
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Usuário';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Ícone ilustrativo em container com glow
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _DisciplinumDesign.primary,
                  _DisciplinumDesign.primaryDark,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _DisciplinumDesign.primary.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.black,
              size: 58,
            ),
          ),

          const SizedBox(height: 36),

          Text(
            'Tudo pronto, $displayName!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: _DisciplinumDesign.onBackground,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Bem-vindo ao Disciplinum!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _DisciplinumDesign.primary,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Visite sua tela de perfil para mais personalizações',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _DisciplinumDesign.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          const Spacer(),

          // Botão Começar
          _buildNeonButton(
            text: _isLoading ? 'Salvando...' : 'Começar Agora',
            icon: _isLoading ? null : Icons.rocket_launch_rounded,
            onPressed: _isLoading ? null : _completeSetup,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNeonButton({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: _DisciplinumDesign.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _DisciplinumDesign.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.black, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
