class JwtService
  # Lazy-load secret key to avoid accessing Rails.application during class definition
  def self.secret_key
    @secret_key ||= begin
      key = ENV['JWT_SECRET_KEY'] || ENV['SECRET_KEY_BASE'] || (Rails.application.secret_key_base if defined?(Rails) && Rails.application)
      if key.nil? || key.empty?
        Rails.logger.error "JwtService: No secret key found! Check SECRET_KEY_BASE or JWT_SECRET_KEY environment variables."
        raise ArgumentError, "Missing JWT secret key. Set SECRET_KEY_BASE or JWT_SECRET_KEY environment variable."
      end
      key
    end
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, 'HS256')
  rescue ArgumentError => e
    Rails.logger.error "JwtService.encode error: #{e.message}"
    raise
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
    decoded[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
