import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportPage extends StatefulWidget {
  final String reportedContentId;

  const ReportPage({super.key, required this.reportedContentId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  bool _isConsentChecked = false;

  final _detailsController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'basseialaa33@gmail.com');
  final _urlController = TextEditingController();

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

  final Map<String, bool> _violations = {
    'Audio': false,
    'Title/Description': false,
    'Cover Art': false,
    'Text': false,
    'Account holder': false,
    'Direct message': false,
  };

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate() && _selectedReason != null && _isConsentChecked) {
      // Process submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormValid = _selectedReason != null && _isConsentChecked;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const Icon(Icons.music_note, color: AppTheme.primaryBrand),
              const SizedBox(width: 8),
              Text(
                'RYTHMIFY',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Content to Rythmify',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Text(
                'Reason for Reporting',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason, style: AppTheme.bodyNormal),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryBrand,
                );
              }),

              const SizedBox(height: 24),
              Text(
                "Please provide more detail as to why you're reporting this content",
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailsController,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(
                  labelText: 'Content report details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please provide details' : null,
              ),

              const SizedBox(height: 24),
              Text(
                'Your Information',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Your email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              Text(
                'Please provide the link (URL) within Rythmify to the content you are reporting. Please only input one link per report.',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://rythmify.com/track/123/comment/4567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a URL';
                  if (!value.contains('rythmify.com')) return 'Please enter a valid Rythmify link';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              Text(
                'Select where the violation occurs (select all that apply)',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: _violations.keys.map((key) {
                  return IntrinsicWidth(
                    child: CheckboxListTile(
                      title: Text(key, style: AppTheme.bodyNormal),
                      value: _violations[key],
                      onChanged: (bool? value) {
                        setState(() {
                          _violations[key] = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.primaryBrand,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              CheckboxListTile(
                title: Text(
                  'I hereby state that I have a good-faith belief that the information and allegations I have submitted are accurate and complete.',
                  style: AppTheme.bodyNormal.copyWith(fontWeight: FontWeight.bold),
                ),
                value: _isConsentChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isConsentChecked = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryBrand,
              ),

              const SizedBox(height: 24),
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
                  child: Text(
                    'Submit Report',
                    style: AppTheme.titleMedium.copyWith(
                      color: isFormValid ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 64),
              _buildBrandFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandFooter() {
    return Column(
      children: [
        Center(
          child: Text(
            'Enjoy the full Rythmify experience',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Download on the App Store'),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('GET IT ON Google Play'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('About Rythmify:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            TextButton(onPressed: () {}, child: const Text('Company', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('About us', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('Blog', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('Jobs', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('Developers', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('Legal', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () {}, child: const Text('Copyright', style: TextStyle(color: Colors.grey))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt, color: Colors.white70),
            SizedBox(width: 24),
            Icon(Icons.flutter_dash, color: Colors.white70),
            SizedBox(width: 24),
            Icon(Icons.facebook, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 32),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('© 2026 Rythmify - Language: English (US)', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
