import 'package:flutter/material.dart';
import 'models/company.dart';
import 'data/mock_data.dart';
import 'widgets/company_card.dart';
import 'widgets/company_list.dart';
import 'widgets/search_bar.dart';
import 'widgets/company_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B2B Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedRegion = 'all';
  double _minRating = 0.0;
  bool _verifiedOnly = false;
  String _companySize = 'all';
  String _sortBy = 'rating'; // 'rating', 'reviews', 'deals'

  final List<Company> _allCompanies = mockCompanies;
  final PageController _carouselController = PageController(viewportFraction: 0.8);

  List<Company> get _filteredCompanies {
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

  void _handleSearch(
    String query,
    String category,
    String region,
    double minRating,
    bool verified,
    String companySize,
  ) {
    setState(() {
      _searchQuery = query;
      _selectedCategory = category;
      _selectedRegion = region;
      _minRating = minRating;
      _verifiedOnly = verified;
      _companySize = companySize;
    });
  }

  void _showCompanyDetails(Company company) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompanyDetailsWidget(company: company);
      },
    );
  }

  void _handleCompanyDismissed(Company company, DismissDirection direction) {
    setState(() {
      _allCompanies.remove(company);
    });
    if (direction == DismissDirection.startToEnd) {
      print('${company.name} swiped right (liked)');
    } else {
      print('${company.name} swiped left (disliked)');
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Company> promoCompanies = _allCompanies.where((c) => c.verified).take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () {
              // TODO: Implement add company functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              // TODO: Implement login functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            SearchBarWidget(onSearch: _handleSearch),

            // Promo Carousel
            if (promoCompanies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Рекомендуемые партнёры',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150.0, // Height of the carousel
                      child: PageView.builder(
                        controller: _carouselController,
                        itemCount: promoCompanies.length,
                        itemBuilder: (context, index) {
                          final company = promoCompanies[index];
                          return GestureDetector(
                            onTap: () => _showCompanyDetails(company),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    company.logo,
                                    style: const TextStyle(fontSize: 40, color: Colors.white),
                                  ),
                                  Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    company.description,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Main Content: Categories and Company List
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories Sidebar
                SizedBox(
                  width: 150, // Fixed width for sidebar
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        title: Text('${category['icon']} ${category['name']}'),
                        selected: _selectedCategory == category['id'],
                        onTap: () {
                          setState(() {
                            _selectedCategory = category['id']!;
                            _handleSearch(
                              _searchQuery,
                              _selectedCategory,
                              _selectedRegion,
                              _minRating,
                              _verifiedOnly,
                              _companySize,
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
                // Company List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Найдено компаний: ${_filteredCompanies.length}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            DropdownButton<String>(
                              value: _sortBy,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sortBy = newValue!;
                                });
                              },
                              items: const <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'rating',
                                  child: Text('По рейтингу'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'reviews',
                                  child: Text('По отзывам'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'deals',
                                  child: Text('По сделкам'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CompanyList(
                        companies: _filteredCompanies,
                        onCompanyTap: _showCompanyDetails,
                        onCompanyDismissed: _handleCompanyDismissed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
