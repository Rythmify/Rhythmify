import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DataSourcesSockets {
  io.Socket? _socket;
  String? _currentConversationId;
  Function()? _onReconnectedToRoom;

  void setOnReconnectedToRoom(Function() callback) {
    _onReconnectedToRoom = callback;
  }

  void connect(String url, String Function() getToken) {
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer ${getToken()}'})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .disableAutoConnect()
          .build(),
    );

    // Refresh the auth token before each automatic reconnect attempt.
    // Must be registered on the Manager (socket.io), not the Socket itself —
    // the Dart socket_io_client fires reconnect_attempt on the Manager.
    _socket!.io.on('reconnect_attempt', (_) {
      _socket!.auth = {'token': 'Bearer ${getToken()}'};
      debugPrint('🔄 reconnect_attempt: auth token refreshed');
    });

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected');
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
    debugPrint('🚪 joinConversation: $conversationId | connected=${_socket?.connected}');
    if (_socket?.connected == true) {
      _socket!.emit('message:join', {'conversationId': conversationId});
      debugPrint('📤 message:join emitted for $conversationId');
    } else {
      debugPrint('⚠️  joinConversation: socket not connected — onConnect will join');
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
      debugPrint('📨 RAW message:received | type=${data.runtimeType} | data=$data');
      callback(data as Map<String, dynamic>);
    });
    debugPrint('👂 onMessageReceived listener registered | socket=${_socket?.id}');
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

  void clearConversationListeners(){
    _socket?.off('message:received');
    _socket?.off('message:read_updated');
    _onReconnectedToRoom=null;
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
      _socket!.connect();
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
