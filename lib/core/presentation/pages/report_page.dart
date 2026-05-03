import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/models/report_request.dart';
import '../../data/models/report_repository.dart';
import '../../network/api_client.dart';

class ReportPage extends StatefulWidget {
  final String reportedContentId;
  final String resourceType;

  const ReportPage({
    super.key,
    required this.reportedContentId,
    this.resourceType = 'track',
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedReason;
  bool _isConsentChecked = false;
  bool _isLoading = false;

  final _detailsController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(
    text: 'basseialaa33@gmail.com',
  );
  final _urlController = TextEditingController();
  final _resourceTypeController = TextEditingController();
  final _resourceIdController = TextEditingController();

  late final ReportRepository _repository;

  final List<String> _reasons = [
    "It's hate speech",
    "It's harassing or abusive content",
    "It contains sexual content or nudity",
    "It contains graphic violence",
    "It promotes self-harm",
    "It's infringement of intellectual property",
    "It's spam or misleading content",
    "It's private or confidential information",
    "It's selling illegal goods",
    "Something else",
    "I just don't like it",
  ];

  final Map<String, String> _reasonMapping = {
    "It's hate speech": "hate_speech",
    "It's harassing or abusive content": "harassment",
    "It contains sexual content or nudity": "sexual_content",
    "It contains graphic violence": "violence",
    "It promotes self-harm": "self_harm",
    "It's infringement of intellectual property": "copyright",
    "It's spam or misleading content": "spam",
    "It's private or confidential information": "privacy",
    "It's selling illegal goods": "illegal_goods",
    "Something else": "other",
    "I just don't like it": "dislike",
  };

  final Map<String, bool> _violations = {
    'Audio': false,
    'Title/Description': false,
    'Cover Art': false,
    'Text': false,
    'Account holder': false,
    'Direct message': false,
  };

  @override
  void initState() {
    super.initState();

    _repository = ReportRepository(apiClient.dio);

    _resourceIdController.text = widget.reportedContentId;
    _resourceTypeController.text = widget.resourceType;

    // Adjust URL generation based on type
    if (widget.resourceType == 'track') {
      _urlController.text = 'https://rythmify.com/tracks/${widget.reportedContentId}';
    } else if (widget.resourceType == 'user') {
      _urlController.text = 'https://rythmify.com/profile/${widget.reportedContentId}';
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _urlController.dispose();
    _resourceIdController.dispose();
    _resourceTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || !_isConsentChecked) {
      return;
    }

    // If it's a track and no reason is selected, default to 'copyright'
    String reasonSlug;
    if (_selectedReason != null) {
      reasonSlug = _reasonMapping[_selectedReason!] ?? 'other';
    } else if (widget.resourceType == 'track') {
      reasonSlug = 'copyright';
    } else {
      // For other types (like users), we still require a reason
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for reporting')),
      );
      return;
    }

    final request = ReportRequest(
      resourceId: widget.reportedContentId,
      resourceType: widget.resourceType,
      reason: reasonSlug,
      description: _detailsController.text,
    );

    setState(() => _isLoading = true);

    try {
      await _repository.submitReport(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // For tracks, reason is optional (defaults to copyright)
    // For others, reason must be selected
    final bool isReasonValid =
        widget.resourceType == 'track' || _selectedReason != null;
    final bool isFormValid = isReasonValid && _isConsentChecked && !_isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Rythmify Report Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// RESOURCE PREVIEW
              Text(
                'Report Details',
                style: AppTheme.titleMedium.copyWith(color: AppTheme.babyBlue),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resourceTypeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resourceIdController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Resource ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
              ),

              const SizedBox(height: 32),

              /// TITLE
              Text(
                widget.resourceType == 'track'
                    ? 'Reason for Reporting (Default: Copyright)'
                    : 'Reason for Reporting',
                style: AppTheme.titleMedium.copyWith(color: AppTheme.babyBlue),
              ),

              const SizedBox(height: 12),

              Column(
                children: _reasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason, style: AppTheme.bodyNormal),
                    value: reason,
                    // ignore: deprecated_member_use
                    groupValue: _selectedReason,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() => _selectedReason = value);
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppTheme.primaryBrand,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// DETAILS
              Text(
                "Please provide more detail",
                style: AppTheme.titleMedium.copyWith(color: AppTheme.babyBlue),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter details' : null,
              ),

              const SizedBox(height: 24),

              /// NAME
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),

              const SizedBox(height: 16),

              /// EMAIL
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// URL (READ ONLY)
              TextFormField(
                controller: _urlController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
              ),

              const SizedBox(height: 24),

              /// VIOLATIONS
              Text(
                'Where is the violation?',
                style: AppTheme.titleMedium.copyWith(color: AppTheme.babyBlue),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 0,
                children: _violations.keys.map((key) {
                  return SizedBox(
                    width: 200,
                    child: CheckboxListTile(
                      title: Text(key, style: AppTheme.bodyNormal),
                      value: _violations[key],
                      onChanged: (val) {
                        setState(() {
                          _violations[key] = val ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      activeColor: AppTheme.primaryBrand,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// CONSENT
              CheckboxListTile(
                title: Text(
                  'I confirm this report is accurate',
                  style: AppTheme.bodyNormal.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _isConsentChecked,
                onChanged: (val) {
                  setState(() => _isConsentChecked = val ?? false);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primaryBrand,
              ),

              const SizedBox(height: 24),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isFormValid ? _submitReport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit Report',
                          style: AppTheme.titleMedium.copyWith(
                            color: isFormValid ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}