import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/claim_service.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';

class SubmitClaimScreen extends StatefulWidget {
  const SubmitClaimScreen({super.key});

  @override
  State<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends State<SubmitClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _claimService = ClaimService();
  final _documentService = DocumentService();

  final _policyNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'HEALTH';
  String? _selectedFilePath;
  String? _selectedFileName;
  String _selectedDocType = 'RECEIPT';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _policyNumberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final newClaim = await _claimService.submitClaim(
        policyNumber: _policyNumberController.text.trim(),
        claimAmount: double.parse(_amountController.text.trim()),
        incidentDate: dateStr,
        description: _descriptionController.text.trim(),
        claimType: _selectedType,
      );

      // Upload file if attached
      if (_selectedFilePath != null) {
        await _documentService.uploadDocument(
          claimId: newClaim.id,
          filePath: _selectedFilePath!,
          documentType: _selectedDocType,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim submitted successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Insurance Claim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Claim Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _policyNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Policy Number',
                      hintText: 'POL-100234',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter policy number' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Claim Amount (\$)',
                      hintText: '1500.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter amount';
                      if (double.tryParse(val.trim()) == null) return 'Enter valid numeric amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Claim Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'HEALTH', child: Text('Health & Medical')),
                      DropdownMenuItem(value: 'AUTO', child: Text('Auto & Vehicle Accident')),
                      DropdownMenuItem(value: 'PROPERTY', child: Text('Property & Home Damage')),
                      DropdownMenuItem(value: 'LIFE', child: Text('Life Insurance')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Theme.of(context).inputDecorationTheme.fillColor,
                    leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryBlue),
                    title: const Text('Incident Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Incident Details',
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter incident details' : null,
                  ),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Supporting Evidence / Document',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file),
                          label: Text(_selectedFileName ?? 'Attach Receipt / Proof'),
                        ),
                      ),
                      if (_selectedFilePath != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.dangerRed),
                          onPressed: () {
                            setState(() {
                              _selectedFilePath = null;
                              _selectedFileName = null;
                            });
                          },
                        ),
                    ],
                  ),
                  if (_selectedFilePath != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDocType,
                      decoration: const InputDecoration(labelText: 'Document Type'),
                      items: const [
                        DropdownMenuItem(value: 'RECEIPT', child: Text('Receipt / Bill')),
                        DropdownMenuItem(value: 'MEDICAL_REPORT', child: Text('Medical Report')),
                        DropdownMenuItem(value: 'POLICE_REPORT', child: Text('Police Report')),
                        DropdownMenuItem(value: 'PHOTO_PROOF', child: Text('Photo Proof')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDocType = val);
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('SUBMIT CLAIM'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
