class AdminDashboardModel {
  final int totalClaims;
  final int pendingClaims;
  final int approvedClaims;
  final int rejectedClaims;
  final int underInvestigationClaims;
  final double totalClaimedAmount;
  final int highRiskCount;

  AdminDashboardModel({
    required this.totalClaims,
    required this.pendingClaims,
    required this.approvedClaims,
    required this.rejectedClaims,
    required this.underInvestigationClaims,
    required this.totalClaimedAmount,
    required this.highRiskCount,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalClaims: json['totalClaims'] ?? 0,
      pendingClaims: json['pendingClaims'] ?? 0,
      approvedClaims: json['approvedClaims'] ?? 0,
      rejectedClaims: json['rejectedClaims'] ?? 0,
      underInvestigationClaims: json['underInvestigationClaims'] ?? 0,
      totalClaimedAmount: (json['totalClaimedAmount'] as num?)?.toDouble() ?? 0.0,
      highRiskCount: json['highRiskCount'] ?? json['flaggedClaimsCount'] ?? 0,
    );
  }
}
