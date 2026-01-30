import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterDirectorPage extends StatefulWidget {
  const RegisterDirectorPage({
    super.key,
    required this.tenantId,
    required this.tenantName,
    required this.gstNumber,
  });

  final int tenantId;
  final String tenantName;
  final String gstNumber;

  @override
  State<RegisterDirectorPage> createState() =>
      _RegisterDirectorPageState();
}

class _RegisterDirectorPageState extends State<RegisterDirectorPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSubmitting = false;

  final RegExp emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
  final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
  );

  late final String apiUrl =
      "http://192.168.29.215:8080/api/employees/tenant/${widget.tenantId}";

  Future<void> submitDirector() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final payload = {
      "employee_name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "password": passwordController.text.trim(),
      "role": "master",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Account Created"),
            content: const Text(
              "Director/Admin account has been created successfully.\n\n"
              "Please login to continue.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        _showSnack("Failed: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Create Director Account"),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// TENANT INFO
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tenantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.gstNumber.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 4),
                              child:
                                  Text("GST: ${widget.gstNumber}"),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// NAME
                    TextFormField(
                      controller: nameController,
                      decoration:
                          _inputDecoration("Full Name *"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Name is required"
                              : null,
                    ),
                    const SizedBox(height: 16),

                    /// EMAIL
                    TextFormField(
                      controller: emailController,
                      decoration: _inputDecoration("Email *"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!emailRegex.hasMatch(v.trim())) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// PHONE
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        "Mobile Number *",
                        hint: "10-digit Indian number",
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Mobile number is required";
                        }
                        if (!phoneRegex.hasMatch(v.trim())) {
                          return "Invalid mobile number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        "Password *",
                        hint:
                            "Min 8 chars, upper, lower, number & special",
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Password is required";
                        }
                        if (!passwordRegex.hasMatch(v.trim())) {
                          return "Password does not meet security rules";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    /// SUBMIT
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting ? null : submitDirector,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Create Account",
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
      ),
    );
  }
}
