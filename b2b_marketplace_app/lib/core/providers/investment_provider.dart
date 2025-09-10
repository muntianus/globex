import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_proposal.dart';
import '../services/api_service.dart';

final investmentProvider = ChangeNotifierProvider((ref) => InvestmentProvider());

class InvestmentProvider with ChangeNotifier {
  List<InvestmentProposal> _proposals = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  InvestmentProvider() {
    _initializeData();
  }

  List<InvestmentProposal> get proposals => _proposals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeData() {
    if (!_initialized) {
      _initialized = true;
      // Load data without notifying listeners during initialization
      Future.delayed(Duration.zero, () async {
        await loadProposals();
      });
    }
  }

  Future<void> loadProposals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate mock data for now - later replace with API call
      _proposals = _generateMockProposals();
    } catch (e) {
      _error = 'Ошибка загрузки предложений: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<InvestmentProposal> _generateMockProposals() {
    return [
      InvestmentProposal(
        id: 1,
        companyId: 1,
        title: 'Экспансия производства стройматериалов',
        description: 'СтройМастер планирует расширение производственных мощностей и выход на новые региональные рынки. Компания показывает стабильный рост 25% год к году.',
        investmentAmount: 5000000.00,
        equityPercentage: 15.00,
        expectedReturn: 22.00,
        investmentType: 'equity',
        businessStage: 'growth',
        industry: 'Строительство',
        location: 'Москва',
        minInvestment: 500000.00,
        maxInvestment: 2000000.00,
        fundingDeadline: DateTime(2025, 6, 30),
        useOfFunds: 'Покупка нового оборудования (60%), маркетинг и продажи (25%), оборотный капитал (15%)',
        financialHighlights: 'Выручка 2023: 45М руб, EBITDA: 12М руб, Рост клиентской базы: +40% за год',
        teamInfo: 'Команда из 8 опытных специалистов, средний опыт 12 лет. Генеральный директор - MBA',
        marketOpportunity: 'Рынок стройматериалов растет 8% в год. Планируемая доля в регионе: 5%',
        competitiveAdvantages: 'Собственное производство, прямые контракты с поставщиками, IT-система управления',
        risks: 'Конкуренция, изменение цен на сырье, экономические риски',
        status: 'active',
        viewsCount: 156,
        interestedInvestors: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InvestmentProposal(
        id: 2,
        companyId: 3,
        title: 'FinTech стартап - платежная система',
        description: 'Инновационное решение для B2B платежей с использованием блокчейн технологий. Готовый MVP, первые клиенты уже подключены.',
        investmentAmount: 15000000.00,
        equityPercentage: 25.00,
        expectedReturn: 35.00,
        investmentType: 'equity',
        businessStage: 'startup',
        industry: 'Финансовые технологии',
        location: 'Москва',
        minInvestment: 1000000.00,
        maxInvestment: 5000000.00,
        fundingDeadline: DateTime(2025, 3, 31),
        useOfFunds: 'Разработка продукта (50%), команда разработчиков (30%), маркетинг (20%)',
        financialHighlights: 'Pre-revenue стадия, подписано 5 LOI с крупными клиентами на общую сумму 8М руб/год',
        teamInfo: 'CTO с опытом в Яндексе, CEO - бывший Goldman Sachs, команда 15 разработчиков',
        marketOpportunity: 'Рынок B2B платежей в России: 2.5 трлн руб. TAM нашего сегмента: 150 млрд руб',
        competitiveAdvantages: 'Blockchain архитектура, патенты на алгоритмы, партнерства с банками',
        risks: 'Регулятивные изменения, технические риски, конкуренция с банками',
        status: 'active',
        viewsCount: 289,
        interestedInvestors: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InvestmentProposal(
        id: 3,
        companyId: 2,
        title: 'Логистическая сеть "Быстрая Доставка"',
        description: 'Развитие сети складов и автоматизация процессов доставки. Внедрение собственной IT-платформы для оптимизации маршрутов.',
        investmentAmount: 8000000.00,
        equityPercentage: 20.00,
        expectedReturn: 28.00,
        investmentType: 'hybrid',
        businessStage: 'expansion',
        industry: 'Логистика',
        location: 'Санкт-Петербург',
        minInvestment: 800000.00,
        maxInvestment: 3000000.00,
        fundingDeadline: DateTime(2025, 5, 15),
        useOfFunds: 'Строительство складов (40%), IT-разработка (35%), закупка транспорта (25%)',
        financialHighlights: 'Выручка 2023: 180М руб, чистая прибыль: 25М руб, ROE: 18%',
        teamInfo: 'Управленческая команда с опытом в X5 Retail Group, сертифицированные логисты',
        marketOpportunity: 'E-commerce растет 20% в год, потребность в быстрой доставке увеличивается',
        competitiveAdvantages: 'Собственная IT-платформа, договоры с ритейлерами, покрытие 5 регионов',
        risks: 'Рост цен на топливо, изменения в регулировании, конкуренция',
        status: 'active',
        viewsCount: 203,
        interestedInvestors: 17,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      InvestmentProposal(
        id: 4,
        companyId: 4,
        title: 'Расширение сети магазинов автозапчастей',
        description: 'АвтоЗапчасти+ планирует открытие 12 новых точек в Московской области и запуск интернет-магазина с доставкой.',
        investmentAmount: 3500000.00,
        equityPercentage: 12.00,
        expectedReturn: 20.00,
        investmentType: 'debt',
        businessStage: 'mature',
        industry: 'Розничная торговля',
        location: 'Московская область',
        minInvestment: 350000.00,
        maxInvestment: 1500000.00,
        fundingDeadline: DateTime(2025, 8, 31),
        useOfFunds: 'Открытие новых магазинов (70%), разработка интернет-магазина (20%), маркетинг (10%)',
        financialHighlights: 'Стабильная прибыльность 5 лет подряд, средняя маржинальность 28%',
        teamInfo: 'Основатели с 15-летним опытом в автобизнесе, команда из 45 сотрудников',
        marketOpportunity: 'Рынок автозапчастей стабилен, высокий уровень повторных покупок',
        competitiveAdvantages: 'Прямые поставки от производителей, лояльная клиентская база',
        risks: 'Экономический спад, изменения в автомобильной отрасли',
        status: 'active',
        viewsCount: 134,
        interestedInvestors: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      InvestmentProposal(
        id: 5,
        companyId: 5,
        title: 'Цифровизация налогового консалтинга',
        description: 'НалогСервис внедряет AI-решения для автоматизации налогового планирования и подготовки отчетности для малого и среднего бизнеса.',
        investmentAmount: 2500000.00,
        equityPercentage: 18.00,
        expectedReturn: 25.00,
        investmentType: 'equity',
        businessStage: 'growth',
        industry: 'Профессиональные услуги',
        location: 'Москва',
        minInvestment: 250000.00,
        maxInvestment: 1000000.00,
        fundingDeadline: DateTime(2025, 4, 30),
        useOfFunds: 'Разработка AI-платформы (60%), маркетинг (25%), расширение команды (15%)',
        financialHighlights: 'Клиентская база 450+ компаний, средний чек 85 тыс руб/год, retention rate 92%',
        teamInfo: 'Команда из сертифицированных налоговых консультантов и AI-разработчиков',
        marketOpportunity: 'Цифровизация учета и отчетности - тренд роста 15% год к году',
        competitiveAdvantages: 'Уникальные алгоритмы, экспертиза в налогообложении, автоматизация',
        risks: 'Изменения в налоговом законодательстве, конкуренция с 1С',
        status: 'active',
        viewsCount: 97,
        interestedInvestors: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}