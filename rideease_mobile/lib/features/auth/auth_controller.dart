import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_store.dart';
import 'auth_repository.dart';

final authRepoProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));

final authProvider = NotifierProvider<AuthController, Session?>(AuthController.new);

class AuthController extends Notifier<Session?> {
  @override
  Session? build() {
    final store = ref.read(tokenStoreProvider);
    final t = store.token;
    if (t == null) return null;
    try {
      if (JwtDecoder.isExpired(t)) return null;
      final p = JwtDecoder.decode(t);
      final roles = ((p['roles'] as List?) ?? const [])
          .map((e) => e.toString().replaceFirst('ROLE_', ''))
          .toList();
      return Session(
        token: t,
        username: (p['sub'] ?? '').toString(),
        roles: roles,
        customerId: store.customerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String username, String password) async {
    final s = await ref.read(authRepoProvider).login(username, password);
    await ref.read(tokenStoreProvider).save(s.token, s.customerId);
    state = s;
  }

  Future<void> register(Map<String, dynamic> body) async {
    await ref.read(authRepoProvider).register(body);
    await login(body['username'].toString(), body['password'].toString());
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = null;
  }

  void sessionExpired() {
    if (state != null) logout();
  }
}
