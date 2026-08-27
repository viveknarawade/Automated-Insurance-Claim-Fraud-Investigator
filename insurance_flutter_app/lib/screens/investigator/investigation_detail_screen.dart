import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../models/document_model.dart';
import '../../services/document_service.dart';
import '../../services/investigator_service.dart';
import '../../theme/app_theme.dart';

class InvestigationDetailScreen extends StatefulWidget {
  final String claimId;
  const InvestigationDetailScreen({super.key, required this.claimId});

  @override
  State<InvestigationDetailScreen> createState() => _InvestigationDetailScreenState();
}

class _InvestigationDetailScreenState extends State<InvestigationDetailScreen> {
  final InvestigatorService _investigatorService = InvestigatorService();
  final DocumentService _documentService = DocumentService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  ClaimModel? _claim;
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  bool _isSubmittingReview = false;

  late double _fraudScoreSlider;
  String _selectedRecommendation = 'APPROVE_RECOMMENDED';
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final claim = await _investigatorService.getClaimDetails(widget.claimId);
      final docs = await _documentService.getClaimDocuments(widget.claimId);
      setState(() {
        _claim = claim;
        _documents = docs;
        _fraudScoreSlider = claim.fraudScore;
        _notesController.text = claim.investigatorNotes ?? '';
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter investigation review notes.')),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      await _investigatorService.reviewClaim(
        claimId: widget.claimId,
        fraudScore: _fraudScoreSlider,
        recommendation: _selectedRecommendation,
        reviewNotes: _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Investigation review submitted!'), backgroundColor: AppTheme.successGreen),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submission failed: ${e.toString()}'), backgroundColor: AppTheme.dangerRed),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case Investigation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case Investigation')),
        body: const Center(child: Text('Claim not found.')),
      );
    }

    final riskColor = AppTheme.getRiskColor(_fraudScoreSlider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Case #${_claim!.claimNumber ?? _claim!.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Risk & AI Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('AI Fraud Risk Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 110,
                          width: 110,
                          child: CircularProgressIndicator(
                            value: _fraudScoreSlider / 100.0,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[800],
                            color: riskColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_fraudScoreSlider.toInt()}%',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: riskColor),
                            ),
                            Text(
                              _fraudScoreSlider >= 70 ? 'HIGH RISK' : _fraudScoreSlider >= 40 ? 'MEDIUM' : 'LOW RISK',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Claimant & Policy Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Claimant & Policy Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 20),
                    _buildRow('Policy Holder', _claim!.policyHolderName ?? 'N/A'),
                    _buildRow('Policy Number', _claim!.policyNumber),
                    _buildRow('Claim Amount', currencyFormat.format(_claim!.claimAmount)),
                    _buildRow('Category', _claim!.claimType ?? 'General'),
                    if (_claim!.incidentDate != null) _buildRow('Incident Date', _claim!.incidentDate!),
                    const SizedBox(height: 12),
                    const Text('Incident Description:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_claim!.description ?? 'No description.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Evidence Documents
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evidence Files (${_documents.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 20),
                    if (_documents.isEmpty)
                      const Text('No uploaded evidence files found.', style: TextStyle(color: Colors.grey))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _documents.length,
                        itemBuilder: (context, idx) {
                          final doc = _documents[idx];
                          return ListTile(
                            leading: const Icon(Icons.file_present_outlined, color: AppTheme.accentCyan),
                            title: Text(doc.fileName),
                            subtitle: Text('Type: ${doc.documentType}'),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Investigator Decision Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submit Investigation Findings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text('Adjust Assessed Fraud Risk Score (${_fraudScoreSlider.toInt()}%)'),
                    Slider(
                      value: _fraudScoreSlider,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: riskColor,
                      label: '${_fraudScoreSlider.toInt()}%',
                      onChanged: (val) {
                        setState(() => _fraudScoreSlider = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedRecommendation,
                      decoration: const InputDecoration(labelText: 'Recommendation'),
                      items: const [
                        DropdownMenuItem(value: 'APPROVE_RECOMMENDED', child: Text('Recommend Approval')),
                        DropdownMenuItem(value: 'REJECT_RECOMMENDED', child: Text('Recommend Rejection')),
                        DropdownMenuItem(value: 'FLAG_SUSPICIOUS', child: Text('Flag as High Suspicion')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRecommendation = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Investigation Notes / Findings',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isSubmittingReview ? null : _submitReview,
                      child: _isSubmittingReview
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('SUBMIT REVIEW FINDINGS'),
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

  Widget _buildRow(String label, String value) {
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
