import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../models/document_model.dart';
import '../../services/claim_service.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';

class ClaimDetailScreen extends StatefulWidget {
  final String claimId;
  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  State<ClaimDetailScreen> createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> {
  final ClaimService _claimService = ClaimService();
  final DocumentService _documentService = DocumentService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  ClaimModel? _claim;
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  bool _isUploadingDoc = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final claim = await _claimService.getClaimById(widget.claimId);
      final docs = await _documentService.getClaimDocuments(widget.claimId);
      setState(() {
        _claim = claim;
        _documents = docs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadNewDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result == null || result.files.single.path == null) return;

    String selectedDocType = 'RECEIPT';

    if (!mounted) return;
    final bool? shouldUpload = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${result.files.single.name}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedDocType,
              decoration: const InputDecoration(labelText: 'Document Type'),
              items: const [
                DropdownMenuItem(value: 'RECEIPT', child: Text('Receipt / Invoice')),
                DropdownMenuItem(value: 'MEDICAL_REPORT', child: Text('Medical Report')),
                DropdownMenuItem(value: 'POLICE_REPORT', child: Text('Police Report')),
                DropdownMenuItem(value: 'PHOTO_PROOF', child: Text('Photo Proof')),
              ],
              onChanged: (val) {
                if (val != null) selectedDocType = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Upload')),
        ],
      ),
    );

    if (shouldUpload == true) {
      setState(() => _isUploadingDoc = true);
      try {
        await _documentService.uploadDocument(
          claimId: widget.claimId,
          filePath: result.files.single.path!,
          documentType: selectedDocType,
        );
        await _fetchDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully!'), backgroundColor: AppTheme.successGreen),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.toString()}'), backgroundColor: AppTheme.dangerRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploadingDoc = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Details')),
        body: const Center(child: Text('Claim not found.')),
      );
    }

    final statusColor = AppTheme.getStatusColor(_claim!.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Claim #${_claim!.claimNumber ?? _claim!.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Banner
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Claim Status', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _claim!.status.replaceAll('_', ' '),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(_claim!.claimAmount),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 6),
                    Text('Category: ${_claim!.claimType ?? 'General'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Policy & Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Policy Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 24),
                    _buildDetailRow('Policy Number', _claim!.policyNumber),
                    if (_claim!.incidentDate != null) _buildDetailRow('Incident Date', _claim!.incidentDate!),
                    if (_claim!.createdAt != null) _buildDetailRow('Submitted Date', _claim!.createdAt!.split('T')[0]),
                    const SizedBox(height: 12),
                    const Text('Description:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_claim!.description ?? 'No description provided.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Admin/Decision Notes if available
            if (_claim!.decisionNotes != null && _claim!.decisionNotes!.isNotEmpty) ...[
              Card(
                color: AppTheme.primaryBlue.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notes, color: AppTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text('Decision Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_claim!.decisionNotes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Documents Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Attachments (${_documents.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: _isUploadingDoc
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryBlue),
                          onPressed: _isUploadingDoc ? null : _uploadNewDocument,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (_documents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No evidence documents attached yet.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _documents.length,
                        itemBuilder: (context, idx) {
                          final doc = _documents[idx];
                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file_outlined, color: AppTheme.accentCyan),
                            title: Text(doc.fileName),
                            subtitle: Text('Type: ${doc.documentType}'),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
