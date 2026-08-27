import '../core/network/api_client.dart';
import '../models/document_model.dart';

class DocumentService {
  final ApiClient _api = ApiClient();

  Future<List<DocumentModel>> getClaimDocuments(String claimId) async {
    final response = await _api.get('/claims/$claimId/documents');
    if (response is List) {
      return response.map((item) => DocumentModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<DocumentModel> uploadDocument({
    required String claimId,
    required String filePath,
    required String documentType,
  }) async {
    final response = await _api.uploadMultipart(
      '/claims/$claimId/documents',
      filePath: filePath,
      fileParamName: 'file',
      fields: {'documentType': documentType},
    );
    return DocumentModel.fromJson(response);
  }

  Future<void> deleteDocument(String documentId) async {
    await _api.delete('/documents/$documentId');
  }
}
