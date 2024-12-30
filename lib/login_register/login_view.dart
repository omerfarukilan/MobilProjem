import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:randevu_sistemi/utils/ui/button/randevu_button.dart';
import 'package:randevu_sistemi/utils/ui/input/randevu_textfield.dart';
import 'package:randevu_sistemi/utils/ui/sized/randevu_sized_box.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hataBilgisi = false;
  String? hataMesaji = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _logo(),
            _emailTextField(),
            const RandevuSizedBox(),
            _passwordTextField(),
            const RandevuSizedBox(),
            _loginButton(context),
            const RandevuSizedBox(),
            _registerButton(context),
            const RandevuSizedBox(),
            hataBilgisi ? _hataMesaji() : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
        gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 59, 188, 4),
        Color.fromARGB(255, 255, 255, 255),
      ],
      begin: Alignment.topCenter,
    ));
  }

  Widget _logo() {
    return Image.asset(
      'https://store.donanimhaber.com/c8/70/73/c8707361023fc9726bfd2dc0851eb73d.jpg',
      height: 100,
    );
  }

  RandevuTextfield _emailTextField() {
    return RandevuTextfield(
        textEditingController: emailController,
        hintText: "Email",
        keyboardType: TextInputType.emailAddress);
  }

  RandevuTextfield _passwordTextField() {
    return RandevuTextfield(
        textEditingController: passwordController,
        obscureText: true,
        hintText: "Password",
        keyboardType: TextInputType.emailAddress);
  }

  RandevuButton _loginButton(BuildContext context) => RandevuButton(
      buttonTitle: "Giriş Yap", onPressed: () => validateInputs(context));

  RandevuButton _registerButton(BuildContext context) => RandevuButton(
      buttonTitle: "Kayıt Ol",
      onPressed: () => Navigator.pushNamed(context, '/register'));

  Text _hataMesaji() {
    return Text(
      hataMesaji!,
      style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  void validateInputs(BuildContext context) {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      hataGostergesi("Lütfen Boş Alanları Doldurunuz !!");
    } else {
      if (EmailValidator.validate(emailController.text)) {
        hataGizle();
        Navigator.pushNamed(
            context, '/home-view'); // Başarılı girişte yönlendirme
      } else {
        hataGostergesi("Email Formatı Hatalı !!");
      }
    }
  }

  void hataGostergesi(String mesaj) {
    setState(() {
      hataBilgisi = true;
      hataMesaji = mesaj;
    });
  }

  void hataGizle() {
    setState(() {
      hataBilgisi = false;
    });
  }
}
