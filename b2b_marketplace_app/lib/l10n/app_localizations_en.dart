// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'B2B Marketplace';

  @override
  String get homePageTitle => 'B2B Marketplace';

  @override
  String get recommendedPartners => 'Recommended Partners';

  @override
  String get companiesFound => 'Companies Found';

  @override
  String get sortByRating => 'By Rating';

  @override
  String get sortByReviews => 'By Reviews';

  @override
  String get sortByDeals => 'By Deals';

  @override
  String get noCompaniesFound => 'No Companies Found';

  @override
  String get tryChangingSearchParams => 'Try changing search parameters';

  @override
  String get investors => 'Investors';

  @override
  String get aboutUs => 'About Us';

  @override
  String get opportunities => 'Opportunities';

  @override
  String get events => 'Events';

  @override
  String get pricing => 'Pricing';

  @override
  String get blog => 'Blog';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get blogPost => 'Blog Post';

  @override
  String get searchCompaniesServices => 'Search companies, services...';

  @override
  String get filters => 'Filters';

  @override
  String get category => 'Category';

  @override
  String get region => 'Region';

  @override
  String get companySize => 'Company Size';

  @override
  String get any => 'Any';

  @override
  String employees(Object count) {
    return '$count employees';
  }

  @override
  String get minRating => 'Minimum Rating';

  @override
  String get verifiedOnly => 'Verified Only';

  @override
  String get allCategories => 'All Categories';

  @override
  String get allRegions => 'All Regions';

  @override
  String get manufacturing => 'Manufacturing';

  @override
  String get logistics => 'Logistics';

  @override
  String get itServices => 'IT Services';

  @override
  String get construction => 'Construction';

  @override
  String get consulting => 'Consulting';

  @override
  String translateCategory(String categoryKey) {
    String _temp0 = intl.Intl.selectLogic(categoryKey, {
      'allCategories': 'All Categories',
      'manufacturing': 'Manufacturing',
      'logistics': 'Logistics',
      'itServices': 'IT Services',
      'construction': 'Construction',
      'consulting': 'Consulting',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get investmentAmount => 'Investment Amount';

  @override
  String get interests => 'Interests';

  @override
  String get companyInfo => 'Company Information';

  @override
  String get inn => 'INN';

  @override
  String get yearFounded => 'Year Founded';

  @override
  String get services => 'Services';

  @override
  String get contacts => 'Contacts';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get latestReviews => 'Latest Reviews';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get rating => 'Rating';

  @override
  String get completedDeals => 'Completed Deals';

  @override
  String get responseTime => 'Response Time';

  @override
  String get status => 'Status';

  @override
  String get verified => 'Verified';

  @override
  String get deals => 'Deals';

  @override
  String get response => 'Response';

  @override
  String swipedRightLiked(Object companyName) {
    return '$companyName swiped right (liked)';
  }

  @override
  String swipedLeftDisliked(Object companyName) {
    return '$companyName swiped left (disliked)';
  }

  @override
  String get reviews => 'reviews';

  @override
  String employeesText(Object employeesCount) {
    return '$employeesCount employees';
  }

  @override
  String tappedOn(Object itemName) {
    return '$itemName tapped';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get dontHaveAccountRegister => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get noInvestorsFound => 'No Investors Found';

  @override
  String get tryChangingSearchParamsInvestors =>
      'Try changing search parameters for investors';
}
