import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_dashboard_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'admin_claims_screen.dart';
import 'admin_workload_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  AdminDashboardModel? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
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
                              'Executive Overview',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'System-wide fraud metrics & claims overview',
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_isLoading)
                      const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                    else if (_stats != null) ...[
                      // Main Total Amount Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryBlue.withAlpha(80)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total System Claims Value', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormat.format(_stats!.totalClaimedAmount),
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBadge('Total: ${_stats!.totalClaims}', Colors.blue),
                                _buildBadge('High Risk: ${_stats!.highRiskCount}', AppTheme.dangerRed),
                                _buildBadge('Pending: ${_stats!.pendingClaims}', AppTheme.warningAmber),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Claim Decisions Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 180,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      PieChartSectionData(
                                        color: AppTheme.successGreen,
                                        value: (_stats!.approvedClaims > 0 ? _stats!.approvedClaims : 1).toDouble(),
                                        title: '${_stats!.approvedClaims}',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.dangerRed,
                                        value: (_stats!.rejectedClaims > 0 ? _stats!.rejectedClaims : 0).toDouble(),
                                        title: '${_stats!.rejectedClaims}',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.warningAmber,
                                        value: (_stats!.underInvestigationClaims > 0 ? _stats!.underInvestigationClaims : 0).toDouble(),
                                        title: '${_stats!.underInvestigationClaims}',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.infoBlue,
                                        value: (_stats!.pendingClaims > 0 ? _stats!.pendingClaims : 0).toDouble(),
                                        title: '${_stats!.pendingClaims}',
                                        radius: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildLegend(AppTheme.successGreen, 'Approved'),
                                  _buildLegend(AppTheme.dangerRed, 'Rejected'),
                                  _buildLegend(AppTheme.warningAmber, 'Under Review'),
                                  _buildLegend(AppTheme.infoBlue, 'Pending'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Action Tiles
                      Text('Management Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(context).cardTheme.color,
                        leading: const Icon(Icons.assignment_ind_outlined, color: AppTheme.primaryBlue),
                        title: const Text('Investigator Workload & Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Reassign claims or monitor capacity'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminWorkloadScreen()));
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(context).cardTheme.color,
                        leading: const Icon(Icons.gavel_outlined, color: AppTheme.accentCyan),
                        title: const Text('Claims Adjudication', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Review and decide pending claims'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminClaimsScreen()));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
