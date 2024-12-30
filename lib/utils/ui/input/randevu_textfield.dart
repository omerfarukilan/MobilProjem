import 'package:flutter/material.dart';

class RandevuTextfield extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  const RandevuTextfield(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      this.keyboardType = TextInputType.text,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      keyboardType: keyboardType,
      cursorColor: const Color.fromARGB(255, 0, 0, 0),
      obscureText: obscureText,
      decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 212, 0, 0)))),
    );
  }
}
