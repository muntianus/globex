import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'company_provider.dart';

// Create company provider first
final companyProviderProvider = ChangeNotifierProvider((ref) => CompanyProvider());

// Initialize app data when app starts
final appInitializerProvider = FutureProvider<void>((ref) async {
  // Just trigger data loading - let the provider handle its own state
  final provider = ref.read(companyProviderProvider.notifier);
  
  // Schedule initialization after current build cycle
  Future.microtask(() async {
    await provider.initialize();
  });
});