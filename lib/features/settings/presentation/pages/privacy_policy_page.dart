import 'package:flutter/material.dart';
import '../../../../shared/utils/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'MaxSpeak Privacy Policy\n\n'
              'Last updated: [Date]\n\n'
              '1. Information We Collect\n'
              'We collect information you provide directly to us, such as when you create an account, upload documents, or contact us for support.\n\n'
              '2. How We Use Your Information\n'
              'We use the information we collect to provide, maintain, and improve our services.\n\n'
              '3. Information Sharing\n'
              'We do not sell, trade, or otherwise transfer your personal information to third parties.\n\n'
              '4. Data Security\n'
              'We implement appropriate security measures to protect your personal information.\n\n'
              '5. Contact Us\n'
              'If you have any questions about this Privacy Policy, please contact us.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
