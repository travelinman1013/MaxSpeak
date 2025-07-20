import 'package:flutter/material.dart';
import '../../../../shared/utils/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'MaxSpeak Terms of Service\n\n'
              'Last updated: [Date]\n\n'
              '1. Acceptance of Terms\n'
              'By using MaxSpeak, you agree to be bound by these Terms of Service.\n\n'
              '2. Description of Service\n'
              'MaxSpeak is a text-to-speech application that allows users to convert PDF documents to audio.\n\n'
              '3. User Responsibilities\n'
              'You are responsible for your use of the service and for any content you upload.\n\n'
              '4. Prohibited Uses\n'
              'You may not use the service for any illegal or unauthorized purpose.\n\n'
              '5. Termination\n'
              'We may terminate your access to the service at any time.\n\n'
              '6. Contact Us\n'
              'If you have any questions about these Terms, please contact us.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
