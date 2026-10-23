import 'package:dio/dio.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<Session> login(String username, String password) => guard(() async {
        final r = await _dio.post('/api/auth/login', data: {'username': username, 'password': password});
        final d = r.data as Map<String, dynamic>;
        final roles = ((d['roles'] as List?) ?? const [])
            .map((e) => e.toString().replaceFirst('ROLE_', ''))
            .toList();
        final cid = d['customerId'];
        return Session(
          token: d['token'].toString(),
          username: (d['username'] ?? username).toString(),
          roles: roles,
          customerId: cid is num ? cid.toInt() : null,
        );
      });

  Future<void> register(Map<String, dynamic> body) =>
      guard(() async {
        await _dio.post('/api/auth/register', data: body);
      });
}
