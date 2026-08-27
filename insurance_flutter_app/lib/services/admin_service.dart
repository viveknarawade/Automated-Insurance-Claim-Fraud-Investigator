import '../core/network/api_client.dart';
import '../models/admin_dashboard_model.dart';
import '../models/claim_model.dart';
import '../models/investigator_workload_model.dart';

class AdminService {
  final ApiClient _api = ApiClient();

  Future<AdminDashboardModel> getDashboardStats() async {
    final response = await _api.get('/admin/dashboard');
    return AdminDashboardModel.fromJson(response ?? {});
  }

  Future<List<ClaimModel>> getAllClaims({
    int pageNumber = 0,
    int pageSize = 20,
    String sortBy = "CREATED_AT",
    String sortDir = "DESC",
  }) async {
    final response = await _api.get(
      '/admin/claims',
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

  Future<List<InvestigatorWorkloadModel>> getInvestigatorsWorkload() async {
    final response = await _api.get('/admin/investigators/workload');
    if (response is List) {
      return response.map((item) => InvestigatorWorkloadModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<ClaimModel> assignInvestigator(String claimId, String investigatorId) async {
    final response = await _api.patch(
      '/admin/claims/$claimId/assign-investigator',
      body: {'investigatorId': investigatorId},
    );
    return ClaimModel.fromJson(response);
  }

  Future<ClaimModel> approveClaim(String claimId, String decisionNotes) async {
    final response = await _api.patch(
      '/admin/claims/$claimId/approve',
      body: {'decisionNotes': decisionNotes},
    );
    return ClaimModel.fromJson(response);
  }

  Future<ClaimModel> rejectClaim(String claimId, String decisionNotes) async {
    final response = await _api.patch(
      '/admin/claims/$claimId/reject',
      body: {'decisionNotes': decisionNotes},
    );
    return ClaimModel.fromJson(response);
  }
}
