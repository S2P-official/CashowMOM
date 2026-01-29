import 'package:flutter/material.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & FAQ"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _supportSection(context),
          const SizedBox(height: 24),
          _faqSection(),
        ],
      ),
    );
  }

  Widget _supportSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need Help?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Contact our support team. We are here to assist you.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            _supportTile(
              icon: Icons.call_outlined,
              title: "Call Support",
              subtitle: "+91 9353003316 / 9482002071",
              onTap: () {
                // TODO: launch tel:
              },
            ),
            _supportTile(
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "fictilecore@gmail.com",
              onTap: () {
                // TODO: launch mailto:
              },
            ),
            _supportTile(
              icon: Icons.chat_outlined,
              title: "WhatsApp Support",
              subtitle: "Chat with us",
              onTap: () {
                // TODO: launch WhatsApp
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _faqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frequently Asked Questions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        _faqItem(
          question: "How do I reset my password?",
          answer:
              "Go to Settings > Change Password and follow the instructions.",
        ),
        _faqItem(
          question: "How is attendance marked?",
          answer:
              "Attendance is managed by your manager if you do not have a device.",
        ),
        _faqItem(
          question: "Why am I not receiving notifications?",
          answer:
              "Ensure notifications are enabled in Settings and device permissions.",
        ),
        _faqItem(
          question: "Who can I contact for support?",
          answer:
              "You can call, email, or WhatsApp our support team using the options above.",
        ),
      ],
    );
  }

  Widget _faqItem({
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
