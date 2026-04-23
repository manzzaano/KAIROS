import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:kairos/providers/auth_provider.dart';
import 'package:kairos/services/auth_service.dart';
import 'package:kairos/services/storage_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}

class FakeUser extends Fake implements supa.User {
  @override
  String get id => 'test-uuid-123';
  @override
  String? get email => 'test@example.com';
  @override
  Map<String, dynamic>? get userMetadata => {'username': 'test_user'};
}

class FakeAuthResponse extends Fake implements supa.AuthResponse {
  @override
  supa.User? get user => FakeUser();
  @override
  supa.Session? get session => null;
}

void main() {
  late MockAuthService mockAuth;
  late MockStorageService mockStorage;
  late AuthProvider provider;

  setUp(() {
    mockAuth = MockAuthService();
    mockStorage = MockStorageService();
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockStorage.getHasSeenOnboarding())
        .thenAnswer((_) async => false);
    provider = AuthProvider(auth: mockAuth, storage: mockStorage);
  });

  group('bootstrap', () {
    test('inicializa user desde currentUser', () async {
      when(() => mockAuth.currentUser).thenReturn(FakeUser());
      when(() => mockAuth.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockStorage.getHasSeenOnboarding())
          .thenAnswer((_) async => false);

      final p = AuthProvider(auth: mockAuth, storage: mockStorage);
      await p.bootstrap();

      expect(p.user?.id, 'test-uuid-123');
      expect(p.isAuthenticated, isTrue);
    });
  });

  group('login', () {
    test('sets user on success', () async {
      when(() => mockAuth.signIn(any(), any()))
          .thenAnswer((_) async => FakeAuthResponse());

      await provider.login('test@example.com', 'password123');

      expect(provider.user?.id, 'test-uuid-123');
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('sets error on AuthException', () async {
      when(() => mockAuth.signIn(any(), any()))
          .thenThrow(const supa.AuthException('Credenciales incorrectas'));

      await provider.login('test@example.com', 'wrongpassword');

      expect(provider.error, 'Credenciales incorrectas');
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('isLoading es false después de completar', () async {
      when(() => mockAuth.signIn(any(), any()))
          .thenThrow(const supa.AuthException('error'));

      await provider.login('test@example.com', 'pass');

      expect(provider.isLoading, isFalse);
    });
  });

  group('register', () {
    test('sets user on success', () async {
      when(() => mockAuth.signUp(any(), any(), any()))
          .thenAnswer((_) async => FakeAuthResponse());

      await provider.register('test@example.com', 'user', 'password123');

      expect(provider.user?.id, 'test-uuid-123');
      expect(provider.error, isNull);
    });

    test('sets error on AuthException', () async {
      when(() => mockAuth.signUp(any(), any(), any()))
          .thenThrow(const supa.AuthException('Email ya en uso'));

      await provider.register('used@example.com', 'user', 'pass');

      expect(provider.error, 'Email ya en uso');
      expect(provider.user, isNull);
    });
  });

  group('logout', () {
    test('limpia user y error', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await provider.logout();

      expect(provider.user, isNull);
      expect(provider.error, isNull);
    });
  });
}
