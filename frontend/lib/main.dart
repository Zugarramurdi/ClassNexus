import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:frontend/core/constants/env.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/router/app_router.dart';

import 'package:frontend/core/utils/messenger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('***** Supabase init started *****');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  print('***** Supabase init completed *****');

  runApp(
    const ProviderScope(
      child: ClassNexusApp(),
    ),
  );
}

class ClassNexusApp extends ConsumerWidget {
  const ClassNexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ClassNexus',
      scaffoldMessengerKey: messengerKey, // Registramos la clave global
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
