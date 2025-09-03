
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investor.dart';
import '../data/mock_investors.dart';

class InvestorNotifier extends StateNotifier<List<Investor>> {
  InvestorNotifier() : super(mockInvestors);

  void handleInvestorDismissed(Investor investor) {
    state = state.where((i) => i.id != investor.id).toList();
  }

  // You can add more logic here for filtering, sorting, etc. if needed
}

final investorProvider = StateNotifierProvider<InvestorNotifier, List<Investor>>((ref) {
  return InvestorNotifier();
});
