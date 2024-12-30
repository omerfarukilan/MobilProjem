import 'package:flutter/material.dart';

class RandevuSizedBox extends StatelessWidget {
  final double height, widght;
  const RandevuSizedBox({super.key, this.height = 10, this.widght = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: widght,
    );
  }
}
