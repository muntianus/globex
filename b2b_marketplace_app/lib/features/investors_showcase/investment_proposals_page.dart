import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/investment_proposal.dart';
import '../../core/providers/investment_provider.dart';
import 'package:b2b_marketplace_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class InvestmentProposalsPage extends ConsumerStatefulWidget {
  const InvestmentProposalsPage({super.key});

  @override
  ConsumerState<InvestmentProposalsPage> createState() => _InvestmentProposalsPageState();
}

class _InvestmentProposalsPageState extends ConsumerState<InvestmentProposalsPage> {
  String _selectedIndustry = 'all';
  String _selectedStage = 'all';
  String _selectedType = 'all';
  double _minInvestment = 0;
  double _maxInvestment = 50000000;

  final List<String> _industries = [
    'all', 'Финансовые технологии', 'Строительство', 'Логистика', 
    'Розничная торговля', 'Профессиональные услуги', 'IT и разработка', 
    'Производство', 'Недвижимость', 'Здравоохранение'
  ];
  
  final List<String> _stages = [
    'all', 'startup', 'growth', 'expansion', 'mature'
  ];
  
  final List<String> _types = [
    'all', 'equity', 'debt', 'hybrid'
  ];

  @override
  Widget build(BuildContext context) {
    final proposals = ref.watch(investmentProvider);
    final filteredProposals = _filterProposals(proposals);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Инвестиционные предложения'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Фильтры
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedIndustry,
                        decoration: const InputDecoration(
                          labelText: 'Отрасль',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _industries.map((industry) {
                          return DropdownMenuItem(
                            value: industry,
                            child: Text(industry == 'all' ? 'Все отрасли' : industry),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedIndustry = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStage,
                        decoration: const InputDecoration(
                          labelText: 'Стадия',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _stages.map((stage) {
                          return DropdownMenuItem(
                            value: stage,
                            child: Text(stage == 'all' ? 'Все стадии' : _getStageLabel(stage)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedStage = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Тип инвестиций',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type == 'all' ? 'Все типы' : _getTypeLabel(type)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Найдено: ${filteredProposals.length} предложений'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Список предложений
          Expanded(
            child: filteredProposals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Нет предложений по выбранным критериям'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProposals.length,
                    itemBuilder: (context, index) {
                      final proposal = filteredProposals[index];
                      return InvestmentProposalCard(proposal: proposal);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<InvestmentProposal> _filterProposals(List<InvestmentProposal> proposals) {
    return proposals.where((proposal) {
      if (_selectedIndustry != 'all' && proposal.industry != _selectedIndustry) {
        return false;
      }
      if (_selectedStage != 'all' && proposal.businessStage != _selectedStage) {
        return false;
      }
      if (_selectedType != 'all' && proposal.investmentType != _selectedType) {
        return false;
      }
      if (proposal.investmentAmount < _minInvestment || 
          proposal.investmentAmount > _maxInvestment) {
        return false;
      }
      return true;
    }).toList();
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case 'startup': return 'Стартап';
      case 'growth': return 'Рост';
      case 'expansion': return 'Экспансия';
      case 'mature': return 'Зрелая компания';
      default: return stage;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'equity': return 'Доля';
      case 'debt': return 'Долг';
      case 'hybrid': return 'Смешанный';
      default: return type;
    }
  }
}

class InvestmentProposalCard extends StatelessWidget {
  final InvestmentProposal proposal;

  const InvestmentProposalCard({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProposalDetails(context, proposal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и сумма
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proposal.industry,
                          style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${formatter.format(proposal.investmentAmount)} ₽',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Описание
              Text(
                proposal.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Метрики
              Row(
                children: [
                  _buildMetric('Доля', '${proposal.equityPercentage?.toStringAsFixed(1)}%'),
                  const SizedBox(width: 16),
                  _buildMetric('Доходность', '${proposal.expectedReturn?.toStringAsFixed(1)}%'),
                  const SizedBox(width: 16),
                  _buildMetric('Стадия', _getStageLabel(proposal.businessStage)),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Дополнительная информация
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(proposal.location, style: TextStyle(color: Colors.grey[600])),
                  const Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${proposal.viewsCount} просмотров', style: TextStyle(color: Colors.grey[600])),
                  if (proposal.fundingDeadline != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 4),
                    Text(
                      'До ${DateFormat('dd.MM.yyyy').format(proposal.fundingDeadline!)}',
                      style: TextStyle(color: Colors.orange[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case 'startup': return 'Стартап';
      case 'growth': return 'Рост';
      case 'expansion': return 'Экспансия';
      case 'mature': return 'Зрелая';
      default: return stage;
    }
  }

  void _showProposalDetails(BuildContext context, InvestmentProposal proposal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InvestmentProposalDetails(proposal: proposal),
    );
  }
}

class InvestmentProposalDetails extends StatelessWidget {
  final InvestmentProposal proposal;

  const InvestmentProposalDetails({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Основные метрики
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildDetailMetric('Сумма инвестиций', '${formatter.format(proposal.investmentAmount)} ₽'),
                        _buildDetailMetric('Доля', '${proposal.equityPercentage?.toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailMetric('Ожидаемая доходность', '${proposal.expectedReturn?.toStringAsFixed(1)}%'),
                        _buildDetailMetric('Тип инвестиций', _getTypeLabel(proposal.investmentType)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Описание
              _buildSection('Описание проекта', proposal.description),
              
              if (proposal.useOfFunds != null)
                _buildSection('Использование средств', proposal.useOfFunds!),
              
              if (proposal.financialHighlights != null)
                _buildSection('Финансовые показатели', proposal.financialHighlights!),
              
              if (proposal.teamInfo != null)
                _buildSection('Команда', proposal.teamInfo!),
              
              if (proposal.marketOpportunity != null)
                _buildSection('Рыночные возможности', proposal.marketOpportunity!),
              
              if (proposal.competitiveAdvantages != null)
                _buildSection('Конкурентные преимущества', proposal.competitiveAdvantages!),
              
              if (proposal.risks != null)
                _buildSection('Риски', proposal.risks!),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement interest functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Интерес отправлен!')),
                        );
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Проявить интерес'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement contact functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Контакты запрошены!')),
                        );
                      },
                      icon: const Icon(Icons.contact_mail),
                      label: const Text('Связаться'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'equity': return 'Доля в капитале';
      case 'debt': return 'Долговое финансирование';
      case 'hybrid': return 'Смешанное финансирование';
      default: return type;
    }
  }
}