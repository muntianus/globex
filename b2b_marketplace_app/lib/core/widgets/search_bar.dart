import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart'; // For regions
import '../providers/company_provider.dart'; // For categories
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final Function(String query, String category, String region, double minRating, bool verified, String companySize) onSearch;

  const SearchBarWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedRegion = 'all';
  double _minRating = 0.0;
  bool _verifiedOnly = false;
  String _companySize = 'all';
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    widget.onSearch(
      _searchController.text,
      _selectedCategory,
      _selectedRegion,
      _minRating,
      _verifiedOnly,
      _companySize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchCompaniesServices,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onChanged: (value) {
                    _performSearch(); // Perform search on text change
                  },
                  onSubmitted: (value) {
                    _performSearch(); // Perform search on submit
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: const Icon(Icons.filter_list),
                label: Text(AppLocalizations.of(context)!.filters),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.category,
                      border: OutlineInputBorder(),
                    ),
                    items: ref.watch(companyProvider).categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat['id'],
                        child: Text('${cat['icon']} ${AppLocalizations.of(context)!.translateCategory(cat['nameKey']!)}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _performSearch();
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.region,
                      border: OutlineInputBorder(),
                    ),
                    items: regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region == 'all' ? AppLocalizations.of(context)!.allRegions : region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value!;
                        _performSearch();
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<String>(
                    value: _companySize,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.companySize,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context)!.any)),
                      DropdownMenuItem(value: '10-50', child: Text(AppLocalizations.of(context)!.employees(50))),
                      DropdownMenuItem(value: '50-100', child: Text(AppLocalizations.of(context)!.employees(100))),
                      DropdownMenuItem(value: '100-500', child: Text(AppLocalizations.of(context)!.employees(500))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _companySize = value!;
                        _performSearch();
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<double>(
                    value: _minRating,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.minRating,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 0.0, child: Text('Любой')),
                      DropdownMenuItem(value: 4.0, child: Text('4+')),
                      DropdownMenuItem(value: 4.5, child: Text('4.5+')),
                      DropdownMenuItem(value: 4.8, child: Text('4.8+')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _minRating = value!;
                        _performSearch();
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _verifiedOnly,
                        onChanged: (value) {
                          setState(() {
                            _verifiedOnly = value!;
                            _performSearch();
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.verifiedOnly),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
