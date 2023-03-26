import 'package:camera/camera.dart';
import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/bird_gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildBirdImage extends StatelessWidget {
  const BuildBirdImage(
      {super.key, required this.scale, required this.controller});
  final double scale;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: context.read<GameBoardCubit>().currentBirdOffset!.dy - 35,
      left: context.read<GameBoardCubit>().currentBirdOffset!.dx - 35,
      child: Align(
        alignment: Alignment.center,
        child: RotationTransition(
          turns: context.read<GameBoardCubit>().birdRotation ==
                  BirdRotation.down
              ? const AlwaysStoppedAnimation(0 / 360)
              : context.read<GameBoardCubit>().birdRotation == BirdRotation.up
                  ? const AlwaysStoppedAnimation(-0 / 360)
                  : const AlwaysStoppedAnimation(0 / 360),
          child: const BuildBirdGif(),
        ),
      ),
    );
  }
}
