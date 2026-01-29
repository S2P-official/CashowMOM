import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle("Introduction"),
            _SectionBody(
              "This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our application. By using this app, you agree to the practices described in this policy.",
            ),

            _SectionTitle("Information We Collect"),
            _SectionBody(
              "We may collect personal information such as your name, phone number, email address, employee ID, and usage data required to operate the application effectively.",
            ),

            _SectionTitle("How We Use Your Information"),
            _SectionBody(
              "Your information is used to manage authentication, attendance, notifications, security, customer support, and to improve application performance and reliability.",
            ),

            _SectionTitle("Data Sharing & Disclosure"),
            _SectionBody(
              "We do not sell or rent your personal information. Data may be shared only with authorized personnel or service providers strictly for business and operational purposes.",
            ),

            _SectionTitle("Data Security"),
            _SectionBody(
              "We implement appropriate technical and organizational security measures to protect your data against unauthorized access, alteration, or disclosure.",
            ),

            _SectionTitle("Data Retention"),
            _SectionBody(
              "Your data is retained only as long as necessary to fulfill business, legal, and operational requirements.",
            ),

            _SectionTitle("Your Rights"),
            _SectionBody(
              "You have the right to access, update, or request deletion of your personal data, subject to applicable laws and organizational policies.",
            ),

            _SectionTitle("Changes to This Policy"),
            _SectionBody(
              "We may update this Privacy Policy from time to time. Any changes will be communicated through the application or official channels.",
            ),

            _SectionTitle("Contact Us"),
            _SectionBody(
              "If you have any questions or concerns regarding this Privacy Policy, please contact our support team through the Contact Support page.",
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
