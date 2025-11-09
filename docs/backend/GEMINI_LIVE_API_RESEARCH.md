# Gemini Live API Research Documentation

**Date:** 2025-01-27
**Purpose:** Research Gemini Live API WebSocket implementation details

---

## 📚 Official Documentation Resources

### Primary Documentation Sites:
1. **Main Gemini API Docs:** https://ai.google.dev/gemini-api/docs
2. **API Reference:** https://ai.google.dev/api
3. **SDKs & Libraries:** https://ai.google.dev/gemini-api/docs/libraries
4. **Google AI Studio:** https://ai.google.dev/guide

### Specific Pages to Check:
- https://ai.google.dev/gemini-api/docs/live (if exists)
- https://ai.google.dev/gemini-api/docs/streaming
- https://ai.google.dev/api#live (if exists)
- Search documentation for "real-time" or "bidirectional streaming"

---

## 🔍 What We Know

### Backend Implementation (Rails):
```ruby
# Session Creation
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-native-audio-preview-09-2025:createSession?key=API_KEY

# Request Body:
{
  "model": "gemini-2.5-flash-native-audio-preview-09-2025",
  "voice_config": { "voice": "zephyr" },
  "system_instruction": { "parts": [{ "text": "..." }] },
  "tools": [{ "function_declarations": [...] }],
  "generation_config": {
    "response_modalities": ["AUDIO", "TEXT"],
    "speech_config": { "voice_config": { "voice": "zephyr" } }
  }
}

# Response (expected):
{
  "session_token": "...",
  "session_name": "sessions/...",
  "expires_at": "..."
}
```

---

## ❓ What We Need to Find

### 1. WebSocket Connection Details

**Questions:**
- What is the exact WebSocket URL format?
- How is the session token used for authentication?
- Is the token in the URL query parameter or header?
- What is the connection protocol?

**Possible URL Patterns:**
```
wss://generativelanguage.googleapis.com/ws/v1beta/{session_name}/streamGenerateContent?key=API_KEY
wss://generativelanguage.googleapis.com/ws/v1beta/models/{model}:streamGenerateContent?key=API_KEY&session={session_token}
```

### 2. Message Protocol

**Questions:**
- What is the message format (JSON structure)?
- How are messages structured?
- What are the message types?
- How to send audio chunks?
- How to send video frames?
- How to receive responses?

**Expected Message Types:**
- Audio input chunks
- Video frame input
- Audio output chunks
- Text transcript output
- Tool call requests
- Tool call responses
- Error messages

### 3. Audio/Video Format

**Questions:**
- Audio encoding (PCM, Opus, WebM, etc.)?
- Sample rate requirements?
- Bit depth requirements?
- Channel configuration (mono/stereo)?
- Video encoding (JPEG, H.264, VP8, etc.)?
- Frame size requirements?
- Frame rate requirements?

### 4. Tool Calls

**Questions:**
- How are tool calls sent from Gemini?
- Message format for tool calls?
- How to respond to tool calls?
- Result format for tool call responses?

### 5. Error Handling

**Questions:**
- Error message format?
- Reconnection logic?
- Timeout handling?
- Connection state management?

---

## 🔄 Implementation Approach

### Step 1: Check Official SDKs

**JavaScript/TypeScript SDK:**
```bash
# Check npm package
npm info @google/genai

# Look for examples
# Check GitHub: google/generative-ai-js
```

**Python SDK:**
```bash
# Check package
pip show google-genai

# Look for examples
# Check GitHub: google/generative-ai-python
```

### Step 2: Review SDK Source Code

If SDKs are available:
- Check SDK source code for WebSocket implementation
- Look for Live API examples
- Review message format handling

**GitHub Repositories:**
- https://github.com/google/generative-ai-js
- https://github.com/google/generative-ai-python
- https://github.com/google/generative-ai-docs

### Step 3: Test with API Directly

**Manual Testing:**
1. Create session via REST API (already working)
2. Try WebSocket connection with session token
3. Send test messages
4. Inspect responses

**Tools:**
- Postman (WebSocket support)
- wscat (command-line WebSocket client)
- Browser DevTools (WebSocket inspector)

### Step 4: Alternative Approaches

If WebSocket not available:
1. **HTTP Streaming:**
   - Use `streamGenerateContent` endpoint
   - Server-Sent Events (SSE)
   - Polling approach

2. **Use Official SDK:**
   - Wait for Flutter/Dart SDK
   - Use platform channels to call native SDK
   - Use JavaScript SDK via web platform

---

## 📋 Research Checklist

### Documentation:
- [ ] Check https://ai.google.dev/gemini-api/docs/live
- [ ] Review API reference for WebSocket endpoints
- [ ] Search docs for "real-time" or "streaming"
- [ ] Check model-specific documentation

### SDK Analysis:
- [ ] Review JavaScript/TypeScript SDK
- [ ] Review Python SDK
- [ ] Look for WebSocket examples
- [ ] Check SDK source code

### Testing:
- [ ] Create test session
- [ ] Test WebSocket connection
- [ ] Inspect message format
- [ ] Test audio/video streaming

---

## 🎯 Next Actions

1. **Immediate:**
   - Visit https://ai.google.dev/gemini-api/docs/live
   - Check JavaScript SDK documentation
   - Review SDK examples

2. **Short-term:**
   - Test WebSocket connection manually
   - Inspect message format
   - Document findings

3. **Implementation:**
   - Implement WebSocket connection
   - Handle message protocol
   - Test audio/video streaming
   - Implement tool call handling

---

## 💡 Current Workaround

Until official documentation is found:

1. **Backend Session Creation:** ✅ Working
2. **Tool Call Execution:** ✅ Working
3. **WebSocket Connection:** ⏳ Pending documentation

**Alternative:** Use HTTP streaming or wait for SDK support

---

## 📝 Notes

- Gemini Live API is relatively new (preview model)
- Documentation may be incomplete
- SDK examples may be most reliable source
- WebSocket protocol may follow standard patterns

---

**Status:** Research in progress
**Last Updated:** 2025-01-27
