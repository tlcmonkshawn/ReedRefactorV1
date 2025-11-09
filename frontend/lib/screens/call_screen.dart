import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootiehunter/services/gemini_live_service.dart';

class CallScreen extends StatefulWidget {
  final String contactName;
  final String contactType;

  const CallScreen({
    super.key,
    required this.contactName,
    required this.contactType,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isVideoEnabled = false;
  bool _isCallActive = false;
  bool _isConnecting = true;
  List<String> _transcripts = []; // Store transcripts for display

  @override
  void initState() {
    super.initState();
    _connectToGeminiLive();
  }

  Future<void> _connectToGeminiLive() async {
    if (widget.contactType != 'reed') {
      setState(() {
        _isConnecting = false;
        _isCallActive = true;
      });
      return;
    }

    try {
      final geminiService = context.read<GeminiLiveService>();

      // Get session token from backend
      final sessionData = await geminiService.createSession();
      final sessionToken = sessionData['session_token'] as String?;
      final sessionName = sessionData['session_name'] as String?;

      if (sessionToken == null) {
        throw Exception('No session token received from backend');
      }

      // Connect to Gemini Live API
      await geminiService.connect(
        sessionToken: sessionToken,
        sessionName: sessionName,
        onTranscript: (transcript) {
          // Display transcript in UI
          if (mounted) {
            setState(() {
              _transcripts.add(transcript);
            });
          }
          print('Transcript: $transcript');
        },
        onAudioData: (audioData) {
          // Audio playback would require an audio player package (e.g., just_audio)
          // For MVP, we'll just log it - audio playback can be added post-launch
          // TODO: Post-MVP - Add audio playback using just_audio package
          // 1. Decode base64 audio data
          // 2. Use AudioPlayer to play the audio
          print('Audio data received (${audioData.length} bytes)');
        },
        onToolCall: (toolCall) async {
          // Handle tool calls - forward to backend
          try {
            // Extract function name and arguments
            final functionName = toolCall['name'] as String?;
            final args = toolCall['args'] as Map<String, dynamic>? ?? {};

            if (functionName == null) {
              print('Tool call missing function name: $toolCall');
              return;
            }

            final result = await geminiService.executeToolCall(
              toolName: functionName,
              arguments: args,
            );

            // Result is automatically sent back to Gemini Live API by executeToolCall
            print('Tool call executed: $functionName');
            print('Result: $result');
          } catch (e) {
            print('Tool call error: $e');
            // Error handling is done in GeminiLiveService.executeToolCall
            // It will send an error response back to the API automatically
          }
        },
      );

      setState(() {
        _isConnecting = false;
        _isCallActive = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    if (widget.contactType == 'reed') {
      context.read<GeminiLiveService>().disconnect();
    }
    super.dispose();
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                  const Spacer(),
                  if (_isVideoEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Video',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Contact info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.contactName[0],
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnecting
                        ? 'Connecting...'
                        : _isCallActive
                            ? (_isVideoEnabled ? 'Video call' : 'Voice call')
                            : 'Call ended',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (widget.contactType == 'reed') ...[
                    const SizedBox(height: 8),
                    Text(
                      'R.E.E.D. 8',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  // Show transcripts if available
                  if (_transcripts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _transcripts.map((transcript) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                transcript,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Call controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera toggle button
                  _CallButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    backgroundColor: Colors.grey[800]!,
                    onPressed: _toggleVideo,
                  ),
                  // End call button
                  _CallButton(
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                    isLarge: true,
                  ),
                  // Mute button (placeholder)
                  _CallButton(
                    icon: Icons.mic,
                    backgroundColor: Colors.grey[800]!,
                    onPressed: () {
                      // TODO: Post-MVP - Implement mute functionality
                      // This would require microphone access and audio stream control
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final bool isLarge;

  const _CallButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 64.0 : 56.0;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isLarge ? 32 : 24,
        ),
      ),
    );
  }
}
