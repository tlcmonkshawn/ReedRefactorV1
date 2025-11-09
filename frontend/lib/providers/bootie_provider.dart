import 'package:flutter/foundation.dart';
import 'package:bootiehunter/services/bootie_service.dart';
import 'package:bootiehunter/models/bootie.dart';

class BootieProvider with ChangeNotifier {
  final BootieService bootieService;

  List<Bootie> _booties = [];
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _categoryFilter;
  int? _locationFilter;

  BootieProvider({required this.bootieService});

  List<Bootie> get booties => _booties;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;
  int? get locationFilter => _locationFilter;

  List<Bootie> get filteredBooties {
    var filtered = _booties;

    if (_statusFilter != null) {
      filtered = filtered.where((b) => b.status == _statusFilter).toList();
    }

    if (_categoryFilter != null) {
      filtered = filtered.where((b) => b.category == _categoryFilter).toList();
    }

    if (_locationFilter != null) {
      filtered = filtered.where((b) => b.location?.id == _locationFilter).toList();
    }

    return filtered;
  }

  int get pendingCount => _booties.where((b) => 
    b.isSubmitted || b.isResearching || b.isResearched
  ).length;

  Future<void> loadBooties({
    String? status,
    String? category,
    int? locationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _booties = await bootieService.getBooties(
        status: status,
        category: category,
        locationId: locationId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBooties() async {
    await loadBooties(
      status: _statusFilter,
      category: _categoryFilter,
      locationId: _locationFilter,
    );
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setLocationFilter(int? locationId) {
    _locationFilter = locationId;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _locationFilter = null;
    notifyListeners();
  }

  Future<Bootie> createBootie({
    required String title,
    String? description,
    required String category,
    required int locationId,
    String? primaryImageUrl,
  }) async {
    try {
      final bootie = await bootieService.createBootie(
        title: title,
        description: description,
        category: category,
        locationId: locationId,
        primaryImageUrl: primaryImageUrl,
      );
      _booties.insert(0, bootie);
      notifyListeners();
      return bootie;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> finalizeBootie(int id, double finalBounty) async {
    try {
      final updated = await bootieService.finalizeBootie(id, finalBounty);
      final index = _booties.indexWhere((b) => b.id == id);
      if (index != -1) {
        _booties[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> triggerResearch(int id) async {
    try {
      await bootieService.triggerResearch(id);
      await refreshBooties();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

