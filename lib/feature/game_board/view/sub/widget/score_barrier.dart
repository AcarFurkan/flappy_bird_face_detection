import 'package:flutter/material.dart';

class ScoreBarrier extends StatelessWidget {
  const ScoreBarrier({super.key, required this.barrierKey, this.height});
  final GlobalKey barrierKey;
  final double? height;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      key: barrierKey,
      height: height ?? 200,
      width: width * .04,
    );
  }
}
