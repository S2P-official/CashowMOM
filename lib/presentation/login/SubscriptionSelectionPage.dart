import 'package:factory_app/presentation/login/DirectorPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubscriptionSelectionPage extends StatefulWidget {
  const SubscriptionSelectionPage({
    super.key,
    required this.tenantId,
    required this.tenantName,
  });

  final int tenantId;
  final String tenantName;

  @override
  State<SubscriptionSelectionPage> createState() =>
      _SubscriptionSelectionPageState();
}

class _SubscriptionSelectionPageState
    extends State<SubscriptionSelectionPage> {
  bool loading = false;

  final String planType = "PREMIUM";
  final int durationDays = 29;

  final String baseUrl =
      "http://192.168.29.215:8080/api/subscriptions/upgrade";

  Future<void> subscribeNow() async {
    setState(() => loading = true);

    final url =
        "$baseUrl?tenantId=${widget.tenantId}&planType=$planType&durationDays=$durationDays";

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterDirectorPage(
              tenantId: widget.tenantId,
              tenantName: widget.tenantName,
              gstNumber: "",
            ),
          ),
        );
      } else {
        _showSnack("Subscription failed: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Activate Subscription"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Header Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 42,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  const Text(
                    "Premium Trial Activated",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Tenant Name
                  Text(
                    widget.tenantName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Description
                  const Text(
                    "Enjoy a 29-day FREE Premium Trial.\n\n"
                    "Access advanced analytics, employee management, "
                    "reports, and all premium features at no cost.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// Plan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.green.shade400,
                      ),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          "Selected Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "PREMIUM • 29 DAYS FREE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : subscribeNow,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Continue to Setup",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
