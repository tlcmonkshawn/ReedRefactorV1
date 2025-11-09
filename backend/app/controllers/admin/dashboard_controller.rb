module Admin
  class DashboardController < BaseController
    def index
      begin
        @stats = {
          total_users: User.count,
          active_users: User.active.count,
          total_booties: Bootie.count,
          pending_booties: Bootie.pending_research.count,
          finalized_booties: Bootie.finalized.count,
          total_locations: Location.active.count
        }
      rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad, PG::Error => e
        Rails.logger.error "Database error in admin dashboard: #{e.message}"
        @stats = {
          total_users: 0,
          active_users: 0,
          total_booties: 0,
          pending_booties: 0,
          finalized_booties: 0,
          total_locations: 0
        }
        @db_error = "Database connection error: #{e.message}"
      rescue StandardError => e
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

