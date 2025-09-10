class InvestmentProposal {
  final int id;
  final int companyId;
  final String title;
  final String description;
  final double investmentAmount;
  final double? equityPercentage;
  final double? expectedReturn;
  final String investmentType;
  final String businessStage;
  final String industry;
  final String location;
  final double? minInvestment;
  final double? maxInvestment;
  final DateTime? fundingDeadline;
  final String? useOfFunds;
  final String? financialHighlights;
  final String? teamInfo;
  final String? marketOpportunity;
  final String? competitiveAdvantages;
  final String? risks;
  final String status;
  final int viewsCount;
  final int interestedInvestors;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentProposal({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.investmentAmount,
    this.equityPercentage,
    this.expectedReturn,
    required this.investmentType,
    required this.businessStage,
    required this.industry,
    required this.location,
    this.minInvestment,
    this.maxInvestment,
    this.fundingDeadline,
    this.useOfFunds,
    this.financialHighlights,
    this.teamInfo,
    this.marketOpportunity,
    this.competitiveAdvantages,
    this.risks,
    this.status = 'active',
    this.viewsCount = 0,
    this.interestedInvestors = 0,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentProposal.fromJson(Map<String, dynamic> json) {
    return InvestmentProposal(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      investmentAmount: (json['investment_amount'] as num).toDouble(),
      equityPercentage: json['equity_percentage'] != null 
          ? (json['equity_percentage'] as num).toDouble() 
          : null,
      expectedReturn: json['expected_return'] != null 
          ? (json['expected_return'] as num).toDouble() 
          : null,
      investmentType: json['investment_type'] as String,
      businessStage: json['business_stage'] as String,
      industry: json['industry'] as String,
      location: json['location'] as String,
      minInvestment: json['min_investment'] != null 
          ? (json['min_investment'] as num).toDouble() 
          : null,
      maxInvestment: json['max_investment'] != null 
          ? (json['max_investment'] as num).toDouble() 
          : null,
      fundingDeadline: json['funding_deadline'] != null 
          ? DateTime.parse(json['funding_deadline'] as String)
          : null,
      useOfFunds: json['use_of_funds'] as String?,
      financialHighlights: json['financial_highlights'] as String?,
      teamInfo: json['team_info'] as String?,
      marketOpportunity: json['market_opportunity'] as String?,
      competitiveAdvantages: json['competitive_advantages'] as String?,
      risks: json['risks'] as String?,
      status: json['status'] as String? ?? 'active',
      viewsCount: json['views_count'] as int? ?? 0,
      interestedInvestors: json['interested_investors'] as int? ?? 0,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'investment_amount': investmentAmount,
      'equity_percentage': equityPercentage,
      'expected_return': expectedReturn,
      'investment_type': investmentType,
      'business_stage': businessStage,
      'industry': industry,
      'location': location,
      'min_investment': minInvestment,
      'max_investment': maxInvestment,
      'funding_deadline': fundingDeadline?.toIso8601String(),
      'use_of_funds': useOfFunds,
      'financial_highlights': financialHighlights,
      'team_info': teamInfo,
      'market_opportunity': marketOpportunity,
      'competitive_advantages': competitiveAdvantages,
      'risks': risks,
      'status': status,
      'views_count': viewsCount,
      'interested_investors': interestedInvestors,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}