import 'package:flutter/material.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // soft enterprise background
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO / HEADER
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Stroke layer
                          RichText(
                            textAlign: TextAlign.center,
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

                          // Color fill layer
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
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
                        "Manufacturing Operations Management",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // LOGIN FORM
                      const LoginForm(),
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
