import 'package:flutter/material.dart';

class RedShape extends CustomClipper<Path> {
  final double width;
  final double height;

  RedShape(this.width, this.height);
  @override
  getClip(Size size) {
    var path = Path();
    // path.moveTo(0.0, height * 0.70);
    path.lineTo(
      0.0,
      height * 0.65,
    );
    path.quadraticBezierTo(
      height * 0.09,
      height * 0.80,
      height * 0.70,
      height * 0.80,
    );
    path.lineTo(width * 0.9, height * 0.80);
    path.quadraticBezierTo(
      width,
      height * 0.80,
      width,
      height * 1.05,
    );
    path.quadraticBezierTo(width * 1.0, height * 0.90, width * 1.0, 0);
    // path.quadraticBezierTo(size.width - 0, 0.0, size.width - 10, 0.0);
    path.lineTo(0.0, 0.0);
    // path.quadraticBezierTo(0.0, 10, 0.0, size.height * 0.20);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
