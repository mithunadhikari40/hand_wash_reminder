import 'package:drinkwater/extension/color_extension.dart';
import 'package:flutter/material.dart';

class MainScreenPainter extends CustomPainter {
  MainScreenPainter(this.size);
  final Size size;

  @override
  void paint(Canvas canvas, Size _) {
    print("The size from painter $size");

    var height = size.height;
    var width = size.width;
    final paint = Paint();
    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = primaryColor;
    canvas.drawPath(mainBackground, paint);
    //that faint green path to the right side of the screen

    final whiteBackgroundPath =Path();
    whiteBackgroundPath.moveTo(0, height*.5);
    whiteBackgroundPath.quadraticBezierTo(width*.25, height*.45, width*.5, height*.5);
    final Rect rect = Rect.fromLTWH(0, height*.5, width, height*.5);
    whiteBackgroundPath.addRect(rect);


    whiteBackgroundPath.quadraticBezierTo(width*.85, height*.70, width*1, height*.7);
    whiteBackgroundPath.lineTo(width, height);
    paint.color = Colors.white;
    canvas.drawPath(whiteBackgroundPath, paint);
    final bubblePath = Path();
    bubblePath.moveTo(width, height*.06);
    bubblePath.quadraticBezierTo(width*.60, height*.20, width*.64, height*.5);
    bubblePath.quadraticBezierTo(width*.8, height*.7, width, height*.73);
    bubblePath.lineTo(width, height*.7);
    paint.color= secondaryColor;
    canvas.drawPath(bubblePath, paint);





  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }
}
