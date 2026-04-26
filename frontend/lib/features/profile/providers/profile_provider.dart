import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';

class ProfileData {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? email;
  final int? roleId;
  final Map<String, dynamic>? role;

  ProfileData({
    required this.id,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.email,
    this.roleId,
    this.role,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'].toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      email: json['email']?.toString(),
      roleId: json['role_id'] != null ? int.tryParse(json['role_id'].toString()) : null,
      role: json['role'] as Map<String, dynamic>?,
    );
  }
}

final profileProvider = FutureProvider.autoDispose<ProfileData?>((ref) async {
  final dio = ref.watch(dioProvider);
  
  try {
    final response = await dio.get('/me');
    return ProfileData.fromJson(response.data);
  } catch (e, stack) {
    if (e is DioException) {
      print('== ERROR BACKEND /me ==');
      print('DioError Status: ${e.response?.statusCode}');
      print('DioError Data: ${e.response?.data}');
      print('Headers Enviados: ${e.requestOptions.headers}');
    } else {
      print('Error en profileProvider: $e');
      print(stack);
    }
    // If the profile is not found (404), or parsing fails, return null
    return null; 
  }
});
