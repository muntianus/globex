import '../models/company.dart';

final List<Map<String, dynamic>> mockCompaniesData = [
  {
    'id': 1,
    'name': 'ТехноПром',
    'category': 'manufacturing',
    'description': 'Производство промышленного оборудования',
    'rating': 4.8,
    'reviewsCount': 127,
    'verified': true,
    'inn': '7725123456',
    'region': 'Москва',
    'yearFounded': 2015,
    'employees': '100-500',
    'tags': ['Быстрая доставка', 'Гарантия качества'],
    'logo': '🏭',
    'phone': '+7 (495) 123-45-67',
    'email': 'info@technoprom.ru',
    'website': 'technoprom.ru',
    'completedDeals': 342,
    'responseTime': '2 часа',
    'services': ['Производство на заказ', 'Консультации', 'Монтаж'],
    'reviews': [
      {'id': 1, 'author': 'ООО "СтройКом"', 'rating': 5, 'text': 'Отличное качество продукции, всегда в срок', 'date': '2024-11-15'},
      {'id': 2, 'author': 'ЗАО "МегаСтрой"', 'rating': 4, 'text': 'Хороший сервис, но цены выше рынка', 'date': '2024-10-22'}
    ]
  },
  {
    'id': 2,
    'name': 'ЛогистикПро',
    'category': 'logistics',
    'description': 'Грузоперевозки по России и СНГ',
    'rating': 4.6,
    'reviewsCount': 89,
    'verified': true,
    'inn': '7726234567',
    'region': 'Санкт-Петербург',
    'yearFounded': 2018,
    'employees': '50-100',
    'tags': ['Страхование груза', 'GPS-трекинг'],
    'logo': '🚛',
    'phone': '+7 (812) 234-56-78',
    'email': 'cargo@logisticpro.ru',
    'website': 'logisticpro.ru',
    'completedDeals': 567,
    'responseTime': '30 минут',
    'services': ['FTL перевозки', 'LTL перевозки', 'Таможенное оформление'],
    'reviews': [
      {'id': 1, 'author': 'ИП Петров', 'rating': 5, 'text': 'Всегда довозят в срок, груз в сохранности', 'date': '2024-11-20'},
      {'id': 2, 'author': 'ООО "ТоргСеть"', 'rating': 4, 'text': 'Хорошая компания, рекомендую', 'date': '2024-11-10'}
    ]
  },
  {
    'id': 3,
    'name': 'ДигиталСофт',
    'category': 'it',
    'description': 'Разработка корпоративного ПО',
    'rating': 4.9,
    'reviewsCount': 156,
    'verified': true,
    'inn': '7727345678',
    'region': 'Москва',
    'yearFounded': 2012,
    'employees': '10-50',
    'tags': ['Agile', 'Поддержка 24/7'],
    'logo': '💻',
    'phone': '+7 (495) 345-67-89',
    'email': 'hello@digitalsoft.ru',
    'website': 'digitalsoft.ru',
    'completedDeals': 234,
    'responseTime': '1 час',
    'services': ['Web-разработка', 'Мобильные приложения', 'Интеграции'],
    'reviews': [
      {'id': 1, 'author': 'АО "ФинТех"', 'rating': 5, 'text': 'Профессиональная команда, сделали отличный продукт', 'date': '2024-11-18'}
    ]
  },
  {
    'id': 4,
    'name': 'СтройМатериал',
    'category': 'construction',
    'description': 'Поставка строительных материалов',
    'rating': 4.5,
    'reviewsCount': 203,
    'verified': false,
    'inn': '7728456789',
    'region': 'Екатеринбург',
    'yearFounded': 2010,
    'employees': '100-500',
    'tags': ['Оптовые цены', 'Доставка'],
    'logo': '🏗️',
    'phone': '+7 (343) 456-78-90',
    'email': 'sales@stroymaterial.ru',
    'website': 'stroymaterial.ru',
    'completedDeals': 891,
    'responseTime': '3 часа',
    'services': ['Оптовые поставки', 'Розница', 'Доставка на объект'],
    'reviews': [
      {'id': 1, 'author': 'ООО "СтройГрад"', 'rating': 4, 'text': 'Большой ассортимент, приемлемые цены', 'date': '2024-11-12'}
    ]
  },
  {
    'id': 5,
    'name': 'КонсалтПлюс',
    'category': 'consulting',
    'description': 'Юридические и бухгалтерские услуги',
    'rating': 4.7,
    'reviewsCount': 67,
    'verified': true,
    'inn': '7729567890',
    'region': 'Москва',
    'yearFounded': 2008,
    'employees': '10-50',
    'tags': ['Аудит', 'Налоговое планирование'],
    'logo': '⚖️',
    'phone': '+7 (495) 567-89-01',
    'email': 'info@consultplus.ru',
    'website': 'consultplus.ru',
    'completedDeals': 445,
    'responseTime': '1 час',
    'services': ['Бухгалтерский учет', 'Юридическое сопровождение', 'Аудит'],
    'reviews': [
      {'id': 1, 'author': 'ИП Иванова', 'rating': 5, 'text': 'Помогли оптимизировать налоги, спасибо!', 'date': '2024-11-05'}
    ]
  },
  {
    'id': 6,
    'name': 'ЭкоФерма',
    'category': 'manufacturing',
    'description': 'Производство органических продуктов питания',
    'rating': 4.9,
    'reviewsCount': 95,
    'verified': true,
    'inn': '7730678901',
    'region': 'Краснодар',
    'yearFounded': 2019,
    'employees': '10-50',
    'tags': ['Органика', 'Эко-продукция'],
    'logo': '🌱',
    'phone': '+7 (861) 234-56-78',
    'email': 'info@ecofarm.ru',
    'website': 'ecofarm.ru',
    'completedDeals': 120,
    'responseTime': '4 часа',
    'services': ['Поставка овощей', 'Фрукты оптом', 'Молочная продукция'],
    'reviews': [
      {'id': 1, 'author': 'ООО "Здоровое Питание"', 'rating': 5, 'text': 'Всегда свежие продукты, очень довольны', 'date': '2024-11-25'}
    ]
  },
  {
    'id': 7,
    'name': 'ГлобалТранс',
    'category': 'logistics',
    'description': 'Международные грузоперевозки',
    'rating': 4.7,
    'reviewsCount': 112,
    'verified': true,
    'inn': '7731789012',
    'region': 'Владивосток',
    'yearFounded': 2010,
    'employees': '50-100',
    'tags': ['Международные перевозки', 'Мультимодальные'],
    'logo': '🚢',
    'phone': '+7 (423) 345-67-89',
    'email': 'cargo@globaltrans.ru',
    'website': 'globaltrans.ru',
    'completedDeals': 780,
    'responseTime': '6 часов',
    'services': ['Морские перевозки', 'Авиаперевозки', 'Ж/д перевозки'],
    'reviews': [
      {'id': 1, 'author': 'ЗАО "ВостокТорг"', 'rating': 5, 'text': 'Надежный партнер для международных поставок', 'date': '2024-11-20'}
    ]
  },
  {
    'id': 8,
    'name': 'КиберЗащита',
    'category': 'it',
    'description': 'Услуги по кибербезопасности',
    'rating': 4.9,
    'reviewsCount': 88,
    'verified': true,
    'inn': '7732890123',
    'region': 'Новосибирск',
    'yearFounded': 2017,
    'employees': '10-50',
    'tags': ['Аудит безопасности', 'Защита данных'],
    'logo': '🔒',
    'phone': '+7 (383) 456-78-90',
    'email': 'info@cyberprotect.ru',
    'website': 'cyberprotect.ru',
    'completedDeals': 180,
    'responseTime': '1 час',
    'services': ['Пентесты', 'Аудит ИБ', 'Защита от DDoS'],
    'reviews': [
      {'id': 1, 'author': 'Банк "Надежный"', 'rating': 5, 'text': 'Повысили уровень нашей кибербезопасности', 'date': '2024-11-15'}
    ]
  },
  {
    'id': 9,
    'name': 'АрхиСтрой',
    'category': 'construction',
    'description': 'Проектирование и строительство зданий',
    'rating': 4.6,
    'reviewsCount': 150,
    'verified': false,
    'inn': '7733901234',
    'region': 'Москва',
    'yearFounded': 2005,
    'employees': '100-500',
    'tags': ['Архитектура', 'Генподряд'],
    'logo': '🏛️',
    'phone': '+7 (495) 678-90-12',
    'email': 'project@archistroy.ru',
    'website': 'archistroy.ru',
    'completedDeals': 600,
    'responseTime': '5 часов',
    'services': ['Проектирование', 'Строительство под ключ', 'Ремонт'],
    'reviews': [
      {'id': 1, 'author': 'Частный заказчик', 'rating': 4, 'text': 'Сделали все качественно, но немного задержали сроки', 'date': '2024-11-10'}
    ]
  },
  {
    'id': 10,
    'name': 'БизнесРост',
    'category': 'consulting',
    'description': 'Консалтинг по развитию бизнеса',
    'rating': 4.8,
    'reviewsCount': 75,
    'verified': true,
    'inn': '7734012345',
    'region': 'Санкт-Петербург',
    'yearFounded': 2016,
    'employees': '10-50',
    'tags': ['Стратегия', 'Маркетинг'],
    'logo': '📈',
    'phone': '+7 (812) 789-01-23',
    'email': 'contact@biznesrost.ru',
    'website': 'biznesrost.ru',
    'completedDeals': 210,
    'responseTime': '2 часа',
    'services': ['Разработка стратегии', 'Маркетинговые исследования', 'Оптимизация процессов'],
    'reviews': [
      {'id': 1, 'author': 'ООО "СтартАп"', 'rating': 5, 'text': 'Помогли выйти на новый уровень, очень ценные советы', 'date': '2024-11-22'}
    ]
  }
];

final List<Company> mockCompanies = mockCompaniesData.map((json) => Company.fromJson(json)).toList();

final List<Map<String, String>> categories = [
  {'id': 'all', 'nameKey': 'allCategories', 'icon': '📋'},
  {'id': 'manufacturing', 'nameKey': 'manufacturing', 'icon': '🏭'},
  {'id': 'logistics', 'nameKey': 'logistics', 'icon': '🚛'},
  {'id': 'it', 'nameKey': 'itServices', 'icon': '💻'},
  {'id': 'construction', 'nameKey': 'construction', 'icon': '🏗️'},
  {'id': 'consulting', 'nameKey': 'consulting', 'icon': '⚖️'}
];

final List<String> regions = ['all', 'Москва', 'Санкт-Петербург', 'Екатеринбург', 'Новосибирск', 'Краснодар', 'Владивосток'];
