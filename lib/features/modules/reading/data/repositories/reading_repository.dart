import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';

class ReadingRepository {
  Isar get _isar => IsarService.instance.database;

  Future<List<ReadingBookEntity>> getBooks(String userId) async {
    return await _isar.readingBookEntitys.filter().userIdEqualTo(userId).findAll();
  }

  Future<void> saveBook(ReadingBookEntity book) async {
    await _isar.writeTxn(() async {
      await _isar.readingBookEntitys.put(book);
    });
  }

  Future<void> deleteBook(int id) async {
    await _isar.writeTxn(() async {
      await _isar.readingBookEntitys.delete(id);
    });
  }

  Future<ReadingBookEntity?> getBook(int id) async {
    return await _isar.readingBookEntitys.get(id);
  }
}
