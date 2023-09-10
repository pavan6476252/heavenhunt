// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Chat {
  final String chatId; // Unique chat ID
  final List<String> participants; // User and roommate IDs
  final List<Message> messages;
  final String roomId; // Room associated with the chat

  Chat({
    required this.chatId,
    required this.participants,
    required this.messages,
    required this.roomId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatId,
      'participants': participants,
      'messages': messages.map((x) => x.toMap()).toList(),
      'roomId': roomId,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatId: map['chatId'] as String,
      participants: List<String>.from(map['participants'] as List<dynamic>),
      messages: List<Message>.from((map['messages'] as List<dynamic>).map<Message>((x) => Message.fromMap(x as Map<String, dynamic>))),
      roomId: map['roomId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) => Chat.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Message {
  final String messageId; // Unique message ID
  final String senderId; // User or roommate ID
  final String content;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String).toLocal(),
    );
  }
}
