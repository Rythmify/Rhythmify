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

  void setOnReconnectedToRoom(Function() callback) {
    _onReconnectedToRoom = callback;
  }

  void connect(String url, String Function() getToken) {
    _url = url;
    _getToken = getToken;
    _buildAndConnect();
  }

  void _buildAndConnect() {
    // Dispose old socket cleanly before creating a new one
    _socket?.off('reconnect_attempt');
    _socket?.off('reconnect_failed');
    _socket?.clearListeners();
    _socket?.dispose();
    _socket = null;

    _socket = io.io(
      _url!,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer ${_getToken!()}'})
          .enableReconnection()
          .setReconnectionAttempts(10) // ← was 5
          .setReconnectionDelay(2000) // ← 2s between attempts
          .setReconnectionDelayMax(10000) // ← cap at 10s
          .disableAutoConnect()
          .build(),
    );

    _socket!.io.on('reconnect_attempt', (_) {
      _socket!.auth = {'token': 'Bearer ${_getToken!()}'};
      debugPrint('🔄 reconnect_attempt: auth token refreshed');
    });

    // KEY FIX: after all attempts fail, build a FRESH socket instance.
    // Calling connect() on the old socket after reconnect_failed doesn't
    // work — the Manager is in a terminal state and ignores the call.
    _socket!.io.on('reconnect_failed', (_) {
      debugPrint('⚠️ reconnect_failed — rebuilding socket in 8s');
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 8), () {
        if (_url != null && _getToken != null) {
          debugPrint('🔁 Rebuilding socket with fresh instance');
          _buildAndConnect(); // ← fresh socket, not connect() on stale one
        }
      });
    });

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected');
      _retryTimer?.cancel(); // stop any pending rebuild timer
      if (_currentConversationId != null) {
        debugPrint('🔁 onConnect: rejoining room $_currentConversationId');
        _socket!.emit('message:join', {
          'conversationId': _currentConversationId,
        });
        _onReconnectedToRoom?.call();
      }
    });

    _socket!.onDisconnect((_) => debugPrint('❌ Socket disconnected'));
    _socket!.onConnectError((err) => debugPrint('🚨 Connection error: $err'));
    _socket!.onError((err) => debugPrint('🚨 Socket error: $err'));

    _socket!.connect();
  }

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
    // If not connected yet, onConnect will handle the join
  }

  void leaveConversation(String conversationId) {
    _currentConversationId = null;
    _socket?.emit('message:leave', {'conversationId': conversationId});
  }

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

  void onMessageReceived(Function(Map<String, dynamic>) callback) {
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
    _socket?.off('message:read_updated');
    _socket?.on('message:read_updated', (data) => callback(data));
  }

  void onTyping(Function(Map<String, dynamic>) callback) {
    _socket?.off('message:typing');
    _socket?.on('message:typing', (data) => callback(data));
  }

  void onStopTyping(Function(Map<String, dynamic>) callback) {
    _socket?.off('message:stop_typing');
    _socket?.on('message:stop_typing', (data) => callback(data));
  }

  void clearConversationListeners() {
    _socket?.off('message:received');
    _socket?.off('message:read_updated');
    _onReconnectedToRoom = null;
  }

  void onNotificationCreated(Function(Map<String, dynamic>) callback) {
    _socket?.off('notification:created');
    _socket?.on(
      'notification:created',
      (data) => callback(data as Map<String, dynamic>),
    );
  }

  void onNotificationRead(Function(Map<String, dynamic>) callback) {
    _socket?.off('notification:read');
    _socket?.on(
      'notification:read',
      (data) => callback(data as Map<String, dynamic>),
    );
  }

  /// Called by the socket provider when the Dio interceptor silently refreshes
  /// the access token. Updates the auth header and re-connects if the socket
  /// is not currently connected (e.g. was rejected with the expired token).
  void reconnectWithToken(String token) {
    if (_socket == null) return;
    _socket!.auth = {'token': 'Bearer $token'};
    if (!(_socket!.connected)) {
      debugPrint('🔄 reconnectWithToken: connecting with fresh token');
      // If the socket Manager is exhausted, rebuild entirely
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
    _retryTimer?.cancel();
    _retryTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _url = null;
    _getToken = null;
  }
}
