import 'package:dio/dio.dart';
import 'package:bootiehunter/services/api_service.dart';

/// Service for analyzing images using AI
///
/// This service calls the backend to analyze images and extract:
/// - Title
/// - Description
/// - Category
class ImageAnalysisService {
  final ApiService apiService;

  ImageAnalysisService({required this.apiService});

  /// Analyzes an image URL and returns AI-generated metadata
  ///
  /// Returns a map with: title, description, category
  Future<Map<String, dynamic>> analyzeImage(String imageUrl) async {
    try {
      final response = await apiService.post(
        '/images/analyze',
        data: {'image_url': imageUrl},
      );

      if (response.statusCode == 200) {
        return {
          'title': response.data['title'] as String? ?? 'Untitled Item',
          'description': response.data['description'] as String? ?? '',
          'category': response.data['category'] as String? ?? 'other',
        };
      }

      throw Exception(
        response.data['error']?['message'] ?? 'Failed to analyze image',
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['error']?['message'] ??
                           e.message ??
                           'Failed to analyze image';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }
}
