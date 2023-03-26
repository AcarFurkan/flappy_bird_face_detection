import 'dart:async';

import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildStartCounter extends StatelessWidget {
  const BuildStartCounter({
    super.key,
    required this.timerForStart,
  });

  final Timer timerForStart;

  @override
  Widget build(BuildContext context) {
    return !context.read<GameBoardCubit>().gameStarted
        ? Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Card(
                elevation: 10,
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text((3 - timerForStart.tick).toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
