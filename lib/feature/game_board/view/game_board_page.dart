import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/game_board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBoardPage extends StatelessWidget {
  const GameBoardPage({super.key});
  //BlocProvider<GameBoardCubit>(
  //             create: (BuildContext context) => GameBoardCubit())
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBoardCubit>(
      create: ((context) => GameBoardCubit()),
      child: const GameBoardBuilder(),
    );
  }
}

class GameBoardBuilder extends StatelessWidget {
  const GameBoardBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    context.read<GameBoardCubit>().customInit(context);
    debugPrint("1-GameBoardViewBuilder");
    return GameBoardView(
      title: 'Pose Detector',
      customPaint: context.read<GameBoardCubit>().customPaint,
      text: context.read<GameBoardCubit>().text,
      onImage: (inputImage) async {
        if (!context.read<GameBoardCubit>().isBusy) {
          context.read<GameBoardCubit>().processImageFace(inputImage);
        }
        //  context.read<GameBoardCubit>().inputImage = inputImage;
      },
    );
  }
}
