import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bootiehunter/services/api_service.dart';

class ImageService {
  final ApiService apiService;
  final ImagePicker _picker = ImagePicker();

  ImageService({required this.apiService});

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<List<File>> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 85,
    );

    return images.map((xFile) => File(xFile.path)).toList();
  }

  /// Uploads an image file to the backend, which stores it in Google Cloud Storage
  ///
  /// Returns the public URL of the uploaded image
  Future<String> uploadImage(File imageFile) async {
    try {
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Get the underlying Dio instance to make multipart request
      final dio = Dio(BaseOptions(
        baseUrl: apiService.baseUrl,
        headers: {
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 60), // Longer timeout for file uploads
        receiveTimeout: const Duration(seconds: 60),
      ));

      // Add auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Make multipart upload request
      final response = await dio.post(
        '/images/upload',
        data: formData,
      );

      if (response.statusCode == 201) {
        return response.data['image_url'] as String;
      }

      throw Exception(
        response.data['error']?['message'] ?? 'Failed to upload image',
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['error']?['message'] ??
                           e.message ??
                           'Failed to upload image';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// Processes an image using AI (editing, enhancement, etc.)
  ///
  /// Returns the URL of the processed image
  Future<String> processImage(String imageUrl, String prompt) async {
    final response = await apiService.post(
      '/images/process',
      data: {
        'image_url': imageUrl,
        'prompt': prompt,
      },
    );

    if (response.statusCode == 200) {
      return response.data['processed_image_url'] as String;
    }

    throw Exception(
      response.data['error']?['message'] ?? 'Failed to process image',
    );
  }
}
