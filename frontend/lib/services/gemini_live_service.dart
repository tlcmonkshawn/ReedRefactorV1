import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'package:bootiehunter/services/api_service.dart';

/// Service for managing Gemini Live API connections
///
/// ARCHITECTURE:
/// - Frontend connects DIRECTLY to Google's Gemini Live API via WebSocket
/// - Backend only provides session tokens and executes tool calls
/// - See backend docs for detailed architecture explanation
class GeminiLiveService {
  final ApiService apiService;
  WebSocketChannel? _channel;
  Function(String)? _onTranscript;
  Function(String)? _onAudioData;
  Function(Map<String, dynamic>)? _onToolCall;

  GeminiLiveService({required this.apiService});

  /// Creates a session with the backend and returns session token
  ///
  /// Returns a map with session_token, expires_at, and session_name
  Future<Map<String, dynamic>> createSession() async {
    try {
      final response = await apiService.post('/gemini_live/session');

      if (response.statusCode == 200) {
        return {
          'session_token': response.data['session_token'] as String?,
          'expires_at': response.data['expires_at'] as String?,
          'session_name': response.data['session_name'] as String?,
        };
      }

      throw Exception(
        response.data['error']?['message'] ??
        'Failed to create Gemini Live session',
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['error']?['message'] ??
                           e.message ??
                           'Failed to create Gemini Live session';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// Connects to Gemini Live API WebSocket
  ///
  /// Requires session data from createSession() which includes session_token and session_name
  ///
  /// The WebSocket URL format uses session_name in the path:
  /// wss://generativelanguage.googleapis.com/ws/v1beta/{session_name}/streamGenerateContent?key={session_token}
  ///
  /// Or alternative format:
  /// wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key={session_token}
  Future<void> connect({
    required String sessionToken,
    String? sessionName,
    Function(String)? onTranscript,
    Function(String)? onAudioData,
    Function(Map<String, dynamic>)? onToolCall,
  }) async {
    _onTranscript = onTranscript;
    _onAudioData = onAudioData;
    _onToolCall = onToolCall;

    try {
      // Build WebSocket URL
      // Based on Gemini Live API documentation:
      // Format 1 (with session_name): wss://generativelanguage.googleapis.com/ws/v1beta/{session_name}/streamGenerateContent?key={session_token}
      // Format 2 (alternative): wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key={session_token}
      String wsUrl;

      if (sessionName != null && sessionName.isNotEmpty) {
        // Use session_name in path (preferred method)
        // session_name format: "sessions/abc123" or "sessions/abc123:def456"
        String cleanSessionName = sessionName.replaceFirst('sessions/', '');
        wsUrl = 'wss://generativelanguage.googleapis.com/ws/v1beta/sessions/$cleanSessionName/streamGenerateContent?key=${Uri.encodeComponent(sessionToken)}';
      } else {
        // Fallback: Use BidiGenerateContent endpoint with session token
        wsUrl = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=${Uri.encodeComponent(sessionToken)}';
      }

      final uri = Uri.parse(wsUrl);

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(uri);

      // Listen for incoming messages
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          // TODO: Notify UI of error
        },
        onDone: () {
          print('WebSocket connection closed');
          _channel = null;
          // TODO: Notify UI of disconnection
        },
        cancelOnError: false,
      );
    } catch (e) {
      _channel = null;
      throw Exception('Failed to connect to Gemini Live API: $e');
    }
  }

  /// Handles incoming WebSocket messages
  ///
  /// Messages are JSON-encoded and can contain:
  /// - Audio chunks (for playback)
  /// - Text transcripts
  /// - Tool call requests
  /// - Error messages
  ///
  /// Message format based on Gemini Live API:
  /// - serverContent: Response from Gemini with parts (text, audio, function calls)
  /// - setupComplete: Confirmation that setup was successful
  /// - error: Error messages
  void _handleMessage(dynamic data) {
    try {
      // Parse JSON message
      final message = jsonDecode(data.toString()) as Map<String, dynamic>;

      // Check for serverContent (response from Gemini)
      if (message.containsKey('serverContent')) {
        final serverContent = message['serverContent'] as Map<String, dynamic>?;
        if (serverContent != null) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
          if (modelTurn != null) {
            final parts = modelTurn['parts'] as List<dynamic>?;
            if (parts != null) {
              for (var part in parts) {
                final partMap = part as Map<String, dynamic>;

                // Text part
                if (partMap.containsKey('text')) {
                  final text = partMap['text'] as String?;
                  if (text != null && _onTranscript != null) {
                    _onTranscript!(text);
                  }
                }

                // Audio part (inlineData with audio mimeType)
                if (partMap.containsKey('inlineData')) {
                  final inlineData = partMap['inlineData'] as Map<String, dynamic>?;
                  if (inlineData != null) {
                    final mimeType = inlineData['mimeType'] as String?;
                    final audioData = inlineData['data'] as String?;

                    if (mimeType?.startsWith('audio/') == true && audioData != null && _onAudioData != null) {
                      _onAudioData!(audioData);
                    }
                  }
                }

                // Function call part
                if (partMap.containsKey('functionCall')) {
                  final functionCall = partMap['functionCall'] as Map<String, dynamic>?;
                  if (functionCall != null && _onToolCall != null) {
                    _onToolCall!(functionCall);
                  }
                }
              }
            }
          }
        }
      }

      // Also check for standard Gemini format (candidates array)
      if (message.containsKey('candidates')) {
        final candidates = message['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;

          // Check for content with parts
          if (candidate.containsKey('content')) {
            final content = candidate['content'] as Map<String, dynamic>;
            final parts = content['parts'] as List<dynamic>?;

            if (parts != null) {
              for (var part in parts) {
                final partMap = part as Map<String, dynamic>;

                // Text part
                if (partMap.containsKey('text')) {
                  final text = partMap['text'] as String?;
                  if (text != null && _onTranscript != null) {
                    _onTranscript!(text);
                  }
                }

                // Audio part
                if (partMap.containsKey('inlineData')) {
                  final inlineData = partMap['inlineData'] as Map<String, dynamic>?;
                  if (inlineData != null) {
                    final mimeType = inlineData['mimeType'] as String?;
                    final audioData = inlineData['data'] as String?;

                    if (mimeType?.startsWith('audio/') == true && audioData != null && _onAudioData != null) {
                      _onAudioData!(audioData);
                    }
                  }
                }

                // Function call part
                if (partMap.containsKey('functionCall')) {
                  final functionCall = partMap['functionCall'] as Map<String, dynamic>?;
                  if (functionCall != null && _onToolCall != null) {
                    _onToolCall!(functionCall);
                  }
                }
              }
            }
          }
        }
      }

      // Check for error messages
      if (message.containsKey('error')) {
        final error = message['error'] as Map<String, dynamic>?;
        print('Gemini Live API error: $error');
        // TODO: Notify UI of error
      }

      // Check for setupComplete
      if (message.containsKey('setupComplete')) {
        print('Gemini Live API setup complete');
      }

    } catch (e) {
      print('Error parsing WebSocket message: $e');
      print('Message data: $data');
    }
  }

  /// Sends audio data to Gemini Live API
  ///
  /// Audio should be PCM format (LINEAR16, 16kHz sample rate, mono)
  /// Data should be base64-encoded
  ///
  /// Format: realtimeInput with audio content
  Future<void> sendAudio(List<int> audioData) async {
    if (_channel == null) {
      throw Exception('Not connected to Gemini Live API');
    }

    try {
      // Convert audio bytes to base64
      final base64Audio = base64Encode(audioData);

      // Build message according to Gemini Live API format
      // Format: realtimeInput with audio content
      final message = {
        'realtimeInput': {
          'audio': {
            'config': {
              'encoding': 'LINEAR16',
              'sampleRateHertz': 16000,
              'languageCode': 'en-US',
            },
            'content': base64Audio,
          }
        }
      };

      // Send as JSON string
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      throw Exception('Failed to send audio: $e');
    }
  }

  /// Sends video frame to Gemini Live API
  ///
  /// Image should be JPEG or PNG format, base64-encoded
  ///
  /// Format: realtimeInput with video content or clientContent with image parts
  Future<void> sendVideoFrame(List<int> imageData, {String mimeType = 'image/jpeg'}) async {
    if (_channel == null) {
      throw Exception('Not connected to Gemini Live API');
    }

    try {
      // Convert image bytes to base64
      final base64Image = base64Encode(imageData);

      // Build message according to Gemini Live API format
      // Format: clientContent with image parts
      final message = {
        'clientContent': {
          'turns': [
            {
              'role': 'user',
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Image,
                  }
                }
              ]
            }
          ]
        }
      };

      // Send as JSON string
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      throw Exception('Failed to send video frame: $e');
    }
  }

  /// Executes a tool call via backend
  ///
  /// When Gemini Live API requests a tool call, frontend forwards it here,
  /// which sends it to the backend for execution (database access, etc.)
  ///
  /// Returns the result that should be sent back to Gemini Live API
  Future<Map<String, dynamic>> executeToolCall({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      final response = await apiService.post(
        '/gemini_live/tool_call',
        data: {
          'tool_name': toolName,
          'arguments': arguments,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data as Map<String, dynamic>;

        // Send tool call result back to Gemini Live API
        if (_channel != null && result['success'] == true) {
          _sendToolCallResponse(toolName, result);
        }

        return result;
      }

      throw Exception(
        response.data['error']?['message'] ?? 'Failed to execute tool call',
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['error']?['message'] ??
                           e.message ??
                           'Failed to execute tool call';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// Sends tool call response back to Gemini Live API
  ///
  /// Format: functionResponse with function name and response data
  void _sendToolCallResponse(String functionName, Map<String, dynamic> result) {
    if (_channel == null) return;

    try {
      // Format tool call response according to Gemini Live API spec
      // Format: clientContent with functionResponse
      final message = {
        'clientContent': {
          'turns': [
            {
              'role': 'user',
              'parts': [
                {
                  'functionResponse': {
                    'name': functionName,
                    'response': result['result'] ?? result,
                  }
                }
              ]
            }
          ]
        }
      };

      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending tool call response: $e');
    }
  }

  /// Disconnects from Gemini Live API
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  bool get isConnected => _channel != null;
}
