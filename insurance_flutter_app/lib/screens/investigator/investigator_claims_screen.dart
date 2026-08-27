import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../services/investigator_service.dart';
import '../../theme/app_theme.dart';
import 'investigation_detail_screen.dart';

class InvestigatorClaimsScreen extends StatefulWidget {
  const InvestigatorClaimsScreen({super.key});

  @override
  State<InvestigatorClaimsScreen> createState() => _InvestigatorClaimsScreenState();
}

class _InvestigatorClaimsScreenState extends State<InvestigatorClaimsScreen> {
  final InvestigatorService _investigatorService = InvestigatorService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<ClaimModel> _claims = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchClaims();
  }

  Future<void> _fetchClaims() async {
    setState(() => _isLoading = true);
    try {
      final claims = await _investigatorService.getAssignedClaims();
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<ClaimModel> get _filteredClaims {
    if (_search.isEmpty) return _claims;
    return _claims.where((c) {
      return (c.claimNumber?.toLowerCase().contains(_search.toLowerCase()) == true) ||
          c.policyNumber.toLowerCase().contains(_search.toLowerCase()) ||
          (c.policyHolderName?.toLowerCase().contains(_search.toLowerCase()) == true);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Case Files'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: const InputDecoration(
                hintText: 'Search by case ID, policy, claimant...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchClaims,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClaims.isEmpty
                      ? const Center(child: Text('No assigned cases found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredClaims.length,
                          itemBuilder: (context, idx) {
                            final claim = _filteredClaims[idx];
                            final riskColor = AppTheme.getRiskColor(claim.fraudScore);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () async {
                                  final res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvestigationDetailScreen(claimId: claim.id),
                                    ),
                                  );
                                  if (res == true) _fetchClaims();
                                },
                                leading: CircleAvatar(
                                  backgroundColor: riskColor.withAlpha(30),
                                  child: Icon(Icons.security, color: riskColor),
                                ),
                                title: Text('Claim #${claim.claimNumber ?? claim.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Claimant: ${claim.policyHolderName ?? "N/A"} | Policy: ${claim.policyNumber}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormat.format(claim.claimAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Risk ${claim.fraudScore.toInt()}%',
                                      style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
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
}
