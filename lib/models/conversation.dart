import 'user.dart';

class Conversation {
  final int id;
  final String? title;
  final List<int> participants;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Message>? messages;
  final List<User>? participantsUsers;

  Conversation({
    required this.id,
    this.title,
    required this.participants,
    this.createdAt,
    this.updatedAt,
    this.messages,
    this.participantsUsers,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      participants: List<int>.from(json['participants']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      messages: json['messages'] != null ? (json['messages'] as List).map((m) => Message.fromJson(m)).toList() : null,
      participantsUsers: json['participants_users'] != null ? (json['participants_users'] as List).map((u) => User.fromJson(u)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participants': participants,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'messages': messages?.map((m) => m.toJson()).toList(),
      'participants_users': participantsUsers?.map((u) => u.toJson()).toList(),
    };
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String? content;
  final List<String>? attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? sender;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.attachments,
    this.createdAt,
    this.updatedAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'attachments': attachments,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }
}