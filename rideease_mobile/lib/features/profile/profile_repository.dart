import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../auth/auth_controller.dart';

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  Future<Customer> byId(int id) => guard(() async {
        final r = await _dio.get('/api/customers/$id');
        return Customer.fromJson(r.data as Map<String, dynamic>);
      });

  /// The logged-in user's profile photo, or null when none was uploaded.
  Future<Uint8List?> myPhoto() async {
    try {
      final r = await _dio.get<List<int>>(
        '/api/profile/photo',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = r.data;
      return (data == null || data.isEmpty) ? null : Uint8List.fromList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.from(e);
    }
  }

  Future<void> uploadPhoto(Uint8List bytes, String filename) => guard(() async {
        final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: filename)});
        await _dio.post('/api/profile/photo', data: form);
      });

  Future<void> removePhoto() => guard(() async {
        await _dio.delete('/api/profile/photo');
      });
}

final profileRepoProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(dioProvider)));

final myCustomerProvider = FutureProvider.autoDispose<Customer>((ref) async {
  final cid = ref.watch(authProvider)?.customerId;
  if (cid == null) {
    throw StateError('no customer');
  }
  return ref.read(profileRepoProvider).byId(cid);
});

/// Profile photo of the signed-in user (re-fetched when another user signs in).
final myPhotoProvider = FutureProvider<Uint8List?>((ref) async {
  final session = ref.watch(authProvider);
  if (session == null) return null;
  return ref.read(profileRepoProvider).myPhoto();
});
