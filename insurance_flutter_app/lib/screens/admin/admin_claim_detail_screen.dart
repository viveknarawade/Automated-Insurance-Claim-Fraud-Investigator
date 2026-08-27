import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../models/document_model.dart';
import '../../models/investigator_workload_model.dart';
import '../../services/admin_service.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';

class AdminClaimDetailScreen extends StatefulWidget {
  final String claimId;
  const AdminClaimDetailScreen({super.key, required this.claimId});

  @override
  State<AdminClaimDetailScreen> createState() => _AdminClaimDetailScreenState();
}

class _AdminClaimDetailScreenState extends State<AdminClaimDetailScreen> {
  final AdminService _adminService = AdminService();
  final DocumentService _documentService = DocumentService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  ClaimModel? _claim;
  List<DocumentModel> _documents = [];
  List<InvestigatorWorkloadModel> _investigators = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  final _decisionNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _decisionNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final claim = await _adminService.getAdminClaimById(widget.claimId);
      final docs = await _documentService.getClaimDocuments(widget.claimId);
      final investigators = await _adminService.getInvestigatorsWorkload();
      setState(() {
        _claim = claim;
        _documents = docs;
        _investigators = investigators;
        _decisionNotesController.text = claim.decisionNotes ?? '';
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAssignInvestigatorDialog() async {
    if (_investigators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No investigators available.')));
      return;
    }

    String? selectedId = _investigators.first.investigatorId;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Investigator'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => DropdownButtonFormField<String>(
            initialValue: selectedId,
            decoration: const InputDecoration(labelText: 'Select Investigator'),
            items: _investigators.map((inv) {
              return DropdownMenuItem(
                value: inv.investigatorId,
                child: Text('${inv.investigatorName} (${inv.activeAssignedClaims} active)'),
              );
            }).toList(),
            onChanged: (val) {
              setDialogState(() => selectedId = val);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Assign')),
        ],
      ),
    );

    if (confirmed == true && selectedId != null) {
      setState(() => _isProcessing = true);
      try {
        await _adminService.assignInvestigator(widget.claimId, selectedId!);
        await _fetchDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investigator assigned!'), backgroundColor: AppTheme.successGreen),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment failed: $e'), backgroundColor: AppTheme.dangerRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDecision(bool isApprove) async {
    if (_decisionNotesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter administrative decision notes.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      if (isApprove) {
        await _adminService.approveClaim(widget.claimId, _decisionNotesController.text.trim());
      } else {
        await _adminService.rejectClaim(widget.claimId, _decisionNotesController.text.trim());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApprove ? 'Claim Approved successfully!' : 'Claim Rejected.'),
          backgroundColor: isApprove ? AppTheme.successGreen : AppTheme.dangerRed,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Decision submission failed: $e'), backgroundColor: AppTheme.dangerRed),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Management')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Management')),
        body: const Center(child: Text('Claim not found.')),
      );
    }

    final statusColor = AppTheme.getStatusColor(_claim!.status);
    final riskColor = AppTheme.getRiskColor(_claim!.fraudScore);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Claim #${_claim!.claimNumber ?? _claim!.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Status', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          _claim!.status.replaceAll('_', ' '),
                          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Risk Assessment', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: riskColor.withAlpha(40), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'Score: ${_claim!.fraudScore.toInt()}%',
                            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Policy & Claimant Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Claim Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 20),
                    _buildRow('Claimant', _claim!.policyHolderName ?? 'N/A'),
                    _buildRow('Policy Number', _claim!.policyNumber),
                    _buildRow('Claim Amount', currencyFormat.format(_claim!.claimAmount)),
                    _buildRow('Category', _claim!.claimType ?? 'General'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assigned Investigator', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        TextButton.icon(
                          onPressed: _isProcessing ? null : _showAssignInvestigatorDialog,
                          icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                          label: Text(_claim!.assignedInvestigatorName ?? 'Assign Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Investigator Review Notes if submitted
            if (_claim!.investigatorNotes != null && _claim!.investigatorNotes!.isNotEmpty) ...[
              Card(
                color: AppTheme.warningAmber.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.search_outlined, color: AppTheme.warningAmber),
                          SizedBox(width: 8),
                          Text('Investigator Findings', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_claim!.investigatorNotes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Evidence Files
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evidence Files (${_documents.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 20),
                    if (_documents.isEmpty)
                      const Text('No documents attached.', style: TextStyle(color: Colors.grey))
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

            // Final Decision Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Executive Adjudication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _decisionNotesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Decision Rationale / Admin Notes',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                            onPressed: _isProcessing ? null : () => _handleDecision(true),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('APPROVE'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                            onPressed: _isProcessing ? null : () => _handleDecision(false),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('REJECT'),
                          ),
                        ),
                      ],
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
