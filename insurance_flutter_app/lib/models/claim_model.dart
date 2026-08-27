class ClaimModel {
  final String id;
  final String? claimNumber;
  final String policyNumber;
  final double claimAmount;
  final String status;
  final double fraudScore;
  final String? riskLevel;
  final String? incidentDate;
  final String? createdAt;
  final String? description;
  final String? claimType;
  final String? policyHolderName;
  final String? assignedInvestigatorId;
  final String? assignedInvestigatorName;
  final String? investigatorNotes;
  final String? decisionNotes;

  ClaimModel({
    required this.id,
    this.claimNumber,
    required this.policyNumber,
    required this.claimAmount,
    required this.status,
    required this.fraudScore,
    this.riskLevel,
    this.incidentDate,
    this.createdAt,
    this.description,
    this.claimType,
    this.policyHolderName,
    this.assignedInvestigatorId,
    this.assignedInvestigatorName,
    this.investigatorNotes,
    this.decisionNotes,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['id']?.toString() ?? '',
      claimNumber: json['claimNumber'] ?? json['id']?.toString(),
      policyNumber: json['policyNumber'] ?? 'POL-N/A',
      claimAmount: (json['claimAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['claimStatus'] ?? json['status'] ?? 'PENDING',
      fraudScore: (json['fraudScore'] as num?)?.toDouble() ?? (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['riskLevel'] ?? json['fraudRiskLevel'] ?? 'LOW',
      incidentDate: json['incidentDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
      description: json['description'],
      claimType: json['claimType'] ?? json['category'] ?? 'HEALTH',
      policyHolderName: json['policyHolderName'] ?? json['user']?['fullName'],
      assignedInvestigatorId: json['assignedInvestigatorId']?.toString(),
      assignedInvestigatorName: json['assignedInvestigatorName'] ?? json['investigator']?['fullName'],
      investigatorNotes: json['investigatorNotes'] ?? json['reviewNotes'],
      decisionNotes: json['decisionNotes'] ?? json['adminNotes'],
    );
  }
}
