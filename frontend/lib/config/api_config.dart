// API Configuration
// Centralized configuration for API endpoints

class ApiConfig {
  // Get API base URL from environment or use default
  // In production (Cloud Run), this will be set via environment variable
  // In development, use localhost
  static String get baseUrl {
    // Check for environment variable (set in Cloud Run)
    const apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }

    // Check for runtime environment variable (Flutter web)
    // This can be set via window.location or build-time configuration
    if (const bool.fromEnvironment('dart.library.html')) {
      // For web, try to get from window.location or use default
      // In production, this should be the Cloud Run backend URL
      return 'https://reed-refactor-v1-backend-${_getProjectNumber()}-uw.a.run.app';
    }

    // Development default
    return 'http://localhost:3000';
  }

  // Helper to get project number (would need to be set at build time)
  static String _getProjectNumber() {
    // This should be set via build-time environment variable
    const projectNumber = String.fromEnvironment('PROJECT_NUMBER', defaultValue: 'YOUR_PROJECT_NUMBER');
    return projectNumber;
  }

  // API endpoints
  static String get authEndpoint => '$baseUrl/api/v1/auth';
  static String get bootiesEndpoint => '$baseUrl/api/v1/booties';
  static String get locationsEndpoint => '$baseUrl/api/v1/locations';
  static String get promptsEndpoint => '$baseUrl/api/v1/prompts';
  static String get geminiLiveEndpoint => '$baseUrl/api/v1/gemini_live';
  static String get healthEndpoint => '$baseUrl/health';
}

