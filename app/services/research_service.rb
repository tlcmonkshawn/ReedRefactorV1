require 'faraday'
require 'json'

# ResearchService - AI-powered price research service
#
# Coordinates automated price research for Booties using Google Gemini AI
# with Google Search grounding to find real-world pricing data.
#
# Research Process:
# 1. Bootie status changes to "researching"
# 2. Generate research query from Bootie details (title, description, category)
# 3. Call Gemini 2.5 Flash with Google Search grounding
# 4. Parse response for recommended_bounty, research_summary, research_reasoning
# 5. Extract and store grounding sources (URLs, titles, snippets)
# 6. Create research logs for audit trail
# 7. Update Bootie with research results (status -> "researched")
#
# @see PRODUCT_PROFILE.md for research feature details
# @see ARCHITECTURE.md for AI integration architecture
class ResearchService < ApplicationService
  GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta'
  MODEL = 'gemini-2.5-flash'

  # Initialize service with Bootie to research
  #
  # @param bootie [Bootie] The Bootie to research
  def initialize(bootie)
    @bootie = bootie
    @gemini_api_key = ENV['GEMINI_API_KEY']  # API key stored in environment variables
  end

  # Execute research process
  #
  # @return [ServiceResult] Result with updated Bootie on success, error on failure
  def call
    return failure("Bootie not found") unless @bootie
    return failure("Gemini API key not configured") unless @gemini_api_key

    begin
      # Update Bootie status to "researching"
      @bootie.start_research!

      # Generate research query
      query = generate_research_query

      # Call Gemini API with Google Search grounding
      response = call_gemini_with_search(query)

      # Parse response to extract research data
      research_data = parse_research_response(response)

      # Create research log
      create_research_log(query, response, research_data)

      # Create grounding sources
      create_grounding_sources(research_data[:sources] || [])

      # Update Bootie with research results
      @bootie.complete_research!(
        recommended_bounty: research_data[:recommended_bounty],
        research_summary: research_data[:research_summary],
        research_reasoning: research_data[:research_reasoning]
      )

      success(@bootie)
    rescue StandardError => e
      Rails.logger.error("ResearchService.call error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      # Update Bootie status to error
      @bootie.update(status: 'failed') if @bootie.respond_to?(:update)

      failure("Research failed: #{e.message}", 'RESEARCH_ERROR')
    end
  end

  private

  # Generate research query from Bootie details
  def generate_research_query
    parts = []
    parts << "Find current market prices for: #{@bootie.title}" if @bootie.title.present?
    parts << @bootie.description if @bootie.description.present?
    parts << "Category: #{@bootie.category}" if @bootie.category.present?

    query = parts.join('. ')
    query.presence || "Research pricing for this item"
  end

  # Call Gemini API with Google Search grounding
  #
  # @param query [String] Research query string
  # @return [Hash] Gemini API response
  def call_gemini_with_search(query)
    url = "#{GEMINI_API_BASE}/models/#{MODEL}:generateContent?key=#{@gemini_api_key}"

    # Get research prompt from cache
    prompt = PromptCacheService.get(category: 'research', name: 'price_research')
    prompt_text = prompt&.prompt_text || default_research_prompt(query)

    # Build payload with Google Search tool
    payload = {
      contents: [{
        parts: [{ text: prompt_text }]
      }],
      tools: [{
        googleSearch: {}
      }]
    }

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

  # Parse Gemini response to extract research data
  #
  # @param response [Hash] Raw Gemini API response
  # @return [Hash] Parsed data with recommended_bounty, research_summary, research_reasoning, sources
  def parse_research_response(response)
    # Extract text from response
    text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
    return default_research_data unless text

    # Extract grounding metadata (sources)
    grounding_metadata = response.dig('candidates', 0, 'groundingMetadata')
    sources = extract_grounding_sources(grounding_metadata)

    # Try to parse JSON if response is structured
    begin
      parsed = JSON.parse(text)
      {
        recommended_bounty: parse_price(parsed['recommended_bounty'] || parsed['recommended_price'] || parsed['price']),
        research_summary: parsed['research_summary'] || parsed['summary'] || extract_summary(text),
        research_reasoning: parsed['research_reasoning'] || parsed['reasoning'] || extract_reasoning(text),
        sources: sources
      }
    rescue JSON::ParserError
      # If not JSON, extract from text using patterns
      {
        recommended_bounty: extract_price(text),
        research_summary: extract_summary(text),
        research_reasoning: extract_reasoning(text),
        sources: sources
      }
    end
  end

  # Extract grounding sources from metadata
  def extract_grounding_sources(metadata)
    return [] unless metadata

    sources = []

    # Check for web search grounding chunks
    chunks = metadata['groundingChunks'] || []
    chunks.each do |chunk|
      web = chunk['web']
      next unless web

      sources << {
        title: web['title'],
        url: web['uri'],
        snippet: web['snippet']
      }
    end

    sources
  end

  # Extract price from text
  def extract_price(text)
    # Look for price patterns like $XX.XX, $XX, XX.XX
    if text =~ /\$?(\d+\.?\d*)/m
      price = $1.to_f
      price > 0 ? price : nil
    else
      nil
    end
  end

  # Parse price from various formats
  def parse_price(value)
    return nil unless value

    case value
    when Numeric
      value.to_f
    when String
      value.gsub(/[^0-9.]/, '').to_f
    else
      nil
    end
  end

  # Extract summary from text (first 200 characters)
  def extract_summary(text)
    lines = text.split(/\n/)
    summary = lines.first(3).join(' ').strip
    summary.length > 200 ? summary[0..200] + '...' : summary
  end

  # Extract reasoning from text
  def extract_reasoning(text)
    # Look for reasoning section or use full text
    if text =~ /reasoning[:\s]+(.+)/im
      $1.strip
    else
      text.strip
    end
  end

  # Create research log for audit trail
  def create_research_log(query, response, research_data)
    ResearchLog.create!(
      bootie: @bootie,
      query: query,
      response_text: response.dig('candidates', 0, 'content', 'parts', 0, 'text'),
      recommended_bounty: research_data[:recommended_bounty],
      status: 'completed'
    )
  rescue StandardError => e
    Rails.logger.error("Failed to create research log: #{e.message}")
  end

  # Create grounding source records
  def create_grounding_sources(sources)
    sources.each do |source|
      GroundingSource.create!(
        bootie: @bootie,
        source_type: 'web',
        title: source[:title],
        url: source[:url],
        snippet: source[:snippet]
      )
    rescue StandardError => e
      Rails.logger.error("Failed to create grounding source: #{e.message}")
    end
  end

  # Default research data if parsing fails
  def default_research_data
    {
      recommended_bounty: nil,
      research_summary: "Research completed but pricing data could not be extracted",
      research_reasoning: "Please review the research logs for details",
      sources: []
    }
  end

  # Default research prompt
  def default_research_prompt(query)
    <<~PROMPT
      Research the current market price for this thrift store item:

      #{query}

      Please provide:
      1. A recommended sale price (as a decimal number, e.g., 25.99)
      2. A brief research summary (2-3 sentences)
      3. Detailed reasoning explaining how you arrived at this price, including:
         - Similar items found
         - Price ranges observed
         - Condition considerations
         - Market trends

      Return your response as JSON with keys: recommended_bounty, research_summary, research_reasoning
    PROMPT
  end
end
