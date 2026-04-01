import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/topic_data.dart';
import '../../../core/network/api_client.dart';

// Definimos un autodisposable family provider para que pasemos el ID de la asignatura 
// y obtenga la lista de sus temas de forma reactiva.
final topicsProvider = FutureProvider.autoDispose.family<List<TopicData>, int>((ref, subjectId) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/subjects/$subjectId/topics');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => TopicData.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener los temas: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Error de red al cargar el temario: ${e.response?.data['error'] ?? e.message}');
  }
});
