import 'package:bootiehunter/services/api_service.dart';
import 'package:bootiehunter/models/bootie.dart';

class LocationService {
  final ApiService apiService;

  LocationService({required this.apiService});

  Future<List<Location>> getLocations() async {
    final response = await apiService.get('/locations');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load locations');
  }

  Future<Location> getLocation(int id) async {
    final response = await apiService.get('/locations/$id');

    if (response.statusCode == 200) {
      return Location.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to load location');
  }
}

