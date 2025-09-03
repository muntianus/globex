
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../core/data/mock_investors.dart'; // Keep for initial data
import '../../core/widgets/investor_list.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';
import '../../core/providers/investor_provider.dart'; // New import

class InvestorPage extends ConsumerWidget { // Change to ConsumerWidget
  const InvestorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef ref
    final investors = ref.watch(investorProvider); // Watch the investor provider

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.investors),
      ),
      body: InvestorList(
        investors: investors, // Use investors from provider
        onInvestorDismissed: (investor, direction) { // Add onInvestorDismissed callback
          ref.read(investorProvider.notifier).handleInvestorDismissed(investor);
          if (direction == DismissDirection.startToEnd) {
            print('Investor ${investor.name} swiped right (liked)');
          } else {
            print('Investor ${investor.name} swiped left (disliked)');
          }
        },
      ),
    );
  }
}
