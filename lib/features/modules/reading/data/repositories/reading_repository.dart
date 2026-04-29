import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReadingRepository {
  Box<ReadingBookEntity> get _box => ObjectBoxService.instance.store.box<ReadingBookEntity>();

  Future<List<ReadingBookEntity>> getBooks(String userId) async {
    return _box.query(ReadingBookEntity_.userId.equals(userId)).build().find();
  }

  Future<void> saveBook(ReadingBookEntity book) async {
    _box.put(book);
  }

  Future<void> deleteBook(int id) async {
    _box.remove(id);
  }

  Future<ReadingBookEntity?> getBook(int id) async {
    return _box.get(id);
  }

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  /// Sincroniza todos os livros do usuário com o Supabase
  Future<void> syncWithSupabase(String userId) async {
    try {
      final books = await getBooks(userId);
      
      final booksData = books.map((book) => {
        'id': book.id,
        'user_id': userId,
        'title': book.title,
        'author': book.author,
        'total_pages': book.totalPages,
        'current_page': book.currentPage,
        'theme_index': book.themeIndex,
        'cover_url': book.coverUrl,
        'start_date': book.startDate?.toIso8601String(),
        'completed_date': book.completedDate?.toIso8601String(),
        'is_completed': book.isCompleted,
        'notes': book.notes,
        'rating': book.rating,
        'additional_data': book.additionalData,
        'created_at': book.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();

      await Supabase.instance.client.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': 'reading_books',
        'books_data': booksData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');

      LoggerService.instance.i('${books.length} livros sincronizados com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar livros com Supabase', error: e);
    }
  }

  /// Carrega livros do Supabase
  Future<List<ReadingBookEntity>> loadFromSupabase(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'reading_books')
          .maybeSingle();

      if (response == null || response['books_data'] == null) {
        return [];
      }

      final booksData = response['books_data'] as List<dynamic>;
      final books = booksData.map((data) {
        final entity = ReadingBookEntity();
        entity.id = data['id'] ?? 0;
        entity.userId = userId;
        entity.title = data['title'] ?? '';
        entity.author = data['author'] ?? '';
        entity.totalPages = data['total_pages'] ?? 0;
        entity.currentPage = data['current_page'] ?? 0;
        entity.themeIndex = data['theme_index'] ?? 11;
        entity.coverUrl = data['cover_url'];
        entity.startDate = data['start_date'] != null 
            ? DateTime.parse(data['start_date']) 
            : null;
        entity.completedDate = data['completed_date'] != null 
            ? DateTime.parse(data['completed_date']) 
            : null;
        entity.isCompleted = data['is_completed'] ?? false;
        entity.notes = data['notes'];
        entity.rating = data['rating'];
        entity.additionalData = data['additional_data'];
        entity.createdAt = data['created_at'] != null 
            ? DateTime.parse(data['created_at']) 
            : DateTime.now();
        entity.updatedAt = data['updated_at'] != null 
            ? DateTime.parse(data['updated_at']) 
            : DateTime.now();
        
        return entity;
      }).toList();

      LoggerService.instance.i('${books.length} livros carregados do Supabase');
      return books;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar livros do Supabase', error: e);
      return [];
    }
  }

  /// Sincronização bidirecional completa
  Future<void> performFullSync(String userId) async {
    try {
      // Carrega da nuvem primeiro
      final cloudBooks = await loadFromSupabase(userId);
      
      if (cloudBooks.isNotEmpty) {
        // Salva localmente
        for (final book in cloudBooks) {
          _box.put(book);
        }
        LoggerService.instance.i('Sincronização: ${cloudBooks.length} livros da nuvem salvos localmente');
      } else {
        // Se não tem na nuvem, envia os locais
        await syncWithSupabase(userId);
      }
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa de livros', error: e);
    }
  }
}
