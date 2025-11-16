import 'package:flutter/foundation.dart';
import 'package:foody_app/data/models/chat_dialogue_model.dart';
import 'package:foody_app/data/services/chat_websocket_service.dart';

class ChatListProvider extends ChangeNotifier {
  final ChatWebSocketService _wsService;
  final Map<String, ChatDialogue> _dialogues = {};
  bool _isLoading = true;
  String? _error;

  List<ChatDialogue> get dialogues {
    final list = _dialogues.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _wsService.isConnected;

  ChatListProvider(String wsUrl) : _wsService = ChatWebSocketService(wsUrl) {
    _initWebSocket();
  }

  void _initWebSocket() async {
    try {
      await _wsService.connect();

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
    } catch (e) {
      _error = 'Failed to connect: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'];
    print('Handling message type: $type');

    try {
      switch (type) {
        case 'initial_dialogues':
        case 'dialogues_list':
          _loadDialogues(data['dialogues']);
          break;

        case 'new_dialogue':
          _addDialogue(ChatDialogue.fromJson(data['dialogue']));
          break;

        case 'dialogue_updated':
        case 'dialogue_update':
          _updateDialogue(ChatDialogue.fromJson(data['dialogue']));
          break;

        case 'new_message':
          _handleNewMessage(data);
          break;

        case 'user_online':
          _updateOnlineStatus(data['dialogueId'], true);
          break;

        case 'user_offline':
          _updateOnlineStatus(data['dialogueId'], false);
          break;

        case 'mark_read_success':
          _markAsReadSuccess(data['dialogueId']);
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

  void _loadDialogues(dynamic dialoguesData) {
    _dialogues.clear();
    if (dialoguesData is List) {
      for (var data in dialoguesData) {
        try {
          final dialogue = ChatDialogue.fromJson(data);
          _dialogues[dialogue.id] = dialogue;
        } catch (e) {
          print('Error parsing dialogue: $e');
        }
      }
    }
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _addDialogue(ChatDialogue dialogue) {
    _dialogues[dialogue.id] = dialogue;
    _isLoading = false;
    notifyListeners();
  }

  void _updateDialogue(ChatDialogue dialogue) {
    _dialogues[dialogue.id] = dialogue;
    notifyListeners();
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final dialogueId = data['dialogueId'];
    final messageText = data['text'] ?? data['message'] ?? '';
    final timestamp = data['timestamp'] != null
        ? DateTime.parse(data['timestamp'])
        : DateTime.now();
    final isMe = data['isMe'] ?? false;

    if (_dialogues.containsKey(dialogueId)) {
      final dialogue = _dialogues[dialogueId]!;
      _dialogues[dialogueId] = dialogue.copyWith(
        lastMessage: messageText,
        timestamp: timestamp,
        unreadCount: isMe ? dialogue.unreadCount : dialogue.unreadCount + 1,
      );
      notifyListeners();
    }
  }

  void _updateOnlineStatus(String dialogueId, bool isOnline) {
    if (_dialogues.containsKey(dialogueId)) {
      final dialogue = _dialogues[dialogueId]!;
      _dialogues[dialogueId] = dialogue.copyWith(isOnline: isOnline);
      notifyListeners();
    }
  }

  void _markAsReadSuccess(String dialogueId) {
    if (_dialogues.containsKey(dialogueId)) {
      final dialogue = _dialogues[dialogueId]!;
      _dialogues[dialogueId] = dialogue.copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  // Public methods for user actions
  void markDialogueAsRead(String dialogueId) {
    _wsService.send({
      'type': 'mark_read',
      'dialogueId': dialogueId,
    });

    // Optimistically update UI
    if (_dialogues.containsKey(dialogueId)) {
      final dialogue = _dialogues[dialogueId]!;
      _dialogues[dialogueId] = dialogue.copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void createNewDialogue(String contactName) {
    _wsService.send({
      'type': 'create_dialogue',
      'contactName': contactName,
    });
  }

  void refreshDialogues() {
    _isLoading = true;
    notifyListeners();
    _wsService.send({'type': 'get_dialogues'});
  }

  void reconnect() {
    _error = null;
    _isLoading = true;
    notifyListeners();
    _wsService.connect();
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}