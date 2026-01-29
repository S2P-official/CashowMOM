import 'package:factory_app/presentation/login/SubscriptionSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterTenantPage extends StatefulWidget {
  const RegisterTenantPage({super.key});

  @override
  State<RegisterTenantPage> createState() => _RegisterTenantPageState();
}

class _RegisterTenantPageState extends State<RegisterTenantPage> {
  final _formKey = GlobalKey<FormState>();

  /// BASIC INFO
  final tenantNameController = TextEditingController();
  final gstController = TextEditingController();
  final cinController = TextEditingController();

  /// ADDRESS (STANDARD FORMAT)
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();

  bool isSubmitting = false;

  String selectedCountry = 'India';

  final List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cape Verde',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];

  final RegExp gstRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  final String apiUrl = 'http://192.168.29.215:8080/api/tenants';

  Future<void> submitTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final payload = {
      "tenantName": tenantNameController.text.trim(),
      "gstNumber": gstController.text.trim().toUpperCase(),
      "cinNumber": cinController.text.trim().isEmpty
          ? null
          : cinController.text.trim(),
      "address": {
        "line1": addressLine1Controller.text.trim(),
        "line2": addressLine2Controller.text.trim(),
        "street": streetController.text.trim(),
        "city": cityController.text.trim(),
        "district": districtController.text.trim(),
        "state": stateController.text.trim(),
        "pinCode": pinController.text.trim(),
        "country": selectedCountry,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionSelectionPage(
              tenantId: data['id'],
              tenantName: data['tenantName'],
            ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void dispose() {
    tenantNameController.dispose();
    gstController.dispose();
    cinController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    streetController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// LOGO
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Billabong',
                                fontSize: 36,
                                letterSpacing: 2.5,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 1.8
                                  ..color = Colors.black,
                              ),
                              children: const [TextSpan(text: 'CASHOW MOM')],
                            ),
                          ),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Billabong',
                                fontSize: 36,
                                letterSpacing: 2.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'C',
                                  style: TextStyle(color: Colors.green),
                                ),
                                TextSpan(
                                  text: 'A',
                                  style: TextStyle(color: Colors.teal),
                                ),
                                TextSpan(
                                  text: 'S',
                                  style: TextStyle(color: Colors.orange),
                                ),
                                TextSpan(
                                  text: 'H',
                                  style: TextStyle(color: Colors.deepOrange),
                                ),
                                TextSpan(
                                  text: 'O',
                                  style: TextStyle(color: Colors.indigo),
                                ),
                                TextSpan(
                                  text: 'W ',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                TextSpan(
                                  text: 'M',
                                  style: TextStyle(color: Colors.purple),
                                ),
                                TextSpan(
                                  text: 'O',
                                  style: TextStyle(color: Colors.pink),
                                ),
                                TextSpan(
                                  text: 'M',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Tenant Registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// BASIC INFO
                      TextFormField(
                        controller: tenantNameController,
                        decoration: _inputDecoration("Tenant Name *"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Tenant name is required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: gstController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _inputDecoration(
                          "GST Number *",
                          hint: "22AAAAA0000A1Z5",
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "GST number is mandatory";
                          }
                          if (!gstRegex.hasMatch(v.trim().toUpperCase())) {
                            return "Invalid GST number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: cinController,
                        decoration: _inputDecoration("CIN Number (Optional)"),
                      ),

                      const SizedBox(height: 24),

                      /// ADDRESS
                      Text(
                        "Registered Address",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: addressLine1Controller,
                        decoration: _inputDecoration(
                          "Address Line 1 *",
                          hint: "Building / Plot / Company",
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Address Line 1 required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: addressLine2Controller,
                        decoration: _inputDecoration(
                          "Address Line 2",
                          hint: "Area / Landmark",
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: streetController,
                        decoration: _inputDecoration("Street / Road *"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Street required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: cityController,
                        decoration: _inputDecoration("City / Taluka *"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "City required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: districtController,
                        decoration: _inputDecoration("District *"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "District required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: stateController,
                        decoration: _inputDecoration("State / Province *"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "State required"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("PIN / ZIP Code *"),
                        validator: (v) => v == null || v.trim().length < 4
                            ? "Invalid PIN / ZIP"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedCountry,
                        decoration: _inputDecoration("Country *"),
                        items: countries
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedCountry = v!),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : submitTenant,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Continue",
                                  style: TextStyle(fontSize: 16),
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
      ),
    );
  }
}
