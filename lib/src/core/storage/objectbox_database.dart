import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../objectbox.g.dart';

class ObjectBoxDatabase {
  ObjectBoxDatabase._create(this.store);

  final Store store;

  static Future<ObjectBoxDatabase> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "obx-db");
    final store = await openStore(directory: storeDir);
    return ObjectBoxDatabase._create(store);
  }
}
