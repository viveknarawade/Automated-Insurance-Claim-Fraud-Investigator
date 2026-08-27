import '../core/network/api_client.dart';
import '../models/claim_model.dart';

class InvestigatorService {
  final ApiClient _api = ApiClient();

  Future<List<ClaimModel>> getAssignedClaims({
    int pageNumber = 0,
    int pageSize = 20,
    String sortBy = "CREATED_AT",
    String sortDir = "DESC",
  }) async {
    final response = await _api.get(
      '/investigator/claims',
      queryParams: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'sortBy': sortBy,
        'sortDir': sortDir,
      },
    );

    if (response != null) {
      final List content = response['content'] ?? (response is List ? response : []);
      return content.map((item) => ClaimModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<ClaimModel> getClaimDetails(String claimId) async {
    final response = await _api.get('/investigator/claims/$claimId');
    return ClaimModel.fromJson(response);
  }

  Future<ClaimModel> reviewClaim({
    required String claimId,
    required double fraudScore,
    required String recommendation,
    required String reviewNotes,
  }) async {
    final response = await _api.patch(
      '/investigator/claims/$claimId/review',
      body: {
        'fraudScore': fraudScore,
        'recommendation': recommendation,
        'reviewNotes': reviewNotes,
      },
    );
    return ClaimModel.fromJson(response);
  }
}
