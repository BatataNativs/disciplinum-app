import 'package:isar/isar.dart';

part 'app_preference.g.dart';

@collection
class AppPreference {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key;

  String? value; // Armazenado como String, podendo ser JSON encoded para tipos complexos

  AppPreference({required this.key, this.value});
}
