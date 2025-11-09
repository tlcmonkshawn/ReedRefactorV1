import 'package:bootiehunter/models/prompt.dart';
import 'package:bootiehunter/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PromptService {
  final ApiService _apiService;
  static List<Prompt>? _cachedPrompts;
  static DateTime? _lastCacheUpdate;
  static const String _cacheKey = 'prompts_cache';
  static const String _cacheTimestampKey = 'prompts_cache_timestamp';
  static const String _lastUpdatedKey = 'prompts_last_updated_at';

  PromptService(this._apiService);

  // Load prompts from cache at startup
  Future<void> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestampStr = prefs.getString(_cacheTimestampKey);

      if (cachedJson != null && timestampStr != null) {
        final List<dynamic> data = json.decode(cachedJson);
        _cachedPrompts = data.map((json) => Prompt.fromJson(json)).toList();
        _lastCacheUpdate = DateTime.parse(timestampStr);
      }
    } catch (e) {
      // If cache load fails, clear it
      _cachedPrompts = null;
      _lastCacheUpdate = null;
    }
  }

  // Save prompts to local cache
  Future<void> _saveCache(List<Prompt> prompts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final promptsJson = json.encode(prompts.map((p) => p.toJson()).toList());
      await prefs.setString(_cacheKey, promptsJson);
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      _cachedPrompts = prompts;
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      // Cache save failed, but continue
    }
  }

  // Check if prompts have been updated on server
  Future<bool> checkForUpdates() async {
    try {
      final response = await _apiService.get('/prompt_cache/check_updates');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final serverLastUpdated = data['last_updated_at'] as String?;
        final cacheStale = data['cache_stale'] as bool? ?? false;

        if (serverLastUpdated == null) {
          return false; // No prompts on server
        }

        final prefs = await SharedPreferences.getInstance();
        final cachedLastUpdated = prefs.getString(_lastUpdatedKey);

        if (cachedLastUpdated == null || cachedLastUpdated != serverLastUpdated) {
          await prefs.setString(_lastUpdatedKey, serverLastUpdated);
          return true; // Cache needs update
        }

        return cacheStale;
      }
      return false;
    } catch (e) {
      return false; // If check fails, assume cache is fine
    }
  }

  // Get all prompts (from cache or API)
  Future<List<Prompt>> getPrompts({String? category, String? model, bool forceRefresh = false}) async {
    // Check if we need to refresh cache
    if (forceRefresh || _cachedPrompts == null || await checkForUpdates()) {
      await _fetchAndCachePrompts();
    }

    var prompts = _cachedPrompts ?? [];

    // Apply filters
    if (category != null) {
      prompts = prompts.where((p) => p.category == category).toList();
    }
    if (model != null) {
      prompts = prompts.where((p) => p.model == model).toList();
    }

    return prompts;
  }

  // Fetch prompts from API and cache them
  Future<void> _fetchAndCachePrompts() async {
    try {
      final response = await _apiService.get('/prompts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final prompts = data.map((json) => Prompt.fromJson(json)).toList();
        await _saveCache(prompts);

        // Also save the last updated timestamp
        if (prompts.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final maxUpdated = prompts.map((p) => p.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
          await prefs.setString(_lastUpdatedKey, maxUpdated.toIso8601String());
        }
      }
    } catch (e) {
      // If fetch fails, keep using cached data if available
      if (_cachedPrompts == null) {
        rethrow;
      }
    }
  }

  // Get a single prompt by ID (from cache)
  Future<Prompt?> getPrompt(int id) async {
    // Load prompts if not cached
    if (_cachedPrompts == null) {
      await getPrompts();
    }

    try {
      return _cachedPrompts?.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }


  // Get prompts by category (from cache)
  Future<List<Prompt>> getPromptsByCategory(String category) async {
    return await getPrompts(category: category);
  }

  // Get prompt by category and name (from cache)
  Future<Prompt?> getPromptByName(String category, String name) async {
    final prompts = await getPrompts(category: category);
    try {
      return prompts.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  // Create a new prompt (invalidates cache)
  Future<Prompt> createPrompt(Prompt prompt) async {
    final response = await _apiService.post(
      '/prompts',
      data: prompt.toCreateJson(),
    );

    if (response.statusCode == 201) {
      final created = Prompt.fromJson(response.data as Map<String, dynamic>);
      // Force cache refresh on next access
      _cachedPrompts = null;
      return created;
    } else {
      final errorData = response.data as Map<String, dynamic>?;
      throw Exception('Failed to create prompt: ${errorData?['error']?['message'] ?? response.statusCode}');
    }
  }

  // Update an existing prompt (invalidates cache)
  Future<Prompt> updatePrompt(Prompt prompt) async {
    final response = await _apiService.put(
      '/prompts/${prompt.id}',
      data: prompt.toCreateJson(),
    );

    if (response.statusCode == 200) {
      final updated = Prompt.fromJson(response.data as Map<String, dynamic>);
      // Force cache refresh on next access
      _cachedPrompts = null;
      return updated;
    } else {
      final errorData = response.data as Map<String, dynamic>?;
      throw Exception('Failed to update prompt: ${errorData?['error']?['message'] ?? response.statusCode}');
    }
  }

  // Delete a prompt (invalidates cache)
  Future<void> deletePrompt(int id) async {
    final response = await _apiService.delete('/prompts/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete prompt: ${response.statusCode}');
    }

    // Force cache refresh on next access
    _cachedPrompts = null;
  }

  // Clear local cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
    await prefs.remove(_lastUpdatedKey);
    _cachedPrompts = null;
    _lastCacheUpdate = null;
  }
}
