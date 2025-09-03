
import 'package:flutter/material.dart';
import '../models/investor.dart';
import 'package:intl/intl.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';

class InvestorCard extends StatelessWidget {
  final Investor investor;
  final VoidCallback onTap;

  const InvestorCard({
    Key? key,
    required this.investor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'ru_RU', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                investor.avatar,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investor.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${AppLocalizations.of(context)!.investmentAmount}: ${currencyFormatter.format(investor.investmentAmount)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: investor.interests
                          .map((interest) => Chip(
                                label: Text(interest),
                                backgroundColor: Colors.blue[100],
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                labelStyle: TextStyle(fontSize: 12, color: Colors.blue[800]),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
