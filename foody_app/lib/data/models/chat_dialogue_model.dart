class ChatDialogue {
  final String id;
  final String contactName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String? avatarUrl;
  final bool isOnline;

  ChatDialogue({
    required this.id,
    required this.contactName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    this.avatarUrl,
    required this.isOnline,
  });

  factory ChatDialogue.fromJson(Map<String, dynamic> json) {
    return ChatDialogue(
      id: json['id'],
      contactName: json['contactName'],
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['timestamp']),
      unreadCount: json['unreadCount'] ?? 0,
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'unreadCount': unreadCount,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    };
  }

  ChatDialogue copyWith({
    String? id,
    String? contactName,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return ChatDialogue(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}