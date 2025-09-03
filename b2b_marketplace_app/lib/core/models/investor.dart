class Investor {
  final String id;
  final String name;
  final String description;
  final double investmentAmount;
  final List<String> interests;
  final String avatar; // New field

  Investor({
    required this.id,
    required this.name,
    required this.description,
    required this.investmentAmount,
    required this.interests,
    required this.avatar, // New required parameter
  });
}