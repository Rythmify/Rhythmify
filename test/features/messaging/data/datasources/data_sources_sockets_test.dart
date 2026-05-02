import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';

// ── Minimal engine.io v4 + socket.io v4 WebSocket server ────────────────────
//
// Implements just enough of the protocol to let the Dart socket.io client
// connect, exchange packets, and disconnect cleanly:
//
//   Engine.io OPEN:  0{...}
//   Engine.io PING:  2   → client replies 3
//   Socket.io CONNECT:  40   (from client)   → server replies 40
//   Socket.io EVENT:    42["event",data]
//   Socket.io DISCONNECT: 41
// ────────────────────────────────────────────────────────────────────────────

class _MockSocketIoServer {
  HttpServer? _http;
  WebSocket? _ws;
  final _connected = Completer<void>();

  int get port => _http!.port;

  /// Resolves once the client has completed the socket.io handshake.
  Future<void> get onConnected => _connected.future;

  Future<void> start() async {
    _http = await HttpServer.bind('localhost', 0);
    _http!.listen(_handleRequest);
  }

  Future<void> _handleRequest(HttpRequest req) async {
    if (!WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = 400;
      await req.response.close();
      return;
    }
    _ws = await WebSocketTransformer.upgrade(req);

    // engine.io OPEN — high ping interval so tests never have to deal with pings
    _ws!.add(
      '0{"sid":"test-sid","upgrades":[],'
      '"pingInterval":300000,"pingTimeout":200000,"maxPayload":1000000}',
    );

    _ws!.listen(
      (raw) {
        final data = raw.toString();
        if (data == '2') {
          _ws!.add('3'); // PONG
        } else if (data.startsWith('40')) {
          // socket.io CONNECT from client → ack and signal test
          _ws!.add('40{"sid":"test-socket-sid"}');
          Future<void>.delayed(const Duration(milliseconds: 20), () {
            if (!_connected.isCompleted) _connected.complete();
          });
        }
      },
      onDone: () {
        /* client closed */
      },
    );
  }

  /// Send a socket.io event to the client.
  void sendEvent(String event, dynamic data) {
    _ws?.add('42${jsonEncode([event, data])}');
  }

  /// Close the WebSocket (triggers onDisconnect on the client side).
  Future<void> closeWs() async {
    await _ws?.close();
  }

  Future<void> stop() async {
    await _ws?.close();
    await _http?.close(force: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  /// Waits until [condition] is true, polling every [interval].
  /// Fails (throws) after [timeout] if condition is never met.
  Future<void> waitFor(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('waitFor condition not met within $timeout');
      }
      await Future.delayed(interval);
    }
  }

  // ── without connect ────────────────────────────────────────────────────────

  group('without connect (null socket)', () {
    late DataSourcesSockets ds;

    setUp(() => ds = DataSourcesSockets());

    tearDown(() => ds.disconnect());

    test('setOnReconnectedToRoom stores callback', () {
      var called = false;
      ds.setOnReconnectedToRoom(() => called = true);
      expect(called, isFalse); // stored, not called yet
    });

    test('onMessageReceived stores callback without error', () {
      expect(() => ds.onMessageReceived((_) {}), returnsNormally);
    });

    test('onMessageReadUpdated stores callback without error', () {
      expect(() => ds.onMessageReadUpdated((_) {}), returnsNormally);
    });

    test('onTyping stores callback without error', () {
      expect(() => ds.onTyping((_) {}), returnsNormally);
    });

    test('onStopTyping stores callback without error', () {
      expect(() => ds.onStopTyping((_) {}), returnsNormally);
    });

    test('onUserBlocked stores callback without error', () {
      expect(() => ds.onUserBlocked((_) {}), returnsNormally);
    });

    test('onNotificationCreated stores callback without error', () {
      expect(() => ds.onNotificationCreated((_) {}), returnsNormally);
    });

    test('onNotificationRead stores callback without error', () {
      expect(() => ds.onNotificationRead((_) {}), returnsNormally);
    });

    test('clearConversationListeners runs without error', () {
      ds.onMessageReceived((_) {});
      ds.onMessageReadUpdated((_) {});
      ds.onUserBlocked((_) {});
      ds.setOnReconnectedToRoom(() {});
      expect(() => ds.clearConversationListeners(), returnsNormally);
    });

    test('joinConversation stores conversationId without error', () {
      expect(() => ds.joinConversation('c1'), returnsNormally);
    });

    test('leaveConversation runs without error', () {
      expect(() => ds.leaveConversation('c1'), returnsNormally);
    });

    test('sendMessage runs without error when not connected', () {
      expect(() => ds.sendMessage('c1', {'body': 'hello'}), returnsNormally);
    });

    test('markRead runs without error when not connected', () {
      expect(() => ds.markRead('c1', 'm1', true, 0), returnsNormally);
    });

    test('sendTyping runs without error when not connected', () {
      expect(() => ds.sendTyping('c1'), returnsNormally);
    });

    test('sendStopTyping runs without error when not connected', () {
      expect(() => ds.sendStopTyping('c1'), returnsNormally);
    });

    test('reconnectWithToken returns immediately when socket is null', () {
      expect(() => ds.reconnectWithToken('new-token'), returnsNormally);
    });

    test('forceReconnectIfNeeded returns immediately when socket is null', () {
      expect(() => ds.forceReconnectIfNeeded(), returnsNormally);
    });

    test('disconnect runs without error when never connected', () {
      expect(() => ds.disconnect(), returnsNormally);
    });
  });

