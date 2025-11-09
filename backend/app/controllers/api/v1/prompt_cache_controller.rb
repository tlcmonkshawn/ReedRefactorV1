module Api
  module V1
    class PromptCacheController < BaseController
      # Check if prompts have been updated (for cache invalidation)
      # Returns timestamp of last update
      def check_updates
        last_updated = Prompt.maximum(:updated_at)
        
        render_success({
          last_updated_at: last_updated&.iso8601,
          cache_stale: PromptCacheService.check_for_updates
        })
      end

      # Get cache statistics (admin only)
      def stats
        unless current_user&.admin?
          return render_error('Only admins can view cache stats', code: 'FORBIDDEN', status: :forbidden)
        end

        render_success(PromptCacheService.stats)
      end
    end
  end
end

