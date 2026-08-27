import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../services/claim_service.dart';
import '../../theme/app_theme.dart';
import 'claim_detail_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  final ClaimService _claimService = ClaimService();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  List<ClaimModel> _claims = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchClaims();
  }

  Future<void> _fetchClaims() async {
    setState(() => _isLoading = true);
    try {
      final claims = await _claimService.getMyClaims();
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<ClaimModel> get _filteredClaims {
    return _claims.where((c) {
      final matchesFilter = _selectedFilter == 'ALL' || c.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          (c.claimNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) == true) ||
          c.policyNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.claimType?.toLowerCase().contains(_searchQuery.toLowerCase()) == true);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims History'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search by claim # or policy...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Claims'),
                      _buildFilterChip('PENDING', 'Pending'),
                      _buildFilterChip('UNDER_INVESTIGATION', 'In Review'),
                      _buildFilterChip('APPROVED', 'Approved'),
                      _buildFilterChip('REJECTED', 'Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchClaims,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClaims.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'No matching claims found.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredClaims.length,
                          itemBuilder: (context, index) {
                            final claim = _filteredClaims[index];
                            final color = AppTheme.getStatusColor(claim.status);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClaimDetailScreen(claimId: claim.id),
                                    ),
                                  );
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.shield_outlined, color: color),
                                ),
                                title: Text(
                                  'Claim #${claim.claimNumber ?? claim.id}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Policy: ${claim.policyNumber} | ${claim.claimType ?? 'General'}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(claim.claimAmount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    claim.status.replaceAll('_', ' '),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filterKey;
          });
        },
      ),
    );
  }
}
