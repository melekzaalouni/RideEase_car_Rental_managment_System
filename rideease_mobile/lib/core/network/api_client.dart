import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../features/auth/auth_controller.dart';
import '../config.dart';
import '../storage/token_store.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(tokenStoreProvider).token;
      final isAuth = options.path.startsWith('/api/auth');
      if (token != null && !isAuth) {
        // The backend answers 403 (not 401) for an expired token, so check it here.
        if (JwtDecoder.isExpired(token)) {
          Future.microtask(() => ref.read(authProvider.notifier).sessionExpired());
        } else {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
    onError: (e, handler) {
      if (e.response?.statusCode == 401 && !e.requestOptions.path.startsWith('/api/auth')) {
        ref.read(authProvider.notifier).sessionExpired();
      }
      handler.next(e);
    },
  ));
  return dio;
});

Future<T> guard<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw ApiException.from(e);
  }
}
