import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class CenterModel {
  final int id;
  final String name;
  final String code;
  final String? address;

  CenterModel({
    required this.id,
    required this.name,
    required this.code,
    this.address,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toTableData() {
    return {
      'NOMBRE': name,
      'CÓDIGO': code,
      'DIRECCIÓN': address ?? '-',
      'id': id,
    };
  }
}

class CentersNotifier extends AsyncNotifier<List<CenterModel>> {
  @override
  Future<List<CenterModel>> build() async {
    return _fetchCenters();
  }

  Future<List<CenterModel>> _fetchCenters() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final response = await supabase.from('centers').select().order('name');
      return (response as List).map((json) => CenterModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching centers: $e');
      rethrow;
    }
  }

  Future<void> createCenter({
    required String name,
    required String code,
    String? address,
  }) async {
    state = const AsyncLoading();
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('centers').insert({
        'name': name,
        'code': code,
        'address': address,
      });
      state = AsyncData(await _fetchCenters());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteCenter(int id) async {
    state = const AsyncLoading();
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.from('centers').delete().eq('id', id);
      state = AsyncData(await _fetchCenters());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final centersProvider = AsyncNotifierProvider<CentersNotifier, List<CenterModel>>(() {
  return CentersNotifier();
});
