import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shapes/screen_clip.dart';

Widget shapeComponet(BuildContext context, double shapeHeight) {
  return ClipPath(
    clipper: RedShape(MediaQuery.of(context).size.width, shapeHeight),
    child: Container(
      height: shapeHeight,
      decoration: BoxDecoration(
        color: Color(0XFFc80718),
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: 35,
          right: 35,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "Grocery",
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
              ),
            ),
            // SizedBox(
            //   height: 5,
            // ),
            // Text(
            //   "Lorem ipsum is a dummy text. Lorem ipsum is a dummy text.",
            //   style: TextStyle(
            //     fontSize: 15,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
}
