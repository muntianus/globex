
import 'package:flutter/material.dart';
import '../models/investor.dart';
import 'investor_card.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';

class InvestorList extends StatelessWidget {
  final List<Investor> investors;
  final Function(Investor, DismissDirection)? onInvestorDismissed; // New callback

  const InvestorList({
    Key? key,
    required this.investors,
    this.onInvestorDismissed, // Initialize the new callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (investors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.noInvestorsFound, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.tryChangingSearchParams, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: investors.length,
      itemBuilder: (context, index) {
        final investor = investors[index];
        return Dismissible( // Wrap with Dismissible
          key: ValueKey(investor.id), // Unique key for Dismissible
          direction: DismissDirection.horizontal, // Allow horizontal swipes
          onDismissed: (direction) {
            onInvestorDismissed?.call(investor, direction); // Call the callback
          },
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.thumb_up, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.thumb_down, color: Colors.white),
          ),
          child: InvestorCard(
            investor: investor,
            onTap: () {
              // TODO: Implement investor details page navigation
              print(AppLocalizations.of(context)!.tappedOn(investor.name));
            },
          ),
        );
      },
    );
  }
}
