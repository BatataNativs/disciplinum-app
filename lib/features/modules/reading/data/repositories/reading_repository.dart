import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/objectbox.g.dart';

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
}
