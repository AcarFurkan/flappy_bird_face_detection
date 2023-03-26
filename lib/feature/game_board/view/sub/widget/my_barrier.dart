import 'package:flappy_bird_face_detection/feature/onboard/view/onboard_page.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class MyBarrier extends StatelessWidget {
  const MyBarrier(
      {super.key,
      required this.barrierKey,
      this.color,
      required this.height,
      required this.isBottom,
      required this.isImage});
  final GlobalKey barrierKey;
  final Color? color;
  final double height;
  final bool isBottom;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    return isImage
        ? isBottom
            ? CustomPaint(
                size: Size(context.width * .15, height),
                painter: CurvedPainter(),
                child: Image.asset(
                  "assets/gif/1.png",
                  // width: context.width * .32,
                  fit: BoxFit.fitHeight,
                  height: (height),
                  key: barrierKey,
                ),
              )
            : CustomPaint(
                size: Size(context.width * .15, height),
                painter: CurvedPainterTop(),
                child: Image.asset(
                  "assets/gif/2.png",
                  // width: context.width * .32,
                  fit: BoxFit.fitHeight,
                  height: (height),
                  key: barrierKey,
                ),
              )
        : Container(
            decoration: BoxDecoration(
                color: color ?? Colors.green,
                border: Border.all(color: Colors.green[700]!),
                borderRadius: isBottom
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))
                    : const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
            key: barrierKey,
            height: height,
            width: context.width * 0.2,
          );
  }
}
