import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../data/mock_data.dart';
import '../services/api_service.dart';

final companyProvider = ChangeNotifierProvider((ref) => CompanyProvider());

class CompanyProvider with ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedRegion = 'all';
  double _minRating = 0.0;
  bool _verifiedOnly = false;
  String _companySize = 'all';
  String _sortBy = 'rating'; // 'rating', 'reviews', 'deals'

  List<Company> _allCompanies = [];
  List<Map<String, String>> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  CompanyProvider() {
    // Initialize data when provider is created
    _initializeData();
  }

  List<Company> get allCompanies => _allCompanies;
  List<Map<String, String>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  List<Company> get filteredCompanies {
    List<Company> result = _allCompanies;

    // Filter by category
    if (_selectedCategory != 'all') {
      result = result.where((c) => c.category == _selectedCategory).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((c) =>
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply filters
    if (_minRating > 0) {
      result = result.where((c) => c.rating >= _minRating).toList();
    }
    if (_verifiedOnly) {
      result = result.where((c) => c.verified).toList();
    }
    if (_selectedRegion != 'all') {
      result = result.where((c) => c.region == _selectedRegion).toList();
    }
    if (_companySize != 'all') {
      result = result.where((c) => c.employees == _companySize).toList();
    }

    // Sort
    result.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'reviews':
          return b.reviewsCount.compareTo(a.reviewsCount);
        case 'deals':
          return b.completedDeals.compareTo(a.completedDeals);
        default:
          return 0;
      }
    });

    return result;
  }

  void handleSearch(
    String query,
    String category,
    String region,
    double minRating,
    bool verified,
    String companySize,
  ) {
    _searchQuery = query;
    _selectedCategory = category;
    _selectedRegion = region;
    _minRating = minRating;
    _verifiedOnly = verified;
    _companySize = companySize;
    notifyListeners();
  }

  void handleCompanyDismissed(Company company) {
    _allCompanies.remove(company);
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Load companies from API
  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Test connection first
      final connectionOk = await ApiService.testConnection();
      if (!connectionOk) {
        // Fallback to mock data if API is not available
        _allCompanies = mockCompanies;
        _categories = categories.map((cat) => {
          'id': cat['id']!,
          'nameKey': cat['nameKey']!,
          'icon': cat['icon']!,
        }).toList();
        _error = 'API недоступен. Используются тестовые данные.';
      } else {
        // Load from API
        _allCompanies = await ApiService.getCompanies(limit: 100);
        _categories = await ApiService.getCategories();
      }
    } catch (e) {
      // Fallback to mock data on error
      _allCompanies = mockCompanies;
      _categories = categories.map((cat) => {
        'id': cat['id']!,
        'nameKey': cat['nameKey']!,
        'icon': cat['icon']!,
      }).toList();
      _error = 'Ошибка загрузки: $e. Используются тестовые данные.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get specific company by ID
  Future<Company?> getCompany(int id) async {
    try {
      return await ApiService.getCompany(id);
    } catch (e) {
      // Fallback to local data
      return _allCompanies.where((c) => c.id == id).firstOrNull;
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Copy error to clipboard
  Future<void> copyErrorToClipboard() async {
    if (_error != null) {
      await Clipboard.setData(ClipboardData(text: _error!));
    }
  }

  // Initialize provider (call this on app start)
  Future<void> initialize() async {
    await loadCompanies();
  }

  // Private initialization method that doesn't cause Riverpod conflicts
  void _initializeData() {
    if (!_initialized) {
      _initialized = true;
      // Load data without notifying listeners during initialization
      Future.delayed(Duration.zero, () async {
        await loadCompanies();
      });
    }
  }
}