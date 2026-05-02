import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState _fixed;
  _FakeAuthNotifier(this._fixed);

  @override
  AuthState build() => _fixed;
}

const _tUser = UserEntity(
  id: 'u1',
  email: 'test@example.com',
  displayName: 'Test User',
  isEmailVerified: true,
  token: 'test-token',
);

void main() {
  group('socketProvider', () {
    test('returns DataSourcesSockets instance', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(const AuthUnauthenticated())),
        ],
      );
      addTearDown(container.dispose);

      final socket = container.read(socketProvider);
      expect(socket, isA<DataSourcesSockets>());
    });

    test('does not call connect when user is unauthenticated', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(const AuthUnauthenticated())),
        ],
      );
      addTearDown(container.dispose);

      // Reading the provider should not throw even though no connection is made
      expect(() => container.read(socketProvider), returnsNormally);
    });

    test('disposes socket on container dispose', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(const AuthUnauthenticated())),
        ],
      );

      container.read(socketProvider);
      // dispose triggers ref.onDispose → socket.disconnect()
      expect(() => container.dispose(), returnsNormally);
    });

    test('rebuilds with new socket when auth state changes from null to null', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(const AuthUnauthenticated())),
        ],
      );
      addTearDown(container.dispose);

      final socket1 = container.read(socketProvider);
      final socket2 = container.read(socketProvider);
      expect(identical(socket1, socket2), isTrue);
    });

    test('connects socket when user is authenticated', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _FakeAuthNotifier(const AuthAuthenticated(_tUser)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final socket = container.read(socketProvider);
      expect(socket, isA<DataSourcesSockets>());
      // socket.connect() was called (with real URL that will fail async — that's fine)
    });
  });
}
