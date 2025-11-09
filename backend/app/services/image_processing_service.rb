require 'faraday'
require 'base64'
require 'json'

class ImageProcessingService < ApplicationService
  # Handles image analysis and editing using Gemini AI models

  GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta'
  FLASH_LITE_MODEL = 'gemini-flash-lite-latest'
  FLASH_IMAGE_MODEL = 'gemini-2.5-flash-image'

  def initialize(image_url: nil, image_data: nil)
    @image_url = image_url
    @image_data = image_data
    @gemini_api_key = ENV['GEMINI_API_KEY']
  end

  def analyze_image
    # Uses Gemini Flash Lite Latest for quick image analysis
    # Returns: { title: "...", description: "...", category: "..." }
    return failure("No image provided") unless @image_url || @image_data
    return failure("Gemini API key not configured") unless @gemini_api_key

    begin
      # Get image analysis prompt from cache
      prompt = PromptCacheService.get(category: 'image_processing', name: 'analyze_image')
      prompt_text = prompt&.prompt_text || default_analysis_prompt

      # Prepare image data for API
      image_part = if @image_url
        { file_data: { file_uri: @image_url } }
      elsif @image_data
        # @image_data should be base64 encoded or raw bytes
        image_base64 = if @image_data.is_a?(String)
          # If it's already base64, use it; otherwise encode it
          @image_data.include?('base64') ? @image_data.split(',')[1] : Base64.strict_encode64(@image_data)
        else
          Base64.strict_encode64(@image_data)
        end
        { inline_data: { mime_type: 'image/jpeg', data: image_base64 } }
      end

      # Call Gemini API
      response = call_gemini_api(
        model: FLASH_LITE_MODEL,
        prompt: prompt_text,
        image_part: image_part
      )

      # Parse response to extract title, description, category
      result = parse_analysis_response(response)
      success(result)
    rescue StandardError => e
      Rails.logger.error("ImageProcessingService.analyze_image error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Image analysis failed: #{e.message}", 'ANALYSIS_ERROR')
    end
  end

  def edit_image(prompt)
    # Uses Gemini 2.5 Flash Image for AI-powered image editing
    # Returns: edited image URL
    # If prompt is a name (e.g., "remove_background"), gets prompt from cache
    return failure("No image provided") unless @image_url || @image_data
    return failure("No prompt provided") if prompt.blank?
    return failure("Gemini API key not configured") unless @gemini_api_key

    begin
      # If prompt looks like a prompt name, try to get it from cache
      actual_prompt = prompt
      if prompt.match?(/^[a-z_]+$/) # Simple name like "remove_background"
        cached_prompt = PromptCacheService.get(category: 'image_processing', name: prompt)
        actual_prompt = cached_prompt.prompt_text if cached_prompt
      end

      # Prepare image data for API
      image_part = if @image_url
        { file_data: { file_uri: @image_url } }
      elsif @image_data
        image_base64 = if @image_data.is_a?(String)
          @image_data.include?('base64') ? @image_data.split(',')[1] : Base64.strict_encode64(@image_data)
        else
          Base64.strict_encode64(@image_data)
        end
        { inline_data: { mime_type: 'image/jpeg', data: image_base64 } }
      end

      # Call Gemini API for image editing
      response = call_gemini_api(
        model: FLASH_IMAGE_MODEL,
        prompt: actual_prompt,
        image_part: image_part
      )

      # Extract edited image from response
      edited_image_data = extract_edited_image(response)
      return failure("No edited image returned from API", 'EDIT_ERROR') unless edited_image_data

      # Upload edited image to Google Cloud Storage
      upload_result = upload_edited_image(edited_image_data)
      if upload_result.success?
        success(url: upload_result.data[:url])
      else
        failure("Failed to upload edited image: #{upload_result.error}", 'UPLOAD_ERROR')
      end
    rescue StandardError => e
      Rails.logger.error("ImageProcessingService.edit_image error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Image editing failed: #{e.message}", 'EDIT_ERROR')
    end
  end

  def remove_background
    # Try to get prompt from cache first
    cached_prompt = PromptCacheService.get(category: 'image_processing', name: 'remove_background')
    prompt_text = cached_prompt&.prompt_text || "remove the background, keep only the main subject"
    edit_image(prompt_text)
  end

  def enhance_image
    # Try to get prompt from cache first
    cached_prompt = PromptCacheService.get(category: 'image_processing', name: 'enhance_image')
    prompt_text = cached_prompt&.prompt_text || "enhance lighting, improve contrast, make colors more vibrant"
    edit_image(prompt_text)
  end

  private

  # Call Gemini API for image analysis or editing
  #
  # @param model [String] Model name (e.g., FLASH_LITE_MODEL, FLASH_IMAGE_MODEL)
  # @param prompt [String] Text prompt for the API
  # @param image_part [Hash] Image data (file_data or inline_data)
  # @return [Hash] Parsed API response
  def call_gemini_api(model:, prompt:, image_part: nil)
    url = "#{GEMINI_API_BASE}/models/#{model}:generateContent?key=#{@gemini_api_key}"

    # Build request payload
    contents = [{
      parts: [
        { text: prompt },
        image_part
      ].compact
    }]

    payload = { contents: contents }

    # Make HTTP request
    conn = Faraday.new do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post(url, payload)

    unless response.status == 200
      raise "Gemini API error: #{response.status} - #{response.body}"
    end

    response.body
  end

  # Parse Gemini API response for image analysis
  #
  # @param response [Hash] Raw Gemini API response
  # @return [Hash] Parsed data with title, description, category
  def parse_analysis_response(response)
    # Extract text from response
    text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
    return { title: 'Unknown Item', description: '', category: 'uncategorized' } unless text

    # Try to parse JSON if response is structured
    begin
      parsed = JSON.parse(text)
      {
        title: parsed['title'] || extract_title(text),
        description: parsed['description'] || extract_description(text),
        category: parsed['category'] || extract_category(text)
      }
    rescue JSON::ParserError
      # If not JSON, extract from text using patterns
      {
        title: extract_title(text),
        description: extract_description(text),
        category: extract_category(text)
      }
    end
  end

  # Extract title from text (simple heuristic)
  def extract_title(text)
    # Look for title patterns like "Title:", "Item:", or first sentence
    if text =~ /title[:\s]+(.+?)(?:\n|$)/i
      $1.strip
    elsif text =~ /item[:\s]+(.+?)(?:\n|$)/i
      $1.strip
    else
      # Use first sentence or first 50 characters
      first_line = text.split(/[.\n]/).first
      first_line&.strip&.first(50) || 'Unknown Item'
    end
  end

  # Extract description from text
  def extract_description(text)
    # Look for description section
    if text =~ /description[:\s]+(.+?)(?:\n\n|category|$)/im
      $1.strip
    else
      # Use all text after title
      lines = text.split(/\n/)
      lines[1..-1]&.join(' ')&.strip || text.strip
    end
  end

  # Extract category from text
  def extract_category(text)
    # Look for category patterns
    if text =~ /category[:\s]+(.+?)(?:\n|$)/i
      category = $1.strip.downcase
      # Map to valid categories (adjust based on your category enum)
      valid_categories = %w[electronics clothing books furniture toys collectibles art jewelry home_decor other]
      valid_categories.find { |c| category.include?(c) } || 'other'
    else
      'other'
    end
  end

  # Extract edited image from Gemini API response
  #
  # @param response [Hash] Raw Gemini API response
  # @return [String] Base64-encoded image data, or nil if not found
  def extract_edited_image(response)
    # Gemini 2.5 Flash Image returns edited images in the response
    # Check for inline_data in the response parts
    candidate = response.dig('candidates', 0)
    return nil unless candidate

    parts = candidate.dig('content', 'parts') || []
    parts.each do |part|
      if part['inline_data'] && part['inline_data']['data']
        return part['inline_data']['data']
      end
    end

    nil
  end

  # Upload edited image to Google Cloud Storage
  #
  # @param image_data [String] Base64-encoded image data
  # @return [ServiceResult] Result with URL on success
  def upload_edited_image(image_data)
    require 'google/cloud/storage'

    begin
      bucket_name = ENV['GOOGLE_CLOUD_STORAGE_BUCKET'] || 'bootiehunter-v1-images'
      service_account_path = Rails.root.join('config', 'service-account-key.json')

      # Initialize storage
      # Priority 1: Service account JSON from environment variable (preferred for production/Render)
      storage = if ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'].present?
        require 'json'
        credentials_hash = JSON.parse(ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'])
        Google::Cloud::Storage.new(
          project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
          credentials: credentials_hash
        )
      # Priority 2: Service account key file (for local development)
      elsif File.exist?(service_account_path)
        Google::Cloud::Storage.new(
          project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
          credentials: service_account_path
        )
      # Priority 3: Default credentials (for GKE/GCE with IAM roles)
      elsif ENV['GOOGLE_CLOUD_PROJECT_ID'].present?
        Google::Cloud::Storage.new(project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'])
      else
        return failure("Google Cloud Storage not configured", 'CONFIG_ERROR')
      end

      # Decode base64 image
      image_bytes = Base64.decode64(image_data)

      # Generate filename
      timestamp = Time.current.to_i
      random = SecureRandom.hex(8)
      filename = "processed/#{timestamp}_#{random}.png"

      # Upload to bucket
      bucket = storage.bucket(bucket_name)
      file = bucket.create_file(
        StringIO.new(image_bytes),
        filename,
        content_type: 'image/png'
      )

      # Make publicly readable
      file.acl.public!

      url = "https://storage.googleapis.com/#{bucket_name}/#{filename}"
      success(url: url, filename: filename)
    rescue StandardError => e
      Rails.logger.error("ImageProcessingService.upload_edited_image error: #{e.message}")
      failure("Failed to upload edited image: #{e.message}", 'UPLOAD_ERROR')
    end
  end

  # Default prompt for image analysis
  def default_analysis_prompt
    <<~PROMPT
      Analyze this image of an item from a thrift store. Provide:
      1. A clear, descriptive title (3-8 words)
      2. A detailed description (2-4 sentences) including key features, condition, and notable details
      3. A category (electronics, clothing, books, furniture, toys, collectibles, art, jewelry, home_decor, or other)

      Return your response as JSON with keys: title, description, category
    PROMPT
  end
end
