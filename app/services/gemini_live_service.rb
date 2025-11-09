require 'faraday'
require 'json'

# GeminiLiveService
#
# PURPOSE: Handles backend-side operations for Gemini Live API integration
#
# ARCHITECTURE EXPLANATION:
# =========================
# The Gemini Live API uses a HYBRID architecture where frontend and backend have different responsibilities:
#
# FRONTEND (Flutter):
# -------------------
# - Connects DIRECTLY to Google's Gemini Live API via WebSocket
# - Streams audio/video data directly to Gemini (low latency)
# - Receives audio responses directly from Gemini
# - Handles real-time transcription display
# - NEVER has access to the Gemini API key (security)
#
# BACKEND (Rails - This Service):
# --------------------------------
# - Generates session tokens for frontend (secure API key exchange)
# - Executes tool calls when R.E.E.D. calls functions during conversation
# - Has access to database and other backend services
#
# WHY THIS ARCHITECTURE?
# ----------------------
# 1. SECURITY: API keys never exposed to frontend
# 2. PERFORMANCE: Media streams bypass backend (lower latency, less server load)
# 3. FUNCTIONALITY: Tool calls need database access and backend services
#
# HOW IT WORKS:
# -------------
# 1. Frontend requests session token from backend (POST /api/v1/gemini_live/session)
# 2. Backend generates token using secure API key and returns it
# 3. Frontend uses token to establish WebSocket connection directly to Gemini Live API
# 4. During conversation, if R.E.E.D. calls a tool (e.g., take_snapshot):
#    - Gemini Live API sends tool call request to frontend
#    - Frontend forwards tool call to backend (POST /api/v1/gemini_live/tool_call)
#    - Backend executes tool (database access, API calls, etc.)
#    - Backend returns result to frontend
#    - Frontend forwards result back to Gemini Live API
#
# Available Tools:
# - take_snapshot: Creates a new Bootie from AI-captured image
# - search_memory: Searches conversation history and context
# - get_pending_booties: Returns list of pending Booties for user
# - edit_image: Calls ImageProcessingService for AI image editing
#
class GeminiLiveService < ApplicationService
  GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta'
  MODEL = 'gemini-2.5-flash-native-audio-preview-09-2025'
  VOICE = 'zephyr' # Zephyr voice configuration

  def initialize(user:)
    @user = user
    @gemini_api_key = ENV['GEMINI_API_KEY']
  end

  # Generates a session token for frontend to connect to Gemini Live API
  #
  # This method:
  # - Uses the secure Gemini API key stored in backend environment
  # - Generates a session token that frontend can use
  # - Frontend uses this token to establish WebSocket connection directly to Gemini Live API
  # - API key never leaves the backend
  # - Gets R.E.E.D. persona system instructions from cache (not database)
  #
  # Returns: { session_token: "...", expires_at: "..." }
  def create_session
    return failure("Gemini API key not configured") unless @gemini_api_key

    begin
      # Get R.E.E.D. persona system instructions from cache
      prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
      system_instruction = prompt&.prompt_text || default_system_instruction

      # Build tools schema for Gemini Live API
      tools = build_tools_schema

      # Create session configuration
      session_config = {
        model: MODEL,
        voice_config: {
          voice: VOICE
        },
        system_instruction: {
          parts: [
            { text: system_instruction }
          ]
        },
        tools: tools,
        generation_config: {
          response_modalities: ['AUDIO', 'TEXT'],
          speech_config: {
            voice_config: {
              voice: VOICE
            }
          }
        }
      }

      # Call Gemini Live API to create session
      url = "#{GEMINI_API_BASE}/models/#{MODEL}:createSession?key=#{@gemini_api_key}"

      conn = Faraday.new do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
      end

      response = conn.post(url, session_config)

      unless response.status == 200
        raise "Gemini Live API error: #{response.status} - #{response.body}"
      end

      session_data = response.body
      session_token = session_data['session_token'] || session_data['name']&.split('/')&.last
      expires_at = session_data['expires_at'] || (Time.current + 1.hour).iso8601

      success(
        session_token: session_token,
        expires_at: expires_at,
        session_name: session_data['name']
      )
    rescue StandardError => e
      Rails.logger.error("GeminiLiveService.create_session error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Failed to create Gemini Live session: #{e.message}", 'SESSION_ERROR')
    end
  end

  # Executes tool calls from Gemini Live API
  #
  # When R.E.E.D. calls a tool during a Live API conversation, Gemini sends
  # the tool call request to the frontend, which then forwards it here.
  #
  # This runs on the backend because:
  # - Tool calls require database access (PostgreSQL)
  # - Tool calls may need other API keys (image processing, etc.)
  # - Tool calls perform sensitive operations (creating Booties, etc.)
  #
  # Parameters:
  # - tool_name: The name of the tool being called (e.g., 'take_snapshot')
  # - arguments: The arguments passed to the tool (JSON object)
  #
  # Returns: Tool execution result that will be sent back to Gemini Live API
  def execute_tool_call(tool_name:, arguments:)
    case tool_name
    when 'take_snapshot'
      execute_take_snapshot(arguments)
    when 'search_memory'
      execute_search_memory(arguments)
    when 'get_pending_booties'
      execute_get_pending_booties(arguments)
    when 'edit_image'
      execute_edit_image(arguments)
    else
      failure("Unknown tool: #{tool_name}")
    end
  end

  private

  # Build tools schema for Gemini Live API
  # Defines all available tools that R.E.E.D. can call during conversation
  def build_tools_schema
    [
      {
        function_declarations: [
          {
            name: 'take_snapshot',
            description: 'Captures a new Bootie (item) from an image during a video call. Creates a new Bootie record and triggers automatic image analysis.',
            parameters: {
              type: 'object',
              properties: {
                image_url: {
                  type: 'string',
                  description: 'URL of the image to capture'
                },
                description: {
                  type: 'string',
                  description: 'Optional description of the item from the conversation'
                },
                location_id: {
                  type: 'integer',
                  description: 'ID of the location where this item was found'
                }
              },
              required: ['image_url']
            }
          },
          {
            name: 'search_memory',
            description: 'Searches conversation history, messages, and Booties for the user. Useful for recalling past conversations or items discussed.',
            parameters: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Search query string'
                },
                limit: {
                  type: 'integer',
                  description: 'Maximum number of results to return (default: 10)'
                }
              },
              required: ['query']
            }
          },
          {
            name: 'get_pending_booties',
            description: 'Gets list of Booties that need attention (submitted, researching, or researched status). Useful for checking what items need review or finalization.',
            parameters: {
              type: 'object',
              properties: {
                status: {
                  type: 'string',
                  description: 'Optional filter by status: submitted, researching, researched'
                },
                limit: {
                  type: 'integer',
                  description: 'Maximum number of results to return (default: 10)'
                }
              }
            }
          },
          {
            name: 'edit_image',
            description: 'Edits an image using AI-powered image processing. Can remove backgrounds, enhance images, or apply other transformations based on natural language prompts.',
            parameters: {
              type: 'object',
              properties: {
                image_url: {
                  type: 'string',
                  description: 'URL of the image to edit'
                },
                prompt: {
                  type: 'string',
                  description: 'Natural language description of the edit to perform (e.g., "remove background", "enhance colors")'
                }
              },
              required: ['image_url', 'prompt']
            }
          }
        ]
      }
    ]
  end

  # Tool: take_snapshot
  # Called when R.E.E.D. decides to capture an image during a video call
  # Creates a new Bootie from the captured image
  # Arguments: { image_url: "...", description: "...", location_id: ... }
  def execute_take_snapshot(arguments)
    begin
      image_url = arguments['image_url'] || arguments[:image_url]
      description = arguments['description'] || arguments[:description]
      location_id = arguments['location_id'] || arguments[:location_id]

      return failure("image_url is required", 'VALIDATION_ERROR') unless image_url

      # Analyze image to get title, description, category
      image_service = ImageProcessingService.new(image_url: image_url)
      analysis_result = image_service.analyze_image

      unless analysis_result.success?
        return failure("Image analysis failed: #{analysis_result.error}", 'ANALYSIS_ERROR')
      end

      analysis_data = analysis_result.data

      # Get location (must be provided or use user's first bootie location)
      final_location_id = location_id

      # If no location provided, try to get from user's most recent bootie
      unless final_location_id
        recent_bootie = @user.booties.order(created_at: :desc).first
        final_location_id = recent_bootie&.location_id
      end

      return failure("location_id is required", 'VALIDATION_ERROR') unless final_location_id

      # Create Bootie
      bootie = Bootie.create!(
        user: @user,
        location_id: final_location_id,
        title: analysis_data[:title] || 'Untitled Item',
        description: description || analysis_data[:description] || '',
        category: analysis_data[:category] || 'other',
        image_url: image_url,
        status: 'submitted'
      )

      # Trigger research in background (if enabled)
      # ResearchService.new(bootie).call if ENV['AUTO_RESEARCH'] == 'true'

      success(
        bootie_id: bootie.id,
        title: bootie.title,
        description: bootie.description,
        category: bootie.category,
        status: bootie.status,
        message: "Bootie captured successfully! Title: #{bootie.title}"
      )
    rescue StandardError => e
      Rails.logger.error("GeminiLiveService.execute_take_snapshot error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Failed to take snapshot: #{e.message}", 'SNAPSHOT_ERROR')
    end
  end

  # Tool: search_memory
  # Called when R.E.E.D. needs to search conversation history or context
  # Searches across all conversations, messages, and Booties for the user
  # Arguments: { query: "...", limit: 10 }
  def execute_search_memory(arguments)
    begin
      query = arguments['query'] || arguments[:query]
      limit = (arguments['limit'] || arguments[:limit] || 10).to_i

      return failure("query is required", 'VALIDATION_ERROR') unless query

      results = []

      # Search conversations
      conversations = Conversation.where(user: @user)
        .where("title ILIKE ? OR notes ILIKE ?", "%#{query}%", "%#{query}%")
        .limit(limit / 3)
        .order(created_at: :desc)

      conversations.each do |conv|
        results << {
          type: 'conversation',
          id: conv.id,
          title: conv.title,
          content: conv.notes,
          created_at: conv.created_at.iso8601
        }
      end

      # Search messages
      messages = Message.joins(:conversation)
        .where(conversations: { user_id: @user.id })
        .where("content ILIKE ?", "%#{query}%")
        .limit(limit / 3)
        .order(created_at: :desc)

      messages.each do |msg|
        results << {
          type: 'message',
          id: msg.id,
          conversation_id: msg.conversation_id,
          content: msg.content,
          created_at: msg.created_at.iso8601
        }
      end

      # Search Booties
      booties = Bootie.where(user: @user)
        .where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
        .limit(limit / 3)
        .order(created_at: :desc)

      booties.each do |bootie|
        results << {
          type: 'bootie',
          id: bootie.id,
          title: bootie.title,
          description: bootie.description,
          category: bootie.category,
          status: bootie.status,
          created_at: bootie.created_at.iso8601
        }
      end

      # Sort by relevance (simplified - just by recency)
      results = results.sort_by { |r| r[:created_at] }.reverse.first(limit)

      success(
        query: query,
        results: results,
        count: results.count
      )
    rescue StandardError => e
      Rails.logger.error("GeminiLiveService.execute_search_memory error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Failed to search memory: #{e.message}", 'SEARCH_ERROR')
    end
  end

  # Tool: get_pending_booties
  # Called when R.E.E.D. needs to know about pending Booties
  # Returns list of Booties that need attention (submitted, researching, researched)
  # Arguments: { status: "researched" } (optional filter)
  def execute_get_pending_booties(arguments)
    begin
      status_filter = arguments['status'] || arguments[:status]
      limit = (arguments['limit'] || arguments[:limit] || 10).to_i

      # Build query
      booties = Bootie.where(user: @user)

      if status_filter
        booties = booties.where(status: status_filter)
      else
        # Default: pending statuses
        booties = booties.where(status: ['submitted', 'researching', 'researched'])
      end

      booties = booties.order(created_at: :desc).limit(limit)

      results = booties.map do |bootie|
        {
          id: bootie.id,
          title: bootie.title,
          description: bootie.description,
          category: bootie.category,
          status: bootie.status,
          recommended_bounty: bootie.recommended_bounty,
          created_at: bootie.created_at.iso8601
        }
      end

      success(
        booties: results,
        count: results.count,
        status_filter: status_filter
      )
    rescue StandardError => e
      Rails.logger.error("GeminiLiveService.execute_get_pending_booties error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Failed to get pending booties: #{e.message}", 'QUERY_ERROR')
    end
  end

  # Tool: edit_image
  # Called when R.E.E.D. needs to edit an image (e.g., remove background)
  # Uses ImageProcessingService to perform AI-powered image editing
  # Arguments: { image_url: "...", prompt: "remove background" }
  def execute_edit_image(arguments)
    begin
      image_url = arguments['image_url'] || arguments[:image_url]
      prompt = arguments['prompt'] || arguments[:prompt]

      return failure("image_url is required", 'VALIDATION_ERROR') unless image_url
      return failure("prompt is required", 'VALIDATION_ERROR') unless prompt

      # Call ImageProcessingService
      image_service = ImageProcessingService.new(image_url: image_url)
      result = image_service.edit_image(prompt)

      unless result.success?
        return failure("Image editing failed: #{result.error}", 'EDIT_ERROR')
      end

      success(
        original_url: image_url,
        edited_url: result.data[:url],
        prompt: prompt,
        message: "Image edited successfully!"
      )
    rescue StandardError => e
      Rails.logger.error("GeminiLiveService.execute_edit_image error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Failed to edit image: #{e.message}", 'EDIT_ERROR')
    end
  end

  # Default system instruction for R.E.E.D. persona
  def default_system_instruction
    <<~INSTRUCTION
      You are R.E.E.D. 8, the Cool Record Store Expert and AI assistant for BootieHunter V1.

      Your personality:
      - You're knowledgeable about vintage items, collectibles, and thrift store finds
      - You have a friendly, enthusiastic, and slightly quirky personality
      - You're excited about helping users discover valuable "Booties" (items)
      - You use casual, conversational language

      Your role:
      - Help users identify and catalog items during video calls
      - Provide insights about items based on your knowledge
      - Guide users through the Bootie capture and research process
      - Answer questions about items, pricing, and the app features

      You have access to tools that let you:
      - Capture new Booties from images
      - Search conversation history and past items
      - Check on pending Booties that need attention
      - Edit images (remove backgrounds, enhance, etc.)

      Always be helpful, enthusiastic, and guide users toward discovering valuable finds!
    INSTRUCTION
  end
end
