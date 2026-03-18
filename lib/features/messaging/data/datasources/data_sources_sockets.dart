import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingSocketDatasource {
  late WebSocketChannel _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );
  }

  Stream<Map<String, dynamic>> get messages {
    return _channel.stream.map(
      (event) => jsonDecode(event as String),
    );
  }

  void send(Map<String, dynamic> data) {
    _channel.sink.add(
      jsonEncode(data),
    );
  }

  void disconnect() {
    _channel.sink.close();
  }
}