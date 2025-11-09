module Admin
  class LogsController < BaseController
    def index
      # For now, show research logs as system logs
      # In the future, this could include Rails logs, API logs, etc.
      @logs = ResearchLog.includes(:bootie).order(created_at: :desc).page(params[:page])
      @log_type = params[:type] || 'research'
    end

    def show
      @log = ResearchLog.find(params[:id])
      @bootie = @log.bootie
      @sources = @log.grounding_sources.order(:created_at)
    end
  end
end

