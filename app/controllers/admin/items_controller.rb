module Admin
  class ItemsController < BaseController
    before_action :set_bootie, only: [:show, :edit, :update, :destroy]

    def index
      @booties = Bootie.includes(:user, :location).order(created_at: :desc).page(params[:page])
      @status_filter = params[:status]
      @booties = @booties.by_status(@status_filter) if @status_filter.present?
    end

    def show
    end

    def edit
    end

    def update
      if @bootie.update(bootie_params)
        redirect_to admin_item_path(@bootie), notice: 'Item was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @bootie.destroy
      redirect_to admin_items_path, notice: 'Item was successfully deleted.'
    end

    private

    def set_bootie
      @bootie = Bootie.find(params[:id])
    end

    def bootie_params
      params.require(:bootie).permit(:title, :description, :category, :status, :recommended_bounty, :final_bounty, :location_id)
    end
  end
end

