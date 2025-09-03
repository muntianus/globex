
import 'package:flutter_test/flutter_test.dart';
import 'package:b2b_marketplace_app/core/providers/company_provider.dart';
import 'package:b2b_marketplace_app/core/models/company.dart';

void main() {
  group('CompanyProvider', () {
    late CompanyProvider companyProvider;

    setUp(() {
      companyProvider = CompanyProvider();
    });

    test('Initial values are correct', () {
      expect(companyProvider.filteredCompanies.length, greaterThan(0));
      expect(companyProvider.sortBy, 'rating');
      expect(companyProvider.selectedCategory, 'all');
    });

    test('setSortBy changes the sorting', () {
      companyProvider.setSortBy('reviews');
      expect(companyProvider.sortBy, 'reviews');
    });

    test('setSelectedCategory changes the category', () {
      companyProvider.setSelectedCategory('tech');
      expect(companyProvider.selectedCategory, 'tech');
      // You might want to add more specific assertions here based on your mock data
      expect(companyProvider.filteredCompanies.every((c) => c.category == 'tech'), isTrue);
    });

    test('handleSearch filters the list', () {
      companyProvider.handleSearch('Tech', 'all', 'all', 0.0, false, 'all');
      expect(companyProvider.filteredCompanies.every((c) => c.name.toLowerCase().contains('tech')), isTrue);
    });

    test('handleCompanyDismissed removes a company', () {
      final initialCount = companyProvider.allCompanies.length;
      final companyToDismiss = companyProvider.allCompanies.first;
      companyProvider.handleCompanyDismissed(companyToDismiss);
      expect(companyProvider.allCompanies.length, initialCount - 1);
      expect(companyProvider.allCompanies.contains(companyToDismiss), isFalse);
    });
  });
}
