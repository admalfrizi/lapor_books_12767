import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_apps/pages/dashboard_page.dart';
import 'package:lapor_book_apps/pages/detail_laporan_page.dart';
import 'package:lapor_book_apps/pages/splash_page.dart';
import 'firebase_options.dart';
import 'pages/add_form_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lapor Book',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: false,
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
      '/detail': (context) => DetailLaporanPage(),
    },
  ));
}
