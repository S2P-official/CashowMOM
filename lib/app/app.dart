import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import 'router.dart';


class MyApp extends StatelessWidget {
const MyApp({super.key});


@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => AuthProvider()..checkLoginStatus(),
child: MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Factory Login',
home: const AppRouter(),
),
);
}
}