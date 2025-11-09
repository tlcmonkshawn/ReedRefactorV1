import 'package:bootiehunter/services/api_service.dart';
import 'package:bootiehunter/models/bootie.dart';

class BootieService {
  final ApiService apiService;

  BootieService({required this.apiService});

  Future<List<Bootie>> getBooties({
    String? status,
    String? category,
    int? locationId,
    int? userId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;
    if (locationId != null) queryParams['location_id'] = locationId;
    if (userId != null) queryParams['user_id'] = userId;

    final response = await apiService.get('/booties', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Bootie.fromJson(json as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load booties');
  }

  Future<Bootie> getBootie(int id) async {
    final response = await apiService.get('/booties/$id');

    if (response.statusCode == 200) {
      return Bootie.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to load bootie');
  }

  Future<Bootie> createBootie({
    required String title,
    String? description,
    required String category,
    required int locationId,
    String? primaryImageUrl,
    List<String>? alternateImageUrls,
  }) async {
    final response = await apiService.post(
      '/booties',
      data: {
        'bootie': {
          'title': title,
          'description': description,
          'category': category,
          'location_id': locationId,
          'primary_image_url': primaryImageUrl,
          'alternate_image_urls': alternateImageUrls ?? [],
        }
      },
    );

    if (response.statusCode == 201) {
      return Bootie.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception(response.data['error']?['message'] ?? 'Failed to create bootie');
  }

  Future<Bootie> updateBootie(int id, Map<String, dynamic> updates) async {
    final response = await apiService.put(
      '/booties/$id',
      data: {'bootie': updates},
    );

    if (response.statusCode == 200) {
      return Bootie.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception(response.data['error']?['message'] ?? 'Failed to update bootie');
  }

  Future<void> deleteBootie(int id) async {
    final response = await apiService.delete('/booties/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete bootie');
    }
  }

  Future<Bootie> finalizeBootie(int id, double finalBounty) async {
    final response = await apiService.post(
      '/booties/$id/finalize',
      data: {'final_bounty': finalBounty},
    );

    if (response.statusCode == 200) {
      return Bootie.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception(response.data['error']?['message'] ?? 'Failed to finalize bootie');
  }

  Future<void> triggerResearch(int id) async {
    final response = await apiService.post('/booties/$id/research');

    if (response.statusCode != 200) {
      throw Exception(response.data['error']?['message'] ?? 'Failed to trigger research');
    }
  }

  /// Creates a Bootie from an uploaded image URL
  /// This is typically used after image upload and analysis
  Future<Bootie> createBootieFromImage({
    required String imageUrl,
    required int locationId,
    String? title,
    String? description,
    String? category,
  }) async {
    return createBootie(
      title: title ?? 'Untitled Item',
      description: description,
      category: category ?? 'other',
      locationId: locationId,
      primaryImageUrl: imageUrl,
    );
  }
}
