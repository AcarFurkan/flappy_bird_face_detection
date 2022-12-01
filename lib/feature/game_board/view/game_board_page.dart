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
      child: BlocBuilder<GameBoardCubit, GameBoardState>(
        builder: (context, state) {
          context.read<GameBoardCubit>().setBuildContext(context);
          return GameBoardView(
            title: 'Pose Detector',
            customPaint: context.read<GameBoardCubit>().customPaint,
            text: context.read<GameBoardCubit>().text,
            bodyText: context.read<GameBoardCubit>().count.toString(),
            onImage: (inputImage) async {
              context.read<GameBoardCubit>().inputImage = inputImage;
            },
          );
        },
      ),
    );
  }
}
