import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/claim_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/investigator_service.dart';
import '../../theme/app_theme.dart';
import 'investigation_detail_screen.dart';

class InvestigatorDashboardScreen extends StatefulWidget {
  const InvestigatorDashboardScreen({super.key});

  @override
  State<InvestigatorDashboardScreen> createState() => _InvestigatorDashboardScreenState();
}

class _InvestigatorDashboardScreenState extends State<InvestigatorDashboardScreen> {
  final InvestigatorService _investigatorService = InvestigatorService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<ClaimModel> _assignedClaims = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedClaims();
  }

  Future<void> _loadAssignedClaims() async {
    setState(() => _isLoading = true);
    try {
      final claims = await _investigatorService.getAssignedClaims();
      setState(() {
        _assignedClaims = claims;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final highRiskCount = _assignedClaims.where((c) => c.fraudScore >= 70).length;
    final pendingReviewCount = _assignedClaims.where((c) => c.status != 'APPROVED' && c.status != 'REJECTED').length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAssignedClaims,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Investigator Portal',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back, Agent ${user?.fullName ?? ''}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_outlined, color: AppTheme.warningAmber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Metrics Dashboard Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Assigned Claims',
                            '${_assignedClaims.length}',
                            Icons.folder_shared_outlined,
                            AppTheme.infoBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Pending Review',
                            '$pendingReviewCount',
                            Icons.access_time_filled,
                            AppTheme.warningAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'High AI Risk Score Flagged (≥70%)',
                      '$highRiskCount',
                      Icons.warning_amber_rounded,
                      AppTheme.dangerRed,
                      isWide: true,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Assigned Investigations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            if (_assignedClaims.isEmpty && !_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text('No active claims currently assigned to you.', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final claim = _assignedClaims[index];
                    final riskColor = AppTheme.getRiskColor(claim.fraudScore);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Card(
                        child: ListTile(
                          onTap: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvestigationDetailScreen(claimId: claim.id),
                              ),
                            );
                            if (res == true) _loadAssignedClaims();
                          },
                          leading: CircleAvatar(
                            backgroundColor: riskColor.withAlpha(30),
                            child: Text(
                              '${claim.fraudScore.toInt()}%',
                              style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text('Claim #${claim.claimNumber ?? claim.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: riskColor.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Risk: ${claim.fraudScore >= 70 ? "HIGH" : claim.fraudScore >= 40 ? "MEDIUM" : "LOW"}',
                                  style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Policy: ${claim.policyNumber}', style: const TextStyle(fontSize: 12)),
                                Text(currencyFormat.format(claim.claimAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _assignedClaims.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {bool isWide = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
