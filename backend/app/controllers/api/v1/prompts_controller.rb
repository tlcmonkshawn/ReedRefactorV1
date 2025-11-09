module Api
  module V1
    class PromptsController < BaseController
      # Only Bootie Bosses and Admins can manage prompts
      before_action :authorize_bootie_boss!, only: [:create, :update, :destroy]
      before_action :set_prompt, only: [:show, :update, :destroy]
      
      # Reload cache after changes
      after_action :reload_cache_if_needed, only: [:create, :update, :destroy]

      def index
        # Use cache instead of database query
        prompts = PromptCacheService.all
        
        # Apply filters
        category = params[:category]
        model = params[:model]
        prompts = prompts.select { |p| p.category == category } if category.present?
        prompts = prompts.select { |p| p.model == model } if model.present?
        
        # Sort
        prompts = prompts.sort_by { |p| [p.sort_order, p.name] }
        
        render_success(prompts.map { |p| prompt_json(p) })
      end

      def show
        # Try cache first, fallback to database if not found
        prompt = PromptCacheService.all.find { |p| p.id == @prompt.id }
        prompt ||= @prompt
        
        render_success(prompt_json(prompt))
      end

      def create
        @prompt = Prompt.new(prompt_params)
        
        if @prompt.save
          render_success(prompt_json(@prompt), status: :created)
        else
          render_error(@prompt.errors.full_messages.join(', '), code: 'VALIDATION_ERROR')
        end
      end

      def update
        if @prompt.update(prompt_params)
          render_success(prompt_json(@prompt))
        else
          render_error(@prompt.errors.full_messages.join(', '), code: 'VALIDATION_ERROR')
        end
      end

      def destroy
        @prompt.destroy
        render_success({ message: 'Prompt deleted successfully' })
      end

      # Get prompt by category and name (from cache)
      def get
        prompt = PromptCacheService.get(category: params[:category], name: params[:name])
        
        if prompt
          render_success(prompt_json(prompt))
        else
          render_error('Prompt not found', code: 'NOT_FOUND', status: :not_found)
        end
      end

      # Get all prompts for a specific category (from cache)
      def by_category
        prompts = PromptCacheService.all_for_category(params[:category])
        render_success(prompts.map { |p| prompt_json(p) })
      end

      private

      def set_prompt
        @prompt = Prompt.find(params[:id])
      end

      def authorize_bootie_boss!
        unless current_user&.can_finalize?
          render_error('Only Bootie Bosses and Admins can manage prompts', code: 'FORBIDDEN', status: :forbidden)
        end
      end

      def prompt_params
        params.require(:prompt).permit(
          :category,
          :name,
          :model,
          :prompt_text,
          :description,
          :use_case,
          :active,
          :prompt_type,
          :sort_order,
          metadata: {}
        )
      end

      def prompt_json(prompt)
        {
          id: prompt.id,
          category: prompt.category,
          name: prompt.name,
          model: prompt.model,
          prompt_text: prompt.prompt_text,
          description: prompt.description,
          use_case: prompt.use_case,
          metadata: prompt.metadata_hash,
          active: prompt.active,
          version: prompt.version,
          prompt_type: prompt.prompt_type,
          sort_order: prompt.sort_order,
          created_at: prompt.created_at,
          updated_at: prompt.updated_at
        }
      end

      def reload_cache_if_needed
        # Cache will be reloaded automatically by Prompt model callbacks
        # This is just a safety net
        Thread.new do
          begin
            PromptCacheService.reload_if_changed
          rescue => e
            Rails.logger.error "Failed to reload cache in controller: #{e.message}"
          end
        end
      end
    end
  end
end

