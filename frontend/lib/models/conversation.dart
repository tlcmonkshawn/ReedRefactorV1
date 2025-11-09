class Conversation {
  final int id;
  final String conversationType; // voice, video, text
  final String? participantType; // reed, bootie_boss, admin, player
  final String? contextSummary;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.conversationType,
    this.participantType,
    this.contextSummary,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      conversationType: json['conversation_type'] as String,
      participantType: json['participant_type'] as String?,
      contextSummary: json['context_summary'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isVoice => conversationType == 'voice';
  bool get isVideo => conversationType == 'video';
  bool get isText => conversationType == 'text';
  bool get isReed => participantType == 'reed';
}

