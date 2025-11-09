# Dockerfile for Rails Backend
# Optimized for Cloud Run deployment

FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --deployment --without development test

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids log

# Expose port (Cloud Run uses PORT env var, defaults to 8080)
EXPOSE 8080

# Set production environment
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Start the server
CMD ["bash", "bin/cloud-run-start.sh"]

