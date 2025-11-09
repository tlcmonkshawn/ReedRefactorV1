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
        booties = Bootie.all
        booties = booties.by_status(params[:status]) if params[:status].present?
        booties = booties.by_category(params[:category]) if params[:category].present?
        booties = booties.by_location(params[:location_id]) if params[:location_id].present?
        booties = booties.where(user_id: params[:user_id]) if params[:user_id].present?
        
        # Default to current user's booties if no filter
        booties = booties.where(user_id: current_user.id) unless params[:user_id].present? || current_user.admin?

        render json: booties.order(created_at: :desc)
      end

      def show
        render json: bootie_serializer(@bootie)
      end

      def create
        bootie = current_user.booties.build(bootie_params)
        
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
          research_completed_at: @bootie.research_completed_at
        }
      end

      # GET /api/v1/booties/:id/research/logs
      # Get detailed research logs for a Bootie
      # Returns array of research_log records showing the research process
      def research_logs
        render json: @bootie.research_logs.order(created_at: :desc)
      end

      # GET /api/v1/booties/:id/research/sources
      # Get grounding sources (citations) for research
      # Returns array of source URLs, titles, and snippets
      def grounding_sources
        render json: @bootie.grounding_sources
      end

      private

      # Set @bootie from params and check authorization
      # Users can only access their own Booties unless they're admin
      def set_bootie
        @bootie = Bootie.find(params[:id])
        unless @bootie.user_id == current_user.id || current_user.admin?
          render_error("Not authorized", code: 'FORBIDDEN', status: :forbidden)
        end
      end

      def bootie_params
        params.require(:bootie).permit(:title, :description, :category, :location_id, :primary_image_url, alternate_image_urls: [])
      end

      def bootie_serializer(bootie)
        {
          id: bootie.id,
          title: bootie.title,
          description: bootie.description,
          category: bootie.category,
          status: bootie.status,
          recommended_bounty: bootie.recommended_bounty,
          final_bounty: bootie.final_bounty,
          primary_image_url: bootie.primary_image_url,
          alternate_image_urls: bootie.alternate_image_urls,
          edited_image_urls: bootie.edited_image_urls,
          location: {
            id: bootie.location.id,
            name: bootie.location.name
          },
          created_at: bootie.created_at,
          finalized_at: bootie.finalized_at
        }
      end
    end
  end
end

