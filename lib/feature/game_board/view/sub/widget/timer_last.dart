import 'dart:async';

import 'package:flutter/material.dart';

class TimerLast extends StatelessWidget {
  const TimerLast({
    super.key,
    required this.timerForStart,
  });

  final Timer timerForStart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Card(
          elevation: 10,
          color: Colors.grey,
          child: Padding(
            //furkanacr911
            padding: const EdgeInsets.all(8.0),
            child: Text((3 - timerForStart.tick).toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
