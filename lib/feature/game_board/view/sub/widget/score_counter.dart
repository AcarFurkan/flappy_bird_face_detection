import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/game_board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScoreCounter extends StatelessWidget {
  const ScoreCounter({
    super.key,
    required this.widget,
  });

  final GameBoardView widget;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          elevation: 10,
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(context.read<GameBoardCubit>().count.toString(),
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
