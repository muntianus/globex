
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:b2b_marketplace_app/core/widgets/company_list.dart';
import 'package:b2b_marketplace_app/core/models/company.dart';
import 'package:b2b_marketplace_app/core/data/mock_data.dart';

void main() {
  group('CompanyList Widget Tests', () {
    testWidgets('Shows "Компании не найдены" message when companies list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanyList(
              companies: [],
              onCompanyTap: (_) {},
              onCompanyDismissed: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Компании не найдены'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Shows a list of companies when companies list is not empty', (WidgetTester tester) async {
      final companies = mockCompanies.take(3).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanyList(
              companies: companies,
              onCompanyTap: (_) {},
              onCompanyDismissed: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Dismissible), findsNWidgets(3));
    });
  });
}
