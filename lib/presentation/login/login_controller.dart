import 'package:flutter/material.dart';
import 'widgets/login_form.dart';


class LoginPage extends StatelessWidget {
const LoginPage({super.key});


@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 32),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
"Employee Login",
style: const TextStyle(
fontFamily: "Billabong",
fontSize: 48,
color: Colors.black87,
),
),


const SizedBox(height: 40),


const LoginForm(),
],
),
),
),
);
}
}