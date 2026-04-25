import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DataSourcesSockets {
  io.Socket? _socket;
  String? _currentConversationId;
  Function()? _onReconnectedToRoom;

  void setOnReconnectedToRoom(Function() callback) {
    _onReconnectedToRoom = callback;
  }

  void connect(String url, String token) {
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      if (_currentConversationId != null) {
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
    if (_socket?.connected == true) {
      _socket!.emit('message:join', {'conversationId': conversationId});
    }
    else{
      print('⚠️  joinConversation called but socket not connected');
    }
    // If not connected yet, onConnect will handle the join
  }

  void leaveConversation(String conversationId) {
    _currentConversationId = null;
    _socket?.emit('message:leave', {'conversationId': conversationId});
  }

  void sendMessage(String conversationId, Map<String, dynamic> message) {
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
    _socket?.on('message:received', (data) => callback(data));
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

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
