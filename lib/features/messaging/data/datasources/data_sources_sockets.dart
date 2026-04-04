import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A data source that manages real-time messaging communication using WebSockets.
///
/// This class handles connecting to a WebSocket server, listening for incoming
/// messages, and sending data over the established connection.
class MessagingSocketDatasource {
  late WebSocketChannel _channel;

  /// Establishes a WebSocket connection to the provided [url].
  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  /// A stream of incoming messages from the WebSocket.
  ///
  /// Events are received as JSON strings and decoded into a map.
  Stream<Map<String, dynamic>> get messages {
    return _channel.stream.map((event) => jsonDecode(event as String));
  }

  /// Sends the provided [data] as a JSON-encoded string to the WebSocket server.
  void send(Map<String, dynamic> data) {
    _channel.sink.add(jsonEncode(data));
  }

  /// Closes the active WebSocket connection.
  void disconnect() {
    _channel.sink.close();
  }
}
