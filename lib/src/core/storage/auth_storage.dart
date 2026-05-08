import '../../../objectbox.g.dart';
import '../../models/auth_user.dart';

class AuthStorage {
  const AuthStorage(this._box);

  final Box<AuthUser> _box;

  AuthUser? readUser() {
    return _box.getAll().firstOrNull;
  }

  Future<void> saveUser(AuthUser user) async {
    _box.removeAll();
    user.obxId = 0;
    _box.put(user);
  }

  Future<void> clearUser() async {
    _box.removeAll();
  }
}
