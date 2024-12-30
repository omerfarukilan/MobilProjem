import 'package:flutter/material.dart';

class RandevuButton extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback onPressed;
  const RandevuButton(
      {super.key, required this.buttonTitle, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        onPressed: onPressed,
        child: Text(buttonTitle));
  }
}
