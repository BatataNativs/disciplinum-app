import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/core/di/providers.dart';

class AddBookDialog extends ConsumerStatefulWidget {
  /// Se não-nulo, o diálogo entra em modo de edição
  final ReadingBook? bookToEdit;

  const AddBookDialog({super.key, this.bookToEdit});

  static void show(BuildContext context, {ReadingBook? bookToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddBookDialog(bookToEdit: bookToEdit),
    );
  }

  @override
  ConsumerState<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends ConsumerState<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  ReadingTheme _selectedTheme = ReadingTheme.ficcaoCientifica;

  bool get _isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final book = widget.bookToEdit!;
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _pagesController.text = book.totalPages.toString();
      _selectedTheme = book.theme;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final readingService = ref.read(readingServiceProvider);
      
      if (_isEditing) {
        readingService.updateBook(
          bookId: widget.bookToEdit!.id,
          title: _titleController.text,
          author:
              _authorController.text.isEmpty ? null : _authorController.text,
          totalPages: int.parse(_pagesController.text),
          theme: _selectedTheme,
        );
      } else {
        readingService.addBook(
          title: _titleController.text,
          author:
              _authorController.text.isEmpty ? null : _authorController.text,
          totalPages: int.parse(_pagesController.text),
          theme: _selectedTheme,
        );
      }
      
      // Força reload da UI
      ref.invalidate(readingServiceProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header moderno com animação
              _buildModernHeader(colorScheme, isDark),
              const SizedBox(height: 20),
              
              // Campos do formulário
              _buildFormFields(colorScheme, isDark),
              
              const SizedBox(height: 20),
              
              // Seleção de categoria moderna
              _buildCategorySelector(colorScheme, isDark),
              
              const SizedBox(height: 20),
              
              // Botão de salvar moderno
              _buildModernSubmitButton(colorScheme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Header moderno com gradiente e animação
  Widget _buildModernHeader(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
            const Color(0xFFEC4899).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone animado
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Editar Livro' : 'Adicionar Novo Livro',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing ? 'Atualize as informações do livro' : 'Preencha os detalhes para começar sua jornada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Botão fechar moderno
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campos do formulário modernizados
  Widget _buildFormFields(ColorScheme colorScheme, bool isDark) {
    return Column(
      children: [
        // Campo de título
        _buildModernTextField(
          controller: _titleController,
          label: 'Título do Livro',
          hint: 'Ex: O Senhor dos Anéis',
          icon: Icons.title_rounded,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Campo de autor
        _buildModernTextField(
          controller: _authorController,
          label: 'Autor',
          hint: 'Ex: J.R.R. Tolkien',
          icon: Icons.person_rounded,
          colorScheme: colorScheme,
          isDark: isDark,
          isOptional: true,
        ),
        const SizedBox(height: 12),

        // Campo de páginas
        _buildModernTextField(
          controller: _pagesController,
          label: 'Número de Páginas',
          hint: 'Ex: 500',
          icon: Icons.auto_stories_rounded,
          colorScheme: colorScheme,
          isDark: isDark,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // Campo de texto moderno
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    bool isOptional = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: label.contains('Autor')
            ? TextCapitalization.words
            : TextCapitalization.sentences,
        style: TextStyle(
          fontSize: 15,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          suffixIcon: isOptional
              ? Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Opcional',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            color: colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Campo obrigatório';
          }
          if (label.contains('Páginas') && value != null && value.isNotEmpty) {
            if (int.tryParse(value) == null) {
              return 'Número inválido';
            }
            if (int.tryParse(value)! <= 0) {
              return 'Deve ser maior que 0';
            }
          }
          return null;
        },
      ),
    );
  }

  // Seletor de categoria com text buttons
  Widget _buildCategorySelector(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.category_rounded,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Wrap com text buttons para economizar espaço
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ReadingTheme.values.map((theme) {
            final isSelected = _selectedTheme == theme;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(
                              colors: [
                                theme.color,
                                theme.color.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: isSelected 
                          ? null
                          : isDark 
                              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? theme.color
                            : theme.color.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.color.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: isSelected ? Colors.white : theme.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          theme.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected 
                                ? Colors.white 
                                : isDark 
                                    ? colorScheme.onSurface.withValues(alpha: 0.9)
                                    : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Botão de submit moderno
  Widget _buildModernSubmitButton(ColorScheme colorScheme, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
              ],
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submit,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Atualizar Livro' : 'Adicionar Livro',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  }
