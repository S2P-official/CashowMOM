// router.dart placeholder
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/login/login_page.dart';
import '../presentation/home/home_page.dart';
import '../state/auth_provider.dart';


class AppRouter extends StatelessWidget {
const AppRouter({super.key});


@override
Widget build(BuildContext context) {
final auth = Provider.of<AuthProvider>(context);


if (auth.isLoading) {
return const Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}


return auth.isLoggedIn ? const HomePage() : const LoginPage();
}
}