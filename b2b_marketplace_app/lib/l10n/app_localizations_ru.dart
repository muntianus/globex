// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'B2B Маркетплейс';

  @override
  String get homePageTitle => 'B2B Маркетплейс';

  @override
  String get recommendedPartners => 'Рекомендуемые партнёры';

  @override
  String get companiesFound => 'Найдено компаний';

  @override
  String get sortByRating => 'По рейтингу';

  @override
  String get sortByReviews => 'По отзывам';

  @override
  String get sortByDeals => 'По сделкам';

  @override
  String get noCompaniesFound => 'Компании не найдены';

  @override
  String get tryChangingSearchParams => 'Попробуйте изменить параметры поиска';

  @override
  String get investors => 'Инвесторы';

  @override
  String get aboutUs => 'О нас';

  @override
  String get opportunities => 'Возможности';

  @override
  String get events => 'События';

  @override
  String get pricing => 'Цены';

  @override
  String get blog => 'Блог';

  @override
  String get contactUs => 'Контакты';

  @override
  String get blogPost => 'Запись в блоге';

  @override
  String get searchCompaniesServices => 'Поиск компаний, услуг...';

  @override
  String get filters => 'Фильтры';

  @override
  String get category => 'Категория';

  @override
  String get region => 'Регион';

  @override
  String get companySize => 'Размер компании';

  @override
  String get any => 'Любой';

  @override
  String employees(Object count) {
    return '$count сотрудников';
  }

  @override
  String get minRating => 'Минимальный рейтинг';

  @override
  String get verifiedOnly => 'Только верифицированные';

  @override
  String get allCategories => 'Все категории';

  @override
  String get allRegions => 'Все регионы';

  @override
  String get manufacturing => 'Производство';

  @override
  String get logistics => 'Логистика';

  @override
  String get itServices => 'IT услуги';

  @override
  String get construction => 'Строительство';

  @override
  String get consulting => 'Консалтинг';

  @override
  String translateCategory(String categoryKey) {
    String _temp0 = intl.Intl.selectLogic(categoryKey, {
      'allCategories': 'Все категории',
      'manufacturing': 'Производство',
      'logistics': 'Логистика',
      'itServices': 'IT услуги',
      'construction': 'Строительство',
      'consulting': 'Консалтинг',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String get investmentAmount => 'Сумма инвестиций';

  @override
  String get interests => 'Сферы интересов';

  @override
  String get companyInfo => 'Информация о компании';

  @override
  String get inn => 'ИНН';

  @override
  String get yearFounded => 'Год основания';

  @override
  String get services => 'Услуги';

  @override
  String get contacts => 'Контакты';

  @override
  String get phone => 'Телефон';

  @override
  String get email => 'Электронная почта';

  @override
  String get website => 'Веб-сайт';

  @override
  String get latestReviews => 'Последние отзывы';

  @override
  String get noReviewsYet => 'Отзывов пока нет.';

  @override
  String get rating => 'Рейтинг';

  @override
  String get completedDeals => 'Завершенных сделок';

  @override
  String get responseTime => 'Среднее время ответа';

  @override
  String get status => 'Статус';

  @override
  String get verified => 'Верифицирован';

  @override
  String get deals => 'Сделок';

  @override
  String get response => 'Ответ';

  @override
  String swipedRightLiked(Object companyName) {
    return '$companyName свайпнули вправо (понравилось)';
  }

  @override
  String swipedLeftDisliked(Object companyName) {
    return '$companyName свайпнули влево (не понравилось)';
  }

  @override
  String get reviews => 'отзывов';

  @override
  String employeesText(Object employeesCount) {
    return '$employeesCount сотрудников';
  }

  @override
  String tappedOn(Object itemName) {
    return '$itemName нажато';
  }

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get pleaseEnterUsername => 'Пожалуйста, введите имя пользователя';

  @override
  String get pleaseEnterPassword => 'Пожалуйста, введите пароль';

  @override
  String get pleaseEnterEmail => 'Пожалуйста, введите адрес электронной почты';

  @override
  String get pleaseEnterFullName => 'Пожалуйста, введите полное имя';

  @override
  String get loginFailed => 'Ошибка входа. Проверьте свои учетные данные.';

  @override
  String get registrationFailed =>
      'Ошибка регистрации. Пожалуйста, попробуйте еще раз.';

  @override
  String get dontHaveAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get alreadyHaveAccountLogin => 'Уже есть аккаунт? Войти';

  @override
  String get noInvestorsFound => 'Инвесторы не найдены';

  @override
  String get tryChangingSearchParamsInvestors =>
      'Попробуйте изменить параметры поиска инвесторов';
}
