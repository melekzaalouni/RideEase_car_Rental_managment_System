import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the JWT (and the linked customer id) in memory and in secure storage.
class TokenStore {
  String? token;
  int? customerId;
  final _storage = const FlutterSecureStorage();

  Future<void> load() async {
    token = await _storage.read(key: 'jwt');
    customerId = int.tryParse(await _storage.read(key: 'customerId') ?? '');
  }

  Future<void> save(String t, int? cid) async {
    token = t;
    customerId = cid;
    await _storage.write(key: 'jwt', value: t);
    if (cid == null) {
      await _storage.delete(key: 'customerId');
    } else {
      await _storage.write(key: 'customerId', value: '$cid');
    }
  }

  Future<void> clear() async {
    token = null;
    customerId = null;
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'customerId');
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => throw UnimplementedError('override in main'));
