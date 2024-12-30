import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:randevu_sistemi/auth/moduls/home/home_view.dart';
import 'package:randevu_sistemi/login_register/login_view.dart';
import 'package:randevu_sistemi/login_register/register_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Randevu Sistemi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home-view': (context) => const HomeView(),
        '/login-view': (context) => const LoginView(), // Login ekranı rotası
      },
    );
  }
}