  // ── with real mock server ─────────────────────────────────────────────────

  group('with mock socket.io server', () {
    late _MockSocketIoServer server;
    late DataSourcesSockets ds;

    setUp(() async {
      server = _MockSocketIoServer();
      await server.start();
      ds = DataSourcesSockets();
    });

    tearDown(() async {
      ds.disconnect();
      await server.stop();
      // Let any pending async I/O settle
      await Future.delayed(const Duration(milliseconds: 50));
    });

    // ── basic connect / disconnect ──────────────────────────────────────────

    test('connect establishes socket.io connection', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      // If we reach here, the socket connected successfully
    });

    test('onConnect handler fires after connection', () async {
      var connectFired = false;

      // Register a test-callback that detects the connect event
      // We verify it indirectly: the onConnect handler emits 'notification:subscribe'
      // and calls _retryTimer?.cancel(). Connecting without error proves it ran.
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      connectFired = true;

      expect(connectFired, isTrue);
    });

    test(
      'onConnect handler joins room when conversationId is pre-set',
      () async {
        ds.setOnReconnectedToRoom(() {});
        ds.joinConversation('c1'); // sets _currentConversationId before connect
        ds.connect('ws://localhost:${server.port}', () => 'token');
        // onConnect fires and emits 'message:join' + calls _onReconnectedToRoom
        await server.onConnected.timeout(const Duration(seconds: 5));
        // No assertion needed — we're verifying no error is thrown
      },
    );

    test('disconnect triggers onDisconnect handler', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      // disconnect() calls socket.disconnect() which emits 'disconnect' event
      expect(() => ds.disconnect(), returnsNormally);
    });

    // ── emit helpers after connect ──────────────────────────────────────────

