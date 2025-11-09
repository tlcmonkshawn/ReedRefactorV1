module Admin
  class DashboardController < BaseController
    def index
      begin
        @stats = {
          total_users: User.count,
          active_users: User.active.length,
          total_booties: Bootie.count,
          pending_booties: Bootie.pending_research.length,
          finalized_booties: Bootie.finalized.length,
          total_locations: Location.active.length
        }
      rescue => e
        Rails.logger.error "Error in admin dashboard: #{e.class}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @stats = {
          total_users: 0,
          active_users: 0,
          total_booties: 0,
          pending_booties: 0,
          finalized_booties: 0,
          total_locations: 0
        }
        @db_error = "Error loading dashboard: #{e.message}"
      end
    end
  end
end
