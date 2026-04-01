import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  // En Android Emulator, localhost (127.0.0.1) apunta al propio emulador.
  // Debemos usar 10.0.2.2 para acceder al host (tu PC).
  final String baseUrl = (defaultTargetPlatform == TargetPlatform.android)
      ? 'http://10.0.2.2:8000/api'
      : 'http://localhost:8000/api';

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
  ));

  return dio;
});
