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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 8, 65, 145), // Azul claro específico
                          const Color.fromARGB(255, 5, 37, 98).withValues(alpha: 0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Editar Livro' : 'Adicionar Novo Livro',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditing ? 'Atualize as informações do livro' : 'Preencha os detalhes para começar',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Campo de título
              _buildTextField(
                controller: _titleController,
                label: 'Título do Livro',
                hint: 'Ex: O Senhor dos Anéis',
                icon: Icons.title_rounded,
                isDark: isDark,
              ),
              
              const SizedBox(height: 12),
              
              // Campo de autor
              _buildTextField(
                controller: _authorController,
                label: 'Autor (opcional)',
                hint: 'Ex: J.R.R. Tolkien',
                icon: Icons.person_rounded,
                isDark: isDark,
                isOptional: true,
              ),
              
              const SizedBox(height: 12),
              
              // Campo de páginas
              _buildTextField(
                controller: _pagesController,
                label: 'Número de Páginas',
                hint: 'Ex: 500',
                icon: Icons.auto_stories_rounded,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Seleção de tema
              Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Grid de temas
              SizedBox(
                height: 100,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: ReadingTheme.values.length,
                  itemBuilder: (context, index) {
                    final theme = ReadingTheme.values[index];
                    final isSelected = _selectedTheme == theme;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTheme = theme;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.color 
                              : theme.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? theme.color 
                                : theme.color.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16,
                              color: isSelected ? Colors.white : theme.color,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              theme.label.split(' ')[0],
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : theme.color,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botão de salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 8, 65, 145), // Azul claro específico
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Atualizar Livro' : 'Adicionar Livro',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isOptional = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: label.contains('Autor') 
            ? TextCapitalization.words 
            : TextCapitalization.sentences,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.white60 : Colors.black54,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 12,
          ),
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 12,
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
}
