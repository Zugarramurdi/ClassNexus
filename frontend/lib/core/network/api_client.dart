import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/constants/env.dart';

final dioProvider = Provider<Dio>((ref) {
  const String baseUrl = Env.apiBaseUrl;

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final session = ref.read(supabaseClientProvider).auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        print('== DIO INTERCEPTOR: Sending Bearer Token ==');
      } else {
        print('== DIO INTERCEPTOR: Warning! currentSession is NULL ==');
      }
      return handler.next(options);
    },
    onError: (e, handler) {
      if (e.response?.statusCode == 401) {
        print('== DIO INTERCEPTOR: Sesión inválida o expirada (401). Forzando cierre de sesión. ==');
        // Usamos el notifier para limpiar el estado y que el router nos mande al login
        ref.read(authNotifierProvider.notifier).signOut();
      }
      return handler.next(e);
    },
  ));

  return dio;
});
