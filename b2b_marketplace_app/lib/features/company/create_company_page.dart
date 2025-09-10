import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/company.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/api_service.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CreateCompanyPage extends ConsumerStatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  ConsumerState<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends ConsumerState<CreateCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _innController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _yearFoundedController = TextEditingController();
  
  String _selectedCategory = 'manufacturing';
  String _selectedRegion = 'Москва';
  String _selectedEmployees = '10-50';
  String _selectedLogo = '🏢';
  bool _isLoading = false;

  final List<String> _logos = ['🏢', '🏭', '🏪', '🏬', '🏛️', '🏦', '🏤', '🏣', '🏗️', '🏘️'];
  final List<String> _regions = [
    'Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань',
    'Нижний Новгород', 'Челябинск', 'Самара', 'Омск', 'Ростов-на-Дону'
  ];
  final List<String> _employeeSizes = ['10-50', '50-100', '100-500', '500+'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _innController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _yearFoundedController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final companyData = {
        'name': _nameController.text.trim(),
        'category_id': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'inn': _innController.text.trim(),
        'region': _selectedRegion,
        'year_founded': int.parse(_yearFoundedController.text.trim()),
        'employees': _selectedEmployees,
        'logo': _selectedLogo,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'website': _websiteController.text.trim(),
        'verified': false,
        'rating': 0.0,
        'reviews_count': 0,
        'completed_deals': 0,
      };

      await ApiService.createCompany(companyData);

      // Refresh companies list
      ref.read(companyProvider.notifier).loadCompanies();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Компания успешно создана!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания компании: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyNotifier = ref.watch(companyProvider);
    final categories = companyNotifier.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать компанию'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Название компании
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название компании *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Введите название компании' : null,
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<String>(
              value: _selectedCategory == 'all' ? categories.first['id'] : _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория *',
                border: OutlineInputBorder(),
              ),
              items: categories.where((cat) => cat['id'] != 'all').map((cat) {
                return DropdownMenuItem(
                  value: cat['id'],
                  child: Text('${cat['icon']} ${cat['nameKey']}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Введите описание' : null,
            ),
            const SizedBox(height: 16),

            // ИНН
            TextFormField(
              controller: _innController,
              decoration: const InputDecoration(
                labelText: 'ИНН *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.trim().isEmpty == true) return 'Введите ИНН';
                if (value!.length < 10) return 'ИНН должен содержать минимум 10 цифр';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Регион
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Регион',
                border: OutlineInputBorder(),
              ),
              items: _regions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value!),
            ),
            const SizedBox(height: 16),

            // Год основания
            TextFormField(
              controller: _yearFoundedController,
              decoration: const InputDecoration(
                labelText: 'Год основания *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.trim().isEmpty == true) return 'Введите год основания';
                final year = int.tryParse(value!);
                if (year == null || year < 1900 || year > DateTime.now().year) {
                  return 'Введите корректный год';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Количество сотрудников
            DropdownButtonFormField<String>(
              value: _selectedEmployees,
              decoration: const InputDecoration(
                labelText: 'Количество сотрудников',
                border: OutlineInputBorder(),
              ),
              items: _employeeSizes.map((size) {
                return DropdownMenuItem(value: size, child: Text(size));
              }).toList(),
              onChanged: (value) => setState(() => _selectedEmployees = value!),
            ),
            const SizedBox(height: 16),

            // Телефон
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Введите телефон' : null,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.trim().isEmpty == true) return 'Введите email';
                if (!value!.contains('@')) return 'Введите корректный email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Веб-сайт
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Веб-сайт *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Введите веб-сайт' : null,
            ),
            const SizedBox(height: 16),

            // Логотип
            const Text('Выберите логотип:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _logos.map((logo) {
                return FilterChip(
                  label: Text(logo, style: const TextStyle(fontSize: 20)),
                  selected: _selectedLogo == logo,
                  onSelected: (selected) => setState(() => _selectedLogo = logo),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Кнопка создания
            ElevatedButton(
              onPressed: _isLoading ? null : _createCompany,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Создать компанию', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}