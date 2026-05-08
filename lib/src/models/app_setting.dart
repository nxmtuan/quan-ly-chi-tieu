import 'package:objectbox/objectbox.dart';

@Entity()
class AppSetting {
  AppSetting({
    this.id = 0,
    required this.key,
    required this.value,
  });

  @Id()
  int id;

  @Unique()
  String key;

  String value;
}
