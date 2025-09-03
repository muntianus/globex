
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../data/mock_data.dart';

final companyProvider = ChangeNotifierProvider((ref) => CompanyProvider());

class CompanyProvider with ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedRegion = 'all';
  double _minRating = 0.0;
  bool _verifiedOnly = false;
  String _companySize = 'all';
  String _sortBy = 'rating'; // 'rating', 'reviews', 'deals'

  final List<Company> _allCompanies = mockCompanies;
  List<Company> get allCompanies => _allCompanies;

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
}
