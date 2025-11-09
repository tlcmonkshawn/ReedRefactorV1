module Api
  module V1
    class ImagesController < BaseController
      before_action :authenticate_user!

      # POST /api/v1/images/upload
      #
      # Upload an image to Google Cloud Storage
      #
      # Request: multipart/form-data with 'image' file
      # Response: { image_url: "https://storage.googleapis.com/..." }
      def upload
        unless params[:image].present?
          return render_error("Image file is required", code: 'VALIDATION_ERROR', status: :bad_request)
        end

        service = ImageUploadService.new(
          user: current_user,
          image_file: params[:image]
        )

        result = service.upload

        if result.success?
          render json: { image_url: result.data[:url] }, status: :created
        else
          render_error(result.error, code: result.error_code)
        end
      end

      # POST /api/v1/images/process
      #
      # Process an image using AI (editing, enhancement, etc.)
      #
      # Request: { image_url: "...", prompt: "..." }
      # Response: { processed_image_url: "https://storage.googleapis.com/..." }
      def process
        image_url = params[:image_url]
        prompt = params[:prompt]

        unless image_url.present?
          return render_error("image_url is required", code: 'VALIDATION_ERROR', status: :bad_request)
        end

        unless prompt.present?
          return render_error("prompt is required", code: 'VALIDATION_ERROR', status: :bad_request)
        end

        service = ImageProcessingService.new(image_url: image_url)
        result = service.edit_image(prompt)

        if result.success?
          render json: { processed_image_url: result.data[:url] }
        else
          render_error(result.error, code: result.error_code)
        end
      end

      # POST /api/v1/images/analyze
      #
      # Analyze an image to extract title, description, and category
      #
      # Request: { image_url: "..." }
      # Response: { title: "...", description: "...", category: "..." }
      def analyze
        image_url = params[:image_url]

        unless image_url.present?
          return render_error("image_url is required", code: 'VALIDATION_ERROR', status: :bad_request)
        end

        service = ImageProcessingService.new(image_url: image_url)
        result = service.analyze_image

        if result.success?
          render json: result.data
        else
          render_error(result.error, code: result.error_code)
        end
      end
    end
  end
end
