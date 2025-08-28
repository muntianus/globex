import 'package:flutter/material.dart';
import '../models/company.dart';
import 'company_card.dart';

class CompanyList extends StatelessWidget {
  final List<Company> companies;
  final Function(Company) onCompanyTap;
  final Function(Company, DismissDirection) onCompanyDismissed;

  const CompanyList({
    Key? key,
    required this.companies,
    required this.onCompanyTap,
    required this.onCompanyDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Компании не найдены',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Попробуйте изменить параметры поиска',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // To be used inside a SingleChildScrollView
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        return Dismissible(
          key: Key(company.id.toString()),
          onDismissed: (direction) {
            onCompanyDismissed(company, direction);
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.green,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          child: CompanyCard(
            company: company,
            onTap: () => onCompanyTap(company),
          ),
        );
      },
    );
  }
}