import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:randevu_sistemi/Screens/adminAnaEkran.dart';
import 'package:randevu_sistemi/Screens/anaEkran.dart';
import 'package:randevu_sistemi/Screens/yoneticiGiris.dart';
import 'package:randevu_sistemi/Screens/girisEkrani.dart';
import 'package:randevu_sistemi/Screens/kayitEkrani.dart';
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
      title: 'Halısaha Rezervasyon ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GirisEkrani(),
        '/KayitEkrani': (context) => const KayitEkrani(),
        '/AnaEkran': (context) => const AnaEkran(),
        '/GirisEkrani': (context) => const GirisEkrani(),
        '/YoneticiEkrani': (context) => const YoneticiGiris(),
        '/AdminAnaEkrani': (context) => const AdminAnaEkran()
      },
    );
  }
}
