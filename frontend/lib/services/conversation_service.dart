import 'package:bootiehunter/services/api_service.dart';
import 'package:bootiehunter/models/conversation.dart';
import 'package:bootiehunter/models/message.dart';

class ConversationService {
  final ApiService apiService;

  ConversationService({required this.apiService});

  Future<List<Conversation>> getConversations() async {
    final response = await apiService.get('/conversations');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load conversations');
  }

  Future<Conversation> getConversation(int id) async {
    final response = await apiService.get('/conversations/$id');

    if (response.statusCode == 200) {
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to load conversation');
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final response = await apiService.get('/conversations/$conversationId/messages');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load messages');
  }

  Future<Message> sendMessage(int conversationId, String content) async {
    final response = await apiService.post(
      '/conversations/$conversationId/messages',
      data: {
        'message': {
          'content': content,
          'sender_type': 'user',
          'message_type': 'text',
        }
      },
    );

    if (response.statusCode == 201) {
      return Message.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to send message');
  }

  Future<Conversation> createConversation({
    required String conversationType,
    String? participantType,
  }) async {
    final response = await apiService.post(
      '/conversations',
      data: {
        'conversation': {
          'conversation_type': conversationType,
          'participant_type': participantType,
        }
      },
    );

    if (response.statusCode == 201) {
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to create conversation');
  }
}

