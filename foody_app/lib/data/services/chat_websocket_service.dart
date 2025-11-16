import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final String wsUrl;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnecting = false;
  bool _isManuallyDisconnected = false;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  ChatWebSocketService(this.wsUrl);

  Future<void> connect() async {
    if (_isConnecting || _isManuallyDisconnected) return;
    _isConnecting = true;

    try {
      print('Connecting to WebSocket: $wsUrl'); // Delete on prod
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
            (message) {
          try {
            final decoded = jsonDecode(message) as Map<String, dynamic>;
            print('WebSocket received: ${decoded['type']}'); // Delete on prod
            _messageController.add(decoded);
          } catch (e) {
            print('Error decoding message: $e'); // Delete on prod
          }
        },
        onError: (error) {
          print('WebSocket error: $error'); // Delete on prod
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket connection closed'); // Delete on prod
          _handleDisconnection();
        },
      );

      _isConnecting = false;
      _startPingTimer();
      print('WebSocket connected successfully'); // Delete on prod

      send({'type': 'get_dialogues'});

    } catch (e) {
      print('Failed to connect: $e'); // Delete on prod
      _isConnecting = false;
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _channel = null;
    _pingTimer?.cancel();
    if (!_isManuallyDisconnected) {
      _reconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        send({'type': 'ping'});
      }
    });
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      print('Attempting to reconnect...'); // Delete on prod
      connect();
    });
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(data));
        print('WebSocket sent: ${data['type']}'); // Delete on prod
      } catch (e) {
        print('Error sending message: $e'); // Delete on prod
      }
    } else {
      print('Cannot send message: WebSocket not connected'); // Delete on prod
    }
  }

  void disconnect() {
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}