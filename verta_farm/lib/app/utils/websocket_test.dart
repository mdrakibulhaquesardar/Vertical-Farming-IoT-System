import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';

class WebSocketTest {
  static void testConnection() async {
    const String wsUrl = 'ws://192.168.0.134:8000/api/v1/realtime/esp32-001';

    print('Testing WebSocket connection to: $wsUrl');

    try {
      final webSocket = WebSocket(Uri.parse(wsUrl));

      // Listen for connection state
      webSocket.connection.listen(
        (state) {
          print('Connection state: $state');
        },
        onError: (error) {
          print('Connection error: $error');
        },
      );

      // Listen for messages
      webSocket.messages.listen(
        (message) {
          print('Received message: $message');
          try {
            final data = json.decode(message);
            print('Parsed data: $data');
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('Message error: $error');
        },
      );

      // Keep connection alive for 30 seconds
      await Future.delayed(Duration(seconds: 30));
      webSocket.close();
      print('Test completed');
    } catch (e) {
      print('WebSocket test failed: $e');
    }
  }
}
