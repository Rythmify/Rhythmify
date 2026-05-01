import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DataSourcesSockets {
  io.Socket? _socket;
  String? _currentConversationId;
  Function()? _onReconnectedToRoom;

  String? _url;
  String Function()? _getToken;
  Timer? _retryTimer;
  Timer? _healthCheckTimer;

  // ── Persistent callbacks ──────────────────────────────────────────────────
  // Stored as fields so they survive every _buildAndConnect() rebuild.
  // Without this, any time the socket is torn down and recreated (health-check,
  // token refresh, transport close) the new socket has zero listeners and
  // messages / read-receipts are silently dropped.
  Function(Map<String, dynamic>)? _onMessageReceived;
  Function(Map<String, dynamic>)? _onMessageReadUpdated;
  Function(Map<String, dynamic>)? _onTyping;
  Function(Map<String, dynamic>)? _onStopTyping;
  Function(Map<String, dynamic>)? _onUserBlocked;
  Function(Map<String, dynamic>)? _onNotificationCreated;
  Function(Map<String, dynamic>)? _onNotificationRead;
  // Fired whenever inbox data may have changed (new notification, user:blocked).
  // Kept separate so it survives clearConversationListeners().
  VoidCallback? _onConversationUpdated;

  void setOnReconnectedToRoom(Function() callback) {
    _onReconnectedToRoom = callback;
  }

  void connect(String url, String Function() getToken) {
    _url = url;
    _getToken = getToken;
    _buildAndConnect();
    _startHealthCheck();
  }

  /// Periodic safety net: if the socket is still not connected after 60 s AND
  /// the socket.io Manager is not already in the middle of a reconnect backoff,
  /// tear it down and build a fresh one.
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_url == null || _getToken == null) return;
      if (!(_socket?.connected ?? false)) {
        debugPrint('💓 Health check: not connected after 60s — rebuilding');
        _buildAndConnect();
      } else {
        debugPrint('💓 Health check: connected — skipping rebuild');
      }
    });
  }

  void _buildAndConnect() {
    _retryTimer?.cancel();

    // Tear down the old socket cleanly.
    _socket?.io.off('reconnect_attempt');
    _socket?.io.off('reconnect_failed');
    _socket?.clearListeners();
    _socket?.dispose();
    _socket = null;

    _socket = io.io(
      _url!,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer ${_getToken!()}'})
          .enableReconnection()
          .setReconnectionAttempts(999999) // effectively infinite
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(30000) // cap backoff at 30 s
          .disableAutoConnect()
          .build(),
    );

    _socket!.io.on('reconnect_attempt', (_) {
      _socket!.auth = {'token': 'Bearer ${_getToken!()}'};
      debugPrint('🔄 reconnect_attempt: auth token refreshed');
    });

    _socket!.io.on('reconnect_failed', (_) {
      debugPrint('⚠️ reconnect_failed — rebuilding socket in 5s');
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 5), () {
        if (_url != null && _getToken != null) {
          debugPrint('🔁 Rebuilding socket with fresh instance');
          _buildAndConnect();
        }
      });
    });

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected | id=${_socket?.id}');
      _retryTimer?.cancel();
      // Subscribe to the user's notification room on every (re)connect.
      // The backend auto-joins via registerNotificationHandlers, but emitting
      // this is a defensive fallback for cases where that handler fires after
      // the connect event.
      _socket!.emit('notification:subscribe');
      debugPrint('📬 notification:subscribe emitted');
      // Re-join the conversation room that was active before the rebuild.
      if (_currentConversationId != null) {
        debugPrint('🔁 onConnect: rejoining room $_currentConversationId');
        _socket!.emit('message:join', {
          'conversationId': _currentConversationId,
        });
        _onReconnectedToRoom?.call();
      }
    });

    _socket!.onDisconnect((reason) {
      debugPrint('❌ Socket disconnected: $reason');
    });

    _socket!.onConnectError((err) => debugPrint('🚨 Connection error: $err'));
    _socket!.onError((err) => debugPrint('🚨 Socket error: $err'));

    // Re-attach every stored callback to the brand-new socket instance.
    _reattachListeners();

    _socket!.connect();
  }

  /// Registers all stored callbacks onto the current [_socket].
  /// Called at the end of every [_buildAndConnect] so listeners always survive
  /// socket rebuilds triggered by health-checks, token refreshes, etc.
  void _reattachListeners() {
    final s = _socket;
    if (s == null) return;

    if (_onMessageReceived != null) {
      s.off('message:received');
      s.on('message:received', (data) {
        debugPrint(
          '📨 RAW message:received | type=${data.runtimeType} | data=$data',
        );
        _onMessageReceived!(data as Map<String, dynamic>);
      });
    }

    if (_onMessageReadUpdated != null) {
      s.off('message:read_updated');
      s.on('message:read_updated', (data) {
        _onMessageReadUpdated!(data as Map<String, dynamic>);
      });
    }

    if (_onTyping != null) {
      s.off('message:typing');
      s.on('message:typing', (data) {
        _onTyping!(data as Map<String, dynamic>);
      });
    }

    if (_onStopTyping != null) {
      s.off('message:stop_typing');
      s.on('message:stop_typing', (data) {
        _onStopTyping!(data as Map<String, dynamic>);
      });
    }

    if (_onUserBlocked != null) {
      s.off('user:blocked');
      s.on('user:blocked', (data) {
        _onUserBlocked!(data as Map<String, dynamic>);
      });
    }

    if (_onNotificationCreated != null) {
      s.off('notification:created');
      s.on('notification:created', (data) {
        debugPrint('🔔 RAW notification:created | type=${data.runtimeType} | data=$data');
        _onNotificationCreated!(data as Map<String, dynamic>);
      });
    }

    if (_onNotificationRead != null) {
      s.off('notification:read');
      s.on('notification:read', (data) {
        debugPrint('🔕 RAW notification:read | type=${data.runtimeType} | data=$data');
        _onNotificationRead!(data as Map<String, dynamic>);
      });
    }

    debugPrint('🔁 _reattachListeners: listeners re-bound to socket=${s.id}');
  }

  // ── Room management ───────────────────────────────────────────────────────

  void joinConversation(String conversationId) {
    _currentConversationId = conversationId;
    debugPrint(
      '🚪 joinConversation: $conversationId | connected=${_socket?.connected}',
    );
    if (_socket?.connected == true) {
      _socket!.emit('message:join', {'conversationId': conversationId});
      debugPrint('📤 message:join emitted for $conversationId');
    } else {
      debugPrint(
        '⚠️  joinConversation: socket not connected — onConnect will join',
      );
    }
  }

  void leaveConversation(String conversationId) {
    _currentConversationId = null;
    _socket?.emit('message:leave', {'conversationId': conversationId});
  }

  // ── Emit helpers ──────────────────────────────────────────────────────────

  void sendMessage(String conversationId, Map<String, dynamic> message) {
    debugPrint('📤 message:send | convId=$conversationId | msg=$message');
    _socket?.emit('message:send', {
      'conversationId': conversationId,
      'message': message,
    });
  }

  void markRead(
    String conversationId,
    String messageId,
    bool isRead,
    int unreadCount,
  ) {
    _socket?.emit('message:read', {
      'conversationId': conversationId,
      'messageId': messageId,
      'isRead': isRead,
      'conversationUnreadCount': unreadCount,
    });
  }

  void sendTyping(String conversationId) {
    _socket?.emit('message:typing', {'conversationId': conversationId});
  }

  void sendStopTyping(String conversationId) {
    _socket?.emit('message:stop_typing', {'conversationId': conversationId});
  }

  // ── Listener registration — stores callback AND registers on current socket ─

  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    _onMessageReceived = callback;
    _socket?.off('message:received');
    _socket?.on('message:received', (data) {
      debugPrint(
        '📨 RAW message:received | type=${data.runtimeType} | data=$data',
      );
      callback(data as Map<String, dynamic>);
    });
    debugPrint(
      '👂 onMessageReceived listener registered | socket=${_socket?.id}',
    );
  }

  void onMessageReadUpdated(Function(Map<String, dynamic>) callback) {
    _onMessageReadUpdated = callback;
    _socket?.off('message:read_updated');
    _socket?.on('message:read_updated', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onTyping(Function(Map<String, dynamic>) callback) {
    _onTyping = callback;
    _socket?.off('message:typing');
    _socket?.on('message:typing', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onStopTyping(Function(Map<String, dynamic>) callback) {
    _onStopTyping = callback;
    _socket?.off('message:stop_typing');
    _socket?.on('message:stop_typing', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onUserBlocked(Function(Map<String, dynamic>) callback) {
    _onUserBlocked = callback;
    _socket?.off('user:blocked');
    _socket?.on('user:blocked', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  void onNotificationCreated(Function(Map<String, dynamic>) callback) {
    _onNotificationCreated = callback;
    _socket?.off('notification:created');
    _socket?.on('notification:created', (data) {
      debugPrint('🔔 RAW notification:created | type=${data.runtimeType} | data=$data');
      callback(data as Map<String, dynamic>);
    });
    debugPrint('👂 onNotificationCreated listener registered | socket=${_socket?.id}');
  }

  void onNotificationRead(Function(Map<String, dynamic>) callback) {
    _onNotificationRead = callback;
    _socket?.off('notification:read');
    _socket?.on('notification:read', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  /// Clears conversation-scoped listeners AND their stored callbacks so they
  /// are not re-attached on the next socket rebuild.
  void clearConversationListeners() {
    _onMessageReceived = null;
    _onMessageReadUpdated = null;
    _onUserBlocked = null;
    _onReconnectedToRoom = null;
    _socket?.off('message:received');
    _socket?.off('message:read_updated');
    _socket?.off('user:blocked');
  }

  // ── Token / reconnect helpers ─────────────────────────────────────────────

  /// Called by the socket provider when the Dio interceptor silently refreshes
  /// the access token. Updates auth and reconnects if the socket is not live.
  void reconnectWithToken(String token) {
    if (_socket == null) return;
    _socket!.auth = {'token': 'Bearer $token'};
    if (!(_socket!.connected)) {
      debugPrint('🔄 reconnectWithToken: connecting with fresh token');
      if (_url != null && _getToken != null) {
        _buildAndConnect();
      } else {
        _socket!.connect();
      }
    }
  }

  void forceReconnectIfNeeded() {
    if (_socket == null || _url == null) return;
    if (!(_socket!.connected)) {
      debugPrint('📲 App resumed — rebuilding socket');
      _buildAndConnect();
    }
  }

  void disconnect() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _socket?.io.off('reconnect_attempt');
    _socket?.io.off('reconnect_failed');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _url = null;
    _getToken = null;
  }
}
