
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/company.dart';
import '../../core/data/mock_data.dart';
import '../../core/widgets/company_list.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/company_details.dart';
import '../../core/providers/company_provider.dart'; // This will be the Riverpod provider
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController _carouselController = PageController(viewportFraction: 0.8);
    final companyNotifier = ref.watch(companyProvider);
    final filteredCompanies = companyNotifier.filteredCompanies;
    final promoCompanies = companyNotifier.allCompanies.where((c) => c.verified).take(3).toList();

    void _showCompanyDetails(Company company) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CompanyDetailsWidget(company: company);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on),
            onPressed: () {
              context.go('/investors'); // Use context.go now
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6), // Theme toggle icon
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
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
            SearchBarWidget(onSearch: (query, category, region, minRating, verified, companySize) {
              ref.read(companyProvider).handleSearch(query, category, region, minRating, verified, companySize);
            }),

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
                        AppLocalizations.of(context)!.recommendedPartners,
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
                        selected: companyNotifier.selectedCategory == category['id'],
                        onTap: () {
                          ref.read(companyProvider).setSelectedCategory(category['id']!);
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
                              AppLocalizations.of(context)!.companiesFound,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            DropdownButton<String>(
                              value: companyNotifier.sortBy,
                              onChanged: (String? newValue) {
                                ref.read(companyProvider).setSortBy(newValue!);
                              },
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'rating',
                                  child: Text(AppLocalizations.of(context)!.sortByRating),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'reviews',
                                  child: Text(AppLocalizations.of(context)!.sortByReviews),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'deals',
                                  child: Text(AppLocalizations.of(context)!.sortByDeals),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CompanyList(
                        companies: filteredCompanies,
                        onCompanyTap: _showCompanyDetails,
                        onCompanyDismissed: (company, direction) {
                          ref.read(companyProvider).handleCompanyDismissed(company);
                           if (direction == DismissDirection.startToEnd) {
                              print(AppLocalizations.of(context)!.swipedRightLiked(company.name));
                            } else {
                              print(AppLocalizations.of(context)!.swipedLeftDisliked(company.name));
                            }
                        },
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
