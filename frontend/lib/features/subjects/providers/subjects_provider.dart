import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';

class SubjectData {
  final int id;
  final String name;
  final String? description;
  final int? centerId;
  final Map<String, dynamic>? center;
  final List<dynamic>? teachers;

  SubjectData({
    required this.id,
    required this.name,
    this.description,
    this.centerId,
    this.center,
    this.teachers,
  });

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      centerId: json['center_id'],
      center: json['center'] as Map<String, dynamic>?,
      teachers: json['teachers'] as List<dynamic>?,
    );
  }
}

final subjectsProvider = FutureProvider.autoDispose<List<SubjectData>>((ref) async {
  final dio = ref.watch(dioProvider);
  
  try {
    final response = await dio.get('/subjects');
    final data = response.data as List;
    return data.map((e) => SubjectData.fromJson(e)).toList();
  } catch (e, stack) {
    if (e is DioException) {
      print('== ERROR BACKEND /subjects ==');
      print('DioError Status: ${e.response?.statusCode}');
      print('DioError Data: ${e.response?.data}');
    } else {
      print('Error en subjectsProvider: $e');
      print(stack);
    }
    // Si hay error, lanzarlo para que el UI muestre estado de fallo
    throw Exception('No se pudieron cargar las asignaturas');
  }
});
