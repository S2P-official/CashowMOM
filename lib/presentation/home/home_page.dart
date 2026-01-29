import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _CompanyWelcomePageState();
}

class _CompanyWelcomePageState extends State<HomePage> { 
  bool _accepted = false;

 Future<void> _submit(BuildContext context) async {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms to continue")),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // ✅ Accept welcome
    auth.acceptWelcome();

    // 🔔 Show thank you dialog with restart suggestion
    showDialog(
      context: context,
      barrierDismissible: false, // force user to press button
      builder: (_) => AlertDialog(
        title: const Text("Thank You!"),
        content: const Text(
            "You have accepted the company policies.\n\n"
            "For the changes to take effect, please restart the app.\n"
            "Press the button below to close the app."),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Close dialog first
              Navigator.of(context).pop();

              // Close the app (Android)
              SystemNavigator.pop();

              // Alternative force exit if needed (less recommended)
              // exit(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text("Restart App"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Company Header
              Center(
                child: Column(
                  children: const [
                    Icon(Icons.business, size: 80, color: Colors.deepPurple),
                    SizedBox(height: 10),
                    Text(
                      "FictileCore Technologies Pvt. Ltd.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Driving Digital Transformation Across India",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _sectionTitle("Who We Are"),
              _sectionText(
                "FictileCore Technologies Pvt. Ltd. delivers software solutions "
                "that solve real-world business challenges and enable "
                "digitalization across enterprises in India.",
              ),

              _sectionTitle("What We Do"),
              _bullet("Enterprise Software & CRM Solutions"),
              _bullet("Business Process Automation"),
              _bullet("Mobile & Web Applications"),
              _bullet("Secure & Scalable Systems"),

              _sectionTitle("FAQs"),
              _faq(
                "Who can access this platform?",
                "Access is granted strictly based on assigned organizational roles.",
              ),
              _faq(
                "Is my data secure?",
                "Yes. Industry-standard security practices are followed.",
              ),
              _faq(
                "Is attendance monitored?",
                "Attendance activities are logged and role-controlled.",
              ),

              const SizedBox(height: 20),

              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: const Text(
                  "I understand and agree to the company policies.",
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Accept & Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 20),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _sectionText(String text) =>
      Text(text, style: const TextStyle(fontSize: 15));

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _faq(String q, String a) => ExpansionTile(
    title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
    children: [Padding(padding: const EdgeInsets.all(12), child: Text(a))],
  );
}
