import 'package:socket_io_client/socket_io_client.dart' as IO;

class DataSourcesSockets {
  late IO.Socket _socket;

  void connect(String url, String token) {
    print('🔌 Connecting socket with token: ${token.substring(0, 20)}...');
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) => print('✅ Socket connected'));
    _socket.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket.on('error', (data) => print('⚠️ Socket error: $data'));
    _socket.connect();
  }

  void joinConversation(String conversationId) {
    _socket.emit('message:join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket.emit('message:leave', {'conversationId': conversationId});
  }

  void sendMessage(String conversationId, Map<String, dynamic> message) {
    _socket.emit('message:send', {
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
    _socket.emit('message:read', {
      'conversationId': conversationId,
      'messageId': messageId,
      'isRead': isRead,
      'conversationUnreadCount': unreadCount,
    });
  }

  void sendTyping(String conversationId) {
    _socket.emit('message:typing', {'conversationId': conversationId});
  }

  void sendStopTyping(String conversationId) {
    _socket.emit('message:stop_typing', {'conversationId': conversationId});
  }

  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    _socket.off('message:received');
    _socket.on('message:received', (data) => callback(data));
  }

  void onMessageReadUpdated(Function(Map<String, dynamic>) callback) {
    _socket.off('message:read_updated');
    _socket.on('message:read_updated', (data) => callback(data));
  }

  void onTyping(Function(Map<String, dynamic>) callback) {
    _socket.on('message:typing', (data) => callback(data));
  }

  void onStopTyping(Function(Map<String, dynamic>) callback) {
    _socket.on('message:stop_typing', (data) => callback(data));
  }

  void disconnect() {
    _socket.disconnect();
  }
}
