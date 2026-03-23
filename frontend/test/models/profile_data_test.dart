import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/profile/providers/profile_provider.dart';

void main() {
  group('ProfileData Model Tests', () {
    test('Parsea correctamente JSON válido con role_id numérico', () {
      final json = {
        'id': 'eb7c223a-1234-abcd-9876-1234567890ab',
        'first_name': 'Juanma',
        'last_name': 'Segura',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role_id': 2,
        'role': {'name': 'teacher'}
      };

      final profile = ProfileData.fromJson(json);

      expect(profile.id, 'eb7c223a-1234-abcd-9876-1234567890ab');
      expect(profile.firstName, 'Juanma');
      expect(profile.roleId, 2);
      expect(profile.role?['name'], 'teacher');
    });

    test('Maneja correctamente role_id en formato String silenciosamente', () {
      final json = {
        'id': 'xyz',
        'role_id': '1', // String problemático desde backend
      };

      final profile = ProfileData.fromJson(json);

      expect(profile.roleId, 1); // Debe haberlo parseado a int automáticamente
    });

    test('Maneja roles null (perfil incompleto) sin fallar', () {
      final json = {
        'id': 'abc',
        'first_name': null,
        'role_id': null,
      };

      final profile = ProfileData.fromJson(json);

      expect(profile.firstName, isNull);
      expect(profile.roleId, isNull);
    });
  });
}
