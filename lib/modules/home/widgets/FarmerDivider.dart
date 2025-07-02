import 'package:flutter/material.dart';

class FarmerDivider extends StatelessWidget {
  final double height;
  final double indent;
  final double endIndent;
  final Gradient gradient;

  const FarmerDivider({
    Key? key,
    this.height = 1.0, // mỏng 1 điểm ảnh
    this.indent = 24.0,
    this.endIndent = 24.0,
    this.gradient = const LinearGradient(
      colors: [
        Color.fromRGBO(67, 160, 71, 0.0),
        Color.fromRGBO(67, 160, 71, 0.3),
        Color.fromRGBO(67, 160, 71, 0.0),
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: indent,
        right: endIndent,
        top: height / 2,
        bottom: height / 2,
      ),
      height: height,
      decoration: BoxDecoration(gradient: gradient),
    );
  }
}
