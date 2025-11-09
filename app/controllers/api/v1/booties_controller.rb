# Booties API Controller
#
# Handles all Bootie-related API endpoints.
# Provides CRUD operations and workflow actions (finalize, research, etc.)
#
# @see API.md for endpoint documentation
# @see docs/API.md for detailed API documentation
module Api
  module V1
    class BootiesController < BaseController
      # Set @bootie instance variable and check authorization before actions
      before_action :set_bootie, only: [:show, :update, :destroy, :finalize, :trigger_research, :research_results, :research_logs, :grounding_sources]

      # GET /api/v1/booties
      # List all Booties with optional filtering
      # Non-admin users only see their own Booties unless user_id filter is specified (admin only)
      def index
        booties = if params[:user_id].present? && current_user.admin?
          Bootie.where(:user_id, params[:user_id]).get
        elsif params[:user_id].present?
          # Non-admin can't filter by other users
          []
        else
          # Default to current user's booties
          Bootie.where(:user_id, current_user.id).get
        end

        # Apply additional filters
        booties = booties.select { |b| b.status == params[:status] } if params[:status].present?
        booties = booties.select { |b| b.category == params[:category] } if params[:category].present?
        booties = booties.select { |b| b.location_id == params[:location_id] } if params[:location_id].present?

        # Sort by created_at descending
        booties = booties.sort_by { |b| b.created_at || Time.at(0) }.reverse

        render json: booties.map { |b| bootie_serializer(b) }
      end

      def show
        render json: bootie_serializer(@bootie)
      end

      def create
        bootie = Bootie.new(bootie_params)
        bootie.user_id = current_user.id
        
        if bootie.save
          render json: bootie_serializer(bootie), status: :created
        else
          render_error(bootie.errors.full_messages.join(', '))
        end
      end

      def update
        if @bootie.update(bootie_params)
          render json: bootie_serializer(@bootie)
        else
          render_error(@bootie.errors.full_messages.join(', '))
        end
      end

      def destroy
        @bootie.destroy
        head :no_content
      end

      # POST /api/v1/booties/:id/finalize
      # Finalize a Bootie to Square catalog (publish to online store)
      # Only Bootie Bosses and Admins can finalize Booties
      #
      # Request body: { "final_bounty": 25.00 }
      def finalize
        unless current_user.can_finalize?
          return render_error("Only Bootie Bosses and Admins can finalize Booties", code: 'FORBIDDEN', status: :forbidden)
        end

        result = FinalizationService.call(
          bootie: @bootie,
          user: current_user,
          final_bounty: params[:final_bounty]
        )

        if result.success?
          render json: bootie_serializer(result.data)
        else
          render_error(result.error, code: result.error_code)
        end
      end

      # POST /api/v1/booties/:id/research
      # Trigger research for a Bootie (if not already researching/completed)
      # Research runs asynchronously using ResearchService
      def trigger_research
        result = ResearchService.call(@bootie)
        
        if result.success?
          render json: { message: 'Research started' }
        else
          render_error(result.error, code: result.error_code)
        end
      end

      # GET /api/v1/booties/:id/research
      # Get research results for a Bootie
      # Returns recommended_bounty, research_summary, research_reasoning, and completion timestamp
      def research_results
        render json: {
          recommended_bounty: @bootie.recommended_bounty,
          research_summary: @bootie.research_summary,
          research_reasoning: @bootie.research_reasoning,
          research_completed_at: @bootie.research_completed_at,
          status: @bootie.status
        }
      end

      # GET /api/v1/booties/:id/research_logs
      # Get research logs for a Bootie
      def research_logs
        logs = @bootie.research_logs
        render json: logs.map { |log| research_log_serializer(log) }
      end

      # GET /api/v1/booties/:id/grounding_sources
      # Get grounding sources (research citations) for a Bootie
      def grounding_sources
        sources = @bootie.grounding_sources
        render json: sources.map { |source| grounding_source_serializer(source) }
      end

      private

      def set_bootie
        @bootie = Bootie.find(params[:id])
        return render_unauthorized unless @bootie
        
        # Check authorization: users can only access their own booties unless admin
        unless current_user.admin? || @bootie.user_id == current_user.id
          return render_unauthorized
        end
      rescue FirestoreModel::DocumentNotFound
        render json: { error: { message: 'Bootie not found', code: 'NOT_FOUND' } }, status: :not_found
      end

      def bootie_params
        params.require(:bootie).permit(:title, :description, :category, :location_id, :primary_image_url, :alternate_image_urls, :edited_image_urls)
      end

      def bootie_serializer(bootie)
        {
          id: bootie.id,
          title: bootie.title,
          description: bootie.description,
          category: bootie.category,
          status: bootie.status,
          user_id: bootie.user_id,
          location_id: bootie.location_id,
          primary_image_url: bootie.primary_image_url,
          alternate_image_urls: bootie.alternate_image_urls || [],
          edited_image_urls: bootie.edited_image_urls || [],
          recommended_bounty: bootie.recommended_bounty,
          final_bounty: bootie.final_bounty,
          research_summary: bootie.research_summary,
          research_reasoning: bootie.research_reasoning,
          square_product_id: bootie.square_product_id,
          square_variation_id: bootie.square_variation_id,
          created_at: bootie.created_at,
          updated_at: bootie.updated_at,
          finalized_at: bootie.finalized_at
        }
      end

      def research_log_serializer(log)
        {
          id: log.id,
          query: log.query,
          response: log.response,
          research_method: log.research_method,
          success: log.success,
          error_message: log.error_message,
          created_at: log.created_at
        }
      end

      def grounding_source_serializer(source)
        {
          id: source.id,
          title: source.title,
          url: source.url,
          snippet: source.snippet,
          source_type: source.source_type,
          created_at: source.created_at
        }
      end
    end
  end
end
