import 'package:flutter/material.dart';
import '../models/company.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';

class CompanyDetailsWidget extends StatelessWidget {
  final Company company;

  const CompanyDetailsWidget({Key? key, required this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                company.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const Divider(height: 32),
              _buildInfoRow(Icons.star, AppLocalizations.of(context)!.rating, '${company.rating}/5 (${company.reviewsCount} ${AppLocalizations.of(context)!.reviews})'),
              _buildInfoRow(Icons.check_circle, AppLocalizations.of(context)!.completedDeals, '${company.completedDeals}'),
              _buildInfoRow(Icons.access_time, AppLocalizations.of(context)!.responseTime, company.responseTime),
              if (company.verified) _buildInfoRow(Icons.verified, AppLocalizations.of(context)!.status, AppLocalizations.of(context)!.verified),
              const Divider(height: 32),
              Text(
                AppLocalizations.of(context)!.companyInfo,
                style: Theme.of(context).textTheme.headlineSmall, // Changed from headline6
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.business, AppLocalizations.of(context)!.inn, company.inn),
              _buildInfoRow(Icons.location_on, AppLocalizations.of(context)!.region, company.region),
              _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.yearFounded, '${company.yearFounded}'),
              _buildInfoRow(Icons.people, AppLocalizations.of(context)!.employeesText(company.employees), company.employees),
              const Divider(height: 32),
              Text(
                AppLocalizations.of(context)!.services,
                style: Theme.of(context).textTheme.headlineSmall, // Changed from headline6
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: company.services
                    .map((service) => Chip(label: Text(service)))
                    .toList(),
              ),
              const Divider(height: 32),
              Text(
                AppLocalizations.of(context)!.contacts,
                style: Theme.of(context).textTheme.headlineSmall, // Changed from headline6
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, AppLocalizations.of(context)!.phone, company.phone),
              _buildInfoRow(Icons.email, AppLocalizations.of(context)!.email, company.email),
              _buildInfoRow(Icons.language, AppLocalizations.of(context)!.website, company.website),
              const Divider(height: 32),
              Text(
                AppLocalizations.of(context)!.latestReviews,
                style: Theme.of(context).textTheme.headlineSmall, // Changed from headline6
              ),
              const SizedBox(height: 12),
              if (company.reviews.isEmpty)
                Text(AppLocalizations.of(context)!.noReviewsYet)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: company.reviews.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.author,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < review.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.text,
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  review.date,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}