import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/centers_provider.dart';

void main() {
  test('CentersProvider initial state is loading', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // El provider debería empezar en estado de carga mientras se obtienen los datos de Supabase
    final centersState = container.read(centersProvider);
    expect(centersState, isA<AsyncLoading>());
  });
}
