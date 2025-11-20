// lib/data/providers/chat_conversation_provider.dart
import 'package:flutter/foundation.dart';
import 'package:foody_app/data/models/chat_message_model.dart';
import 'package:foody_app/data/services/chat_websocket_service.dart';

class ChatConversationProvider extends ChangeNotifier {
  final ChatWebSocketService _wsService;
  final String dialogueId;
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _error;
  bool _isOnline = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _wsService.isConnected;
  bool get isOnline => _isOnline;

  ChatConversationProvider(this._wsService, this.dialogueId) {
    _initWebSocket();
  }

  void _initWebSocket() async {
    // If not connected, connect first
    if (!_wsService.isConnected) {
      try {
        await _wsService.connect();
      } catch (e) {
        _error = 'Failed to connect: $e';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // Request messages for this dialogue
    _wsService.getMessages(dialogueId);

    // Listen to all WebSocket messages
    _wsService.messages.listen(
          (data) {
        _handleWebSocketMessage(data);
      },
      onError: (error) {
        _error = 'Connection error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'];
    print('Handling message type: $type');

    try {
      switch (type) {
        case 'message_history':
        // Check if this message history is for our dialogue
          if (data['dialogueId'] == dialogueId) {
            _loadMessageHistory(data['messages']);
          }
          break;

        case 'new_message':
        // Check if this message is for our dialogue
          if (data['dialogueId'] == dialogueId) {
            _addNewMessage(data);
          }
          break;

        case 'message_sent':
          if (data['dialogueId'] == dialogueId) {
            _updateMessageStatus(data);
          }
          break;

        case 'message_delivered':
          if (data['dialogueId'] == dialogueId) {
            _markMessageDelivered(data['messageId']);
          }
          break;

        case 'message_read':
          if (data['dialogueId'] == dialogueId) {
            _markMessageRead(data['messageId']);
          }
          break;

        case 'user_online':
          if (data['dialogueId'] == dialogueId) {
            _isOnline = true;
            notifyListeners();
          }
          break;

        case 'user_offline':
          if (data['dialogueId'] == dialogueId) {
            _isOnline = false;
            notifyListeners();
          }
          break;

        case 'typing':
        // Handle typing indicator if needed
          break;

        case 'error':
          _error = data['message'] ?? 'Unknown error';
          notifyListeners();
          break;

        case 'pong':
        // Heartbeat response
          break;

        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling message: $e');
      _error = 'Error processing message: $e';
      notifyListeners();
    }
  }

  void _loadMessageHistory(dynamic messagesData) {
    _messages.clear();
    if (messagesData is List) {
      for (var data in messagesData) {
        try {
          final message = ChatMessage.fromJson(data);
          _messages.add(message);
        } catch (e) {
          print('Error parsing message: $e');
        }
      }
      // Sort by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _addNewMessage(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data);

      // Check if message already exists (avoid duplicates)
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.add(message);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error adding new message: $e');
    }
  }

  void _updateMessageStatus(Map<String, dynamic> data) {
    final tempId = data['tempId'];
    final messageId = data['messageId'];

    if (tempId != null && messageId != null) {
      final index = _messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          id: messageId,
          isDelivered: true,
        );
        notifyListeners();
      }
    }
  }

  void _markMessageDelivered(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isDelivered: true);
      notifyListeners();
    }
  }

  void _markMessageRead(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        isDelivered: true,
        isRead: true,
      );
      notifyListeners();
    }
  }

  // Public methods
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add optimistic message
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = ChatMessage(
      id: tempId,
      text: text.trim(),
      isSentByMe: true,
      timestamp: DateTime.now(),
      isDelivered: false,
      isRead: false,
    );

    _messages.add(optimisticMessage);
    notifyListeners();

    // Send to server
    _wsService.sendMessage(dialogueId, text.trim());
  }

  void markAsRead() {
    _wsService.markDialogueAsRead(dialogueId);
  }

  void reconnect() {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _wsService.connect();
  }

  @override
  void dispose() {
    // Don't dispose the service here since it's shared
    // Just clean up the listener
    super.dispose();
  }
}