# ApplicationService - Base class for all service objects
#
# Service objects encapsulate business logic and follow a consistent pattern:
# - Inherit from ApplicationService
# - Implement #call method
# - Return success(data) or failure(error_message, error_code)
#
# Usage:
#   result = ServiceName.call(params)
#   if result.success?
#     # Handle success with result.data
#   else
#     # Handle failure with result.error and result.error_code
#   end
#
# @see ARCHITECTURE.md for service layer architecture
class ApplicationService
  # Class method to instantiate and call service in one line
  # Allows ServiceName.call(params) instead of ServiceName.new(params).call
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end

  # Subclasses must implement this method
  def call
    raise NotImplementedError, "Subclass must implement #call method"
  end

  private

  # Return a successful ServiceResult with optional data
  def success(data = nil)
    ServiceResult.new(success: true, data: data)
  end

  # Return a failed ServiceResult with error message and optional error code
  def failure(error_message, error_code = nil)
    ServiceResult.new(success: false, error: error_message, error_code: error_code)
  end
end

# ServiceResult - Standardized return value for service objects
#
# Provides consistent interface for handling service results:
# - success? / failure? - Boolean checks
# - data - Success data (if successful)
# - error - Error message (if failed)
# - error_code - Error code for programmatic error handling
class ServiceResult
  attr_reader :data, :error, :error_code

  def initialize(success:, data: nil, error: nil, error_code: nil)
    @success = success
    @data = data
    @error = error
    @error_code = error_code
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

