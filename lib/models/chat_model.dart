import 'dart:convert';

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String mode;
  final MessageType type;
  final String? imagePath;
  final String? filePath;

  Message({
    String? id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.mode,
    this.type = MessageType.text,
    this.imagePath,
    this.filePath,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'mode': mode,
    'type': type.index,
    'imagePath': imagePath,
    'filePath': filePath,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    mode: json['mode'],
    type: MessageType.values[json['type'] ?? 0],
    imagePath: json['imagePath'],
    filePath: json['filePath'],
  );
}

enum MessageType { text, image, file, voice }

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String mode;
  final List<Message> messages;

  ChatSession({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.mode,
    List<Message>? messages,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now(),
    messages = messages ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'mode': mode,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'],
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    mode: json['mode'],
    messages: (json['messages'] as List?)
        ?.map((m) => Message.fromJson(m))
        .toList() ?? [],
  );

  ChatSession copyWith({
    String? title,
    DateTime? updatedAt,
    String? mode,
    List<Message>? messages,
  }) => ChatSession(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    mode: mode ?? this.mode,
    messages: messages ?? this.messages,
  );
}
