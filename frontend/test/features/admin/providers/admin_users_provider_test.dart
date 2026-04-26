import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';

void main() {
  test('AdminUsersProvider initial state is loading', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final usersState = container.read(adminUsersProvider);
    expect(usersState, isA<AsyncLoading>());
  });
}
