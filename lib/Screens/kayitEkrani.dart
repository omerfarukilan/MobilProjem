import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:randevu_sistemi/utils/service/auth/auth_service.dart';
import 'package:randevu_sistemi/utils/ui/button/randevu_button.dart';
import 'package:randevu_sistemi/utils/ui/input/randevu_textfield.dart';
import 'package:randevu_sistemi/utils/ui/sized/randevu_sized_box.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController kullaniciIsimController = TextEditingController();
  final TextEditingController kullaniciTelController = TextEditingController();
  final TextEditingController kullaniciYasController = TextEditingController();

  final AuthService _authService = AuthService();

  bool showError = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _boxDecoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),
                _emailTextField(),
                const RandevuSizedBox(),
                _passwordTextField(),
                const RandevuSizedBox(),
                _kullaniciIsimTextfield(),
                const RandevuSizedBox(),
                _kullaniciTelTextfield(),
                const RandevuSizedBox(),
                _kullaniciYasTextfield(),
                const RandevuSizedBox(),
                _kayitButonu(),
                const RandevuSizedBox(),
                _girisButonu(context),
                showError ? _hataMesaji() : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(
            'assets/images/depositphotos_392760248-stock-photo-green-grass-texture-sport-background.jpg'),
        fit: BoxFit.cover, // Arka planın tüm alanı kaplamasını sağlar
      ),
      gradient: LinearGradient(
        colors: [Colors.yellow, Colors.deepPurple],
        begin: Alignment.topCenter,
      ),
    );
  }

  Widget _logo() {
    return SizedBox(
      height: 150,
      child: Image.asset(
        'assets/images/wpLogo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  RandevuTextfield _emailTextField() {
    return RandevuTextfield(
      textEditingController: emailController,
      hintText: "Email",
      keyboardType: TextInputType.emailAddress,
    );
  }

  RandevuTextfield _passwordTextField() {
    return RandevuTextfield(
      textEditingController: passwordController,
      obscureText: true,
      hintText: "Password",
      keyboardType: TextInputType.text,
    );
  }

  RandevuTextfield _kullaniciIsimTextfield() {
    return RandevuTextfield(
      textEditingController: kullaniciIsimController,
      hintText: "İsim",
      keyboardType: TextInputType.text,
    );
  }

  RandevuTextfield _kullaniciTelTextfield() {
    return RandevuTextfield(
      textEditingController: kullaniciTelController,
      hintText: "Telefon numarası",
      keyboardType: TextInputType.phone,
    );
  }

  RandevuTextfield _kullaniciYasTextfield() {
    return RandevuTextfield(
      textEditingController: kullaniciYasController,
      hintText: "Yaşınız",
      keyboardType: TextInputType.number,
    );
  }

  RandevuButton _kayitButonu() {
    return RandevuButton(
      buttonTitle: "Kayıt Ol",
      onPressed: _registerButtonTapped,
    );
  }

  TextButton _girisButonu(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/GirisEkrani'),
      child: const Text(
        "Giriş Yap",
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Text _hataMesaji() {
    return Text(
      errorMessage ?? '',
      style: const TextStyle(
        color: Colors.red,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _registerButtonTapped() async {
    if (_validateInputs()) {
      try {
        final user = await _authService.signUp(
          kullaniciIsimController.text,
          int.parse(kullaniciTelController.text),
          int.parse(kullaniciYasController.text),
          emailController.text,
          passwordController.text,
        );

        if (user != null) {
          Navigator.pushReplacementNamed(context, "/AnaEkran");
        }
      } catch (e) {
        _hataGoster(e.toString());
      }
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        kullaniciIsimController.text.isEmpty ||
        kullaniciTelController.text.isEmpty ||
        kullaniciYasController.text.isEmpty) {
      _hataGoster("Lütfen Boş Alanları Doldurunuz!");
      return false;
    } else if (!EmailValidator.validate(emailController.text)) {
      _hataGoster("Geçersiz Email Formatı!");
      return false;
    }
    _hataGizle();
    return true;
  }

  void _hataGoster(String message) {
    setState(() {
      showError = true;
      errorMessage = message;
    });
  }

  void _hataGizle() {
    setState(() {
      showError = false;
    });
  }
}
