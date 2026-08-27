class ClaimModel {
  final String id;
  final String? claimNumber;
  final String policyNumber;
  final double claimAmount;
  final String status;
  final double fraudScore;
  final String? fraudStatus;
  final String? riskLevel;
  final String? incidentDate;
  final String? createdAt;
  final String? updatedAt;
  final String? description;
  final String? claimType;
  final String? incidentAddress;
  final String? incidentCity;
  final String? incidentState;
  final String? policyHolderName;
  final String? assignedInvestigatorId;
  final String? assignedInvestigatorName;
  final String? reviewNotes;
  final String? decisionNotes;

  ClaimModel({
    required this.id,
    this.claimNumber,
    required this.policyNumber,
    required this.claimAmount,
    required this.status,
    required this.fraudScore,
    this.fraudStatus,
    this.riskLevel,
    this.incidentDate,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.claimType,
    this.incidentAddress,
    this.incidentCity,
    this.incidentState,
    this.policyHolderName,
    this.assignedInvestigatorId,
    this.assignedInvestigatorName,
    this.reviewNotes,
    this.decisionNotes,
  });

  /// Full incident location string
  String get incidentLocation {
    final parts = [incidentAddress, incidentCity, incidentState]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Location not provided' : parts.join(', ');
  }

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: (json['claimId'] ?? json['id'])?.toString() ?? '',
      claimNumber: json['claimNumber'] ?? json['claimId']?.toString(),
      policyNumber: json['policyNumber'] ?? 'POL-N/A',
      claimAmount: (json['claimAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['claimStatus'] ?? json['status'] ?? 'PENDING',
      fraudScore: (json['fraudScore'] as num?)?.toDouble() ?? 0.0,
      fraudStatus: json['fraudStatus'],
      riskLevel: json['riskLevel'] ?? json['fraudRiskLevel'] ?? 'LOW',
      incidentDate: json['incidentDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      description: json['description'],
      claimType: json['claimType'] ?? json['category'],
      incidentAddress: json['incidentAddress'],
      incidentCity: json['incidentCity'],
      incidentState: json['incidentState'],
      policyHolderName: json['policyHolderName'] ?? json['user']?['fullName'],
      assignedInvestigatorId: json['assignedInvestigatorId']?.toString(),
      assignedInvestigatorName: json['assignedInvestigatorName'] ??
          json['investigator']?['fullName'] ??
          json['assignedInvestigator']?['fullName'],
      reviewNotes: json['reviewNotes'] ?? json['investigatorNotes'],
      decisionNotes: json['decisionNotes'] ?? json['adminNotes'],
    );
  }
}
