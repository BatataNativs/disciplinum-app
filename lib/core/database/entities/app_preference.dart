import 'package:objectbox/objectbox.dart';

@Entity()
class AppPreference {
  @Id()
  int id = 0;

  @Unique()
  String key;

  String? value;

  AppPreference({required this.key, this.value});
}
