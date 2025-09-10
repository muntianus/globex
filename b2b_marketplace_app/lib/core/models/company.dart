class Company {
  final int id;
  final String name;
  final String category;
  final String description;
  final double rating;
  final int reviewsCount;
  final bool verified;
  final String inn;
  final String region;
  final int yearFounded;
  final String employees;
  final List<String> tags;
  final String logo;
  final String phone;
  final String email;
  final String website;
  final int completedDeals;
  final String responseTime;
  final List<String> services;
  final List<Review> reviews;

  Company({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.reviewsCount,
    required this.verified,
    required this.inn,
    required this.region,
    required this.yearFounded,
    required this.employees,
    required this.tags,
    required this.logo,
    required this.phone,
    required this.email,
    required this.website,
    required this.completedDeals,
    required this.responseTime,
    required this.services,
    required this.reviews,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category_id'] ?? json['category'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? json['reviewsCount'] ?? 0,
      verified: json['verified'] ?? false,
      inn: json['inn'] ?? '',
      region: json['region'] ?? '',
      yearFounded: json['year_founded'] ?? json['yearFounded'] ?? 2000,
      employees: json['employees'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      logo: json['logo'] ?? '🏢',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      completedDeals: json['completed_deals'] ?? json['completedDeals'] ?? 0,
      responseTime: json['response_time'] ?? json['responseTime'] ?? '',
      services: json['services'] != null ? List<String>.from(json['services']) : [],
      reviews: json['reviews'] != null 
          ? (json['reviews'] as List).map((reviewJson) => Review.fromJson(reviewJson)).toList()
          : [],
    );
  }
}

class Review {
  final int id;
  final String author;
  final int rating;
  final String text;
  final String date;

  Review({
    required this.id,
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      author: json['author'],
      rating: json['rating'],
      text: json['text'],
      date: json['date'],
    );
  }
}
