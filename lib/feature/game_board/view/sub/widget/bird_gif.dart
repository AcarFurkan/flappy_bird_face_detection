import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildBirdGif extends StatelessWidget {
  const BuildBirdGif({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/gif/new_anim.gif",
      key: context.read<GameBoardCubit>().customerPainterKey,
      width: 175,
      fit: BoxFit.fitWidth,
    );
  }
}

class BuildBirdGifTwo extends StatelessWidget {
  const BuildBirdGifTwo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //    color: const Color(0xff7c94b6),
        image: const DecorationImage(
          image: AssetImage("assets/gif/dash_two.png"),
          fit: BoxFit.cover,
        ),
        // shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(100),

        border: Border.all(
            // color: Colors.red,
            // width: 2.0,
            ),
      ),
      height: 80,
      width: 100,
    );
  }
}
