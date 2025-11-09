module Admin
  class PromptsController < BaseController
    before_action :set_prompt, only: [:show, :edit, :update, :destroy]

    def index
      @prompts = Prompt.order(:category, :sort_order, :name)
      @categories = Prompt.pluck(:category).uniq.sort
    end

    def show
    end

    def new
      @prompt = Prompt.new
    end

    def create
      @prompt = Prompt.new(prompt_params)
      
      if @prompt.save
        redirect_to admin_prompt_path(@prompt), notice: 'Prompt was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @prompt.update(prompt_params)
        redirect_to admin_prompt_path(@prompt), notice: 'Prompt was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @prompt.destroy
      redirect_to admin_prompts_path, notice: 'Prompt was successfully deleted.'
    end

    private

    def set_prompt
      @prompt = Prompt.find(params[:id])
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
  end
end

