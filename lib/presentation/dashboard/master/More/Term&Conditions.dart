import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle("Acceptance of Terms"),
            _SectionBody(
              "By accessing or using this application, you agree to comply with and be bound by these Terms and Conditions. If you do not agree, please discontinue use of the application.",
            ),

            _SectionTitle("Use of the Application"),
            _SectionBody(
              "This application is intended solely for authorized users. You agree to use the application responsibly and not to misuse any features, data, or services provided.",
            ),

            _SectionTitle("User Responsibilities"),
            _SectionBody(
              "Users are responsible for maintaining the confidentiality of their login credentials and for all activities performed under their account.",
            ),

            _SectionTitle("Account Security"),
            _SectionBody(
              "Any unauthorized access, attempt to breach security, or misuse of the application may result in suspension or termination of access.",
            ),

            _SectionTitle("Data Usage"),
            _SectionBody(
              "All data generated or stored within the application is subject to organizational policies and applicable laws. Users shall not copy, distribute, or misuse application data.",
            ),

            _SectionTitle("Limitation of Liability"),
            _SectionBody(
              "The organization shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use the application.",
            ),

            _SectionTitle("Termination"),
            _SectionBody(
              "We reserve the right to suspend or terminate access to the application at any time for violation of these Terms and Conditions or organizational policies.",
            ),

            _SectionTitle("Changes to Terms"),
            _SectionBody(
              "These Terms and Conditions may be updated periodically. Continued use of the application after updates constitutes acceptance of the revised terms.",
            ),

            _SectionTitle("Governing Law"),
            _SectionBody(
              "These Terms and Conditions shall be governed by and interpreted in accordance with the laws applicable in your jurisdiction.",
            ),

            _SectionTitle("Contact Information"),
            _SectionBody(
              "For questions regarding these Terms and Conditions, please contact our support team through the Contact Support section.",
            ),

            SizedBox(height: 24),

            Text(
              "Last updated: January 2026",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= REUSABLE WIDGETS =================

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.grey.shade800,
      ),
    );
  }
}
