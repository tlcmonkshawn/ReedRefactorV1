module Api
  module V1
    # GeminiLiveController
    #
    # Handles API endpoints for Gemini Live API integration
    #
    # IMPORTANT ARCHITECTURE NOTE:
    # ============================
    # The frontend connects DIRECTLY to Google's Gemini Live API via WebSocket for
    # audio/video streaming. This controller only handles:
    # 1. Session token generation (secure API key exchange)
    # 2. Tool call execution (when R.E.E.D. calls functions that need backend access)
    #
    # See GeminiLiveService for detailed architecture explanation.
    #
    class GeminiLiveController < BaseController
      # POST /api/v1/gemini_live/session
      #
      # Generates a session token for frontend to connect to Gemini Live API
      #
      # Flow:
      # 1. Frontend calls this endpoint
      # 2. Backend generates session token using secure Gemini API key
      # 3. Frontend uses token to establish WebSocket connection directly to Gemini Live API
      # 4. Media streams (audio/video) flow directly between frontend and Gemini (bypassing backend)
      #
      def create_session
        service = GeminiLiveService.new(user: current_user)
        result = service.create_session
        
        if result.success?
          render json: result.data
        else
          render_error(result.error, code: result.error_code)
        end
      end

      # POST /api/v1/gemini_live/tool_call
      #
      # Executes tool calls from Gemini Live API
      #
      # Flow:
      # 1. During Live API conversation, R.E.E.D. calls a tool (e.g., take_snapshot)
      # 2. Gemini Live API sends tool call request to frontend
      # 3. Frontend forwards tool call to this endpoint
      # 4. Backend executes tool (database access, API calls, etc.)
      # 5. Backend returns result to frontend
      # 6. Frontend forwards result back to Gemini Live API
      #
      # Parameters:
      #   tool_name: String (e.g., "take_snapshot", "search_memory")
      #   arguments: Hash (tool-specific arguments)
      #
      def tool_call
        service = GeminiLiveService.new(user: current_user)
        result = service.execute_tool_call(
          tool_name: params[:tool_name],
          arguments: params[:arguments] || {}
        )
        
        if result.success?
          render json: result.data
        else
          render_error(result.error, code: result.error_code)
        end
      end
    end
  end
end