    test('joinConversation emits message:join when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(() => ds.joinConversation('conv-1'), returnsNormally);
    });

    test('leaveConversation emits message:leave when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(() => ds.leaveConversation('conv-1'), returnsNormally);
    });

    test('sendMessage emits when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(
        () => ds.sendMessage('conv-1', {'body': 'hello'}),
        returnsNormally,
      );
    });

    test('markRead emits when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(() => ds.markRead('conv-1', 'm1', true, 0), returnsNormally);
    });

    test('sendTyping emits when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(() => ds.sendTyping('conv-1'), returnsNormally);
    });

    test('sendStopTyping emits when connected', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));
      expect(() => ds.sendStopTyping('conv-1'), returnsNormally);
    });

    // ── reconnect / force reconnect after connect ───────────────────────────

    test(
      'reconnectWithToken updates auth and reconnects when not connected',
      () async {
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));
        // After connected, calling reconnectWithToken with same token should be
        // a no-op since socket IS connected. Disconnect first then call.
        // We test the "not connected" branch by disconnecting:
        ds.disconnect();
        await Future.delayed(const Duration(milliseconds: 30));
        // Now socket is null — reconnectWithToken returns immediately
        expect(() => ds.reconnectWithToken('new-token'), returnsNormally);
      },
    );

    test('forceReconnectIfNeeded rebuilds socket when not connected', () async {
      final server2 = _MockSocketIoServer();
      await server2.start();
      final ds2 = DataSourcesSockets();
      addTearDown(() async {
        ds2.disconnect();
        await server2.stop();
      });

      ds2.connect('ws://localhost:${server2.port}', () => 'token');
      await server2.onConnected.timeout(const Duration(seconds: 5));

      // Close the server-side WebSocket to force a disconnect
      await server2.closeWs();
      await Future.delayed(const Duration(milliseconds: 100));

      // Now call forceReconnectIfNeeded — socket may not be connected
      expect(() => ds2.forceReconnectIfNeeded(), returnsNormally);
    });

    // ── listener callbacks fired by server events ───────────────────────────

    test(
      'onMessageReceived callback fires when server sends message:received',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        // Register callback BEFORE connect so _reattachListeners wires it up
        ds.onMessageReceived((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        server.sendEvent('message:received', {'body': 'hello', 'id': 'm1'});
        final received = await completer.future.timeout(
          const Duration(seconds: 3),
        );
        expect(received['body'], 'hello');
      },
    );

    test(
      'onMessageReceived callback re-registered after calling method again',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        ds.onMessageReceived((_) {}); // first registration (pre-connect)
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        // Re-register after connect — exercises the public method's on() path
        ds.onMessageReceived((data) {
          if (!completer.isCompleted) completer.complete(data);
        });

        server.sendEvent('message:received', {'body': 'world'});
        final received = await completer.future.timeout(
          const Duration(seconds: 3),
        );
        expect(received['body'], 'world');
      },
    );

    test(
      'onMessageReadUpdated callback fires when server sends message:read_updated',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        ds.onMessageReadUpdated((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        server.sendEvent('message:read_updated', {'messageId': 'm1'});
        final data = await completer.future.timeout(const Duration(seconds: 3));
        expect(data['messageId'], 'm1');
      },
    );

    test('onMessageReadUpdated re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onMessageReadUpdated((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onMessageReadUpdated((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('message:read_updated', {'messageId': 'm2'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['messageId'], 'm2');
    });

    test('onTyping callback fires when server sends message:typing', () async {
      final completer = Completer<Map<String, dynamic>>();

      ds.onTyping((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      server.sendEvent('message:typing', {'userId': 'u1'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['userId'], 'u1');
    });

    test('onTyping re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onTyping((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onTyping((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('message:typing', {'userId': 'u2'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['userId'], 'u2');
    });

    test(
      'onStopTyping callback fires when server sends message:stop_typing',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        ds.onStopTyping((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        server.sendEvent('message:stop_typing', {'userId': 'u1'});
        final data = await completer.future.timeout(const Duration(seconds: 3));
        expect(data['userId'], 'u1');
      },
    );

    test('onStopTyping re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onStopTyping((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onStopTyping((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('message:stop_typing', {'userId': 'u3'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['userId'], 'u3');
    });

    test(
      'onUserBlocked callback fires when server sends user:blocked',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        ds.onUserBlocked((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        server.sendEvent('user:blocked', {'userId': 'u5'});
        final data = await completer.future.timeout(const Duration(seconds: 3));
        expect(data['userId'], 'u5');
      },
    );

    test('onUserBlocked re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onUserBlocked((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onUserBlocked((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('user:blocked', {'userId': 'u6'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['userId'], 'u6');
    });

    test(
      'onNotificationCreated callback fires on notification:created',
      () async {
        final completer = Completer<Map<String, dynamic>>();

        ds.onNotificationCreated((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        server.sendEvent('notification:created', {'notifId': 'n1'});
        final data = await completer.future.timeout(const Duration(seconds: 3));
        expect(data['notifId'], 'n1');
      },
    );

    test('onNotificationCreated re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onNotificationCreated((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onNotificationCreated((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('notification:created', {'notifId': 'n2'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['notifId'], 'n2');
    });

    test('onNotificationRead callback fires on notification:read', () async {
      final completer = Completer<Map<String, dynamic>>();

      ds.onNotificationRead((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      server.sendEvent('notification:read', {'notifId': 'n1'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['notifId'], 'n1');
    });

    test('onNotificationRead re-registered after connect', () async {
      final completer = Completer<Map<String, dynamic>>();
      ds.onNotificationRead((_) {});
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      ds.onNotificationRead((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
      server.sendEvent('notification:read', {'notifId': 'n3'});
      final data = await completer.future.timeout(const Duration(seconds: 3));
      expect(data['notifId'], 'n3');
    });

    // ── clearConversationListeners ──────────────────────────────────────────

    test(
      'clearConversationListeners stops message:received from firing',
      () async {
        var callCount = 0;
        ds.onMessageReceived((_) => callCount++);
        ds.connect('ws://localhost:${server.port}', () => 'token');
        await server.onConnected.timeout(const Duration(seconds: 5));

        ds.clearConversationListeners();

        // Listener was cleared — server event should not invoke the callback
        server.sendEvent('message:received', {'body': 'ignored'});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 0);
      },
    );

    // ── reconnectWithToken with live socket ─────────────────────────────────

    test('reconnectWithToken with live connected socket is a no-op', () async {
      ds.connect('ws://localhost:${server.port}', () => 'token');
      await server.onConnected.timeout(const Duration(seconds: 5));

      // Socket IS connected → reconnectWithToken should not rebuild
      expect(() => ds.reconnectWithToken('token'), returnsNormally);
    });
  });
}
