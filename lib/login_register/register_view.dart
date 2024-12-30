import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:randevu_sistemi/utils/service/auth/auth_service.dart';
import 'package:randevu_sistemi/utils/ui/button/randevu_button.dart';
import 'package:randevu_sistemi/utils/ui/input/randevu_textfield.dart';
import 'package:randevu_sistemi/utils/ui/sized/randevu_sized_box.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
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
            _registerButton(),
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
        Colors.yellow,
        Colors.deepPurple,
      ],
      begin: Alignment.topCenter,
    ));
  }

  FlutterLogo _logo() {
    return const FlutterLogo(
      size: 100,
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

  RandevuButton _registerButton() =>
      RandevuButton(buttonTitle: "Kayıt ol", onPressed: registerButtonTapped);

  Text _hataMesaji() {
    return Text(
      hataMesaji!,
      style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  bool validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      hataGostergesi("Lütfen Boş Alanları Doldurunuz !!");
      return false;
    } else {
      if (EmailValidator.validate(emailController.text)) {
        hataGizle();
        return true;
      } else {
        hataGostergesi("Email Formatı Hatalı !!");
        return false;
      }
    }
  }

  Future<void> registerButtonTapped() async {
    if (validateInputs()) {
      try {
        final AuthService authService = AuthService();
        final User? user = await authService.signUp(
            emailController.text, passwordController.text);

        if (user != null) {
          Navigator.pushNamed(context, "/home-view");
        }
      } catch (e) {
        hataGostergesi(e.toString());
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
