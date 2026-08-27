import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'admin_claim_detail_screen.dart';

class AdminClaimsScreen extends StatefulWidget {
  const AdminClaimsScreen({super.key});

  @override
  State<AdminClaimsScreen> createState() => _AdminClaimsScreenState();
}

class _AdminClaimsScreenState extends State<AdminClaimsScreen> {
  final AdminService _adminService = AdminService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<ClaimModel> _claims = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchClaims();
  }

  Future<void> _fetchClaims() async {
    setState(() => _isLoading = true);
    try {
      final claims = await _adminService.getAllClaims();
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<ClaimModel> get _filteredClaims {
    if (_selectedFilter == 'ALL') return _claims;
    if (_selectedFilter == 'UNASSIGNED') {
      return _claims.where((c) => c.assignedInvestigatorId == null || c.assignedInvestigatorId!.isEmpty).toList();
    }
    return _claims.where((c) => c.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All System Claims'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All'),
                _buildFilterChip('UNASSIGNED', 'Unassigned'),
                _buildFilterChip('PENDING', 'Pending'),
                _buildFilterChip('UNDER_INVESTIGATION', 'In Review'),
                _buildFilterChip('APPROVED', 'Approved'),
                _buildFilterChip('REJECTED', 'Rejected'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchClaims,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClaims.isEmpty
                      ? const Center(child: Text('No claims found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredClaims.length,
                          itemBuilder: (context, idx) {
                            final claim = _filteredClaims[idx];
                            final statusColor = AppTheme.getStatusColor(claim.status);
                            final riskColor = AppTheme.getRiskColor(claim.fraudScore);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () async {
                                  final res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminClaimDetailScreen(claimId: claim.id),
                                    ),
                                  );
                                  if (res == true) _fetchClaims();
                                },
                                leading: CircleAvatar(
                                  backgroundColor: riskColor.withAlpha(30),
                                  child: Icon(Icons.shield, color: riskColor),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text('Claim #${claim.claimNumber ?? claim.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(40),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        claim.status.replaceAll('_', ' '),
                                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Holder: ${claim.policyHolderName ?? "N/A"} | Policy: ${claim.policyNumber}'),
                                    Text(
                                      'Investigator: ${claim.assignedInvestigatorName ?? "UNASSIGNED"}',
                                      style: TextStyle(
                                        color: claim.assignedInvestigatorName == null ? AppTheme.warningAmber : Colors.grey,
                                        fontWeight: claim.assignedInvestigatorName == null ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(currencyFormat.format(claim.claimAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) => setState(() => _selectedFilter = key),
      ),
    );
  }
}
