import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:get/get.dart';

class WebSocketService extends GetxService {
  static WebSocketService get to => Get.find();

  late WebSocket _webSocket;
  var isConnected = false.obs;
  var connectionStatus = 'Disconnected'.obs;

  // Callback functions for data updates
  Function(Map<String, dynamic>)? onDataReceived;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  // WebSocket URL
  final String wsUrl = 'ws://192.168.0.134:8000/api/v1/realtime/esp32-001';

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  void connect() async {
    try {
      connectionStatus.value = 'Connecting...';

      _webSocket = WebSocket(Uri.parse(wsUrl));

      // Listen for connection state changes
      _webSocket.connection.listen(
        (state) {
          print('WebSocket state: $state');
          if (state.toString().contains('Connected')) {
            isConnected.value = true;
            connectionStatus.value = 'Connected';
            onConnected?.call();
            print('WebSocket Connected to: $wsUrl');
          } else if (state.toString().contains('Disconnected')) {
            isConnected.value = false;
            connectionStatus.value = 'Disconnected';
            onDisconnected?.call();
            print('WebSocket Disconnected');
          }
        },
        onError: (error) {
          isConnected.value = false;
          connectionStatus.value = 'Error: $error';
          onError?.call(error.toString());
          print('WebSocket Error: $error');
        },
      );

      // Listen for messages
      _webSocket.messages.listen(
        (message) {
          try {
            final data = json.decode(message);
            onDataReceived?.call(data);
            print('Received WebSocket data: $data');
          } catch (e) {
            print('Error parsing WebSocket message: $e');
            onError?.call('Failed to parse message: $e');
          }
        },
        onError: (error) {
          print('WebSocket message error: $error');
          onError?.call('Message error: $error');
        },
      );
    } catch (e) {
      isConnected.value = false;
      connectionStatus.value = 'Connection failed: $e';
      onError?.call('Connection failed: $e');
      print('WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    try {
      _webSocket.close();
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      print('WebSocket manually disconnected');
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (isConnected.value) {
      try {
        _webSocket.send(json.encode(message));
        print('Sent WebSocket message: $message');
      } catch (e) {
        print('Error sending WebSocket message: $e');
        onError?.call('Failed to send message: $e');
      }
    } else {
      print('WebSocket not connected, cannot send message');
      onError?.call('WebSocket not connected');
    }
  }

  void reconnect() {
    disconnect();
    Future.delayed(Duration(seconds: 2), () {
      connect();
    });
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
