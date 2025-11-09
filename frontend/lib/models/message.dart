class Message {
  final int id;
  final int conversationId;
  final String senderType; // user, reed, system
  final String content;
  final String messageType; // text, audio, image, system
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.content,
    required this.messageType,
    required this.read,
    required this.createdAt,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderType: json['sender_type'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isFromUser => senderType == 'user';
  bool get isFromReed => senderType == 'reed';
  bool get isSystem => senderType == 'system';
}

