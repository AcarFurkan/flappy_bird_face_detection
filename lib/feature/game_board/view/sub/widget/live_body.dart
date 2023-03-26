import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/game_board_view.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/bird_image.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/camera_view.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/my_barrier.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/score_barrier.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/score_counter.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/timer_last.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildLiveBody extends StatelessWidget {
  const BuildLiveBody({
    super.key,
    required this.controller,
    required this.timerForStart,
    required this.widget,
  });

  final GameBoardView widget;
  final CameraController? controller;
  final Timer timerForStart;

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Container();
    }
    if (controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * controller!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;
    return BlocConsumer<GameBoardCubit, GameBoardState>(
      listener: blocListener,
      builder: (context, state) {
        debugPrint("state: $state");
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            BuildCameraView(scale: scale, controller: controller),
            if (context.read<GameBoardCubit>().currentBirdOffset != null)
              BuildBirdImage(controller: controller, scale: scale),
            ...generateOneColumnBarrier(
                context,
                context.read<GameBoardCubit>().barrierXOnePixel,
                context.read<GameBoardCubit>().barrierYOnePixel,
                Colors.blue[500],
                bottomKey: context.read<GameBoardCubit>().barrierKeyOne,
                scoreBarrierKey:
                    context.read<GameBoardCubit>().scoreBarrierKeyOne,
                topKey: context.read<GameBoardCubit>().barrierKeyTwo),
            ...generateOneColumnBarrier(
                context,
                context.read<GameBoardCubit>().barrierXTwoPixel,
                context.read<GameBoardCubit>().barrierYTwoPixel,
                Colors.blue[500],
                bottomKey: context.read<GameBoardCubit>().barrierKeyThree,
                scoreBarrierKey:
                    context.read<GameBoardCubit>().scoreBarrierKeyTwo,
                topKey: context.read<GameBoardCubit>().barrierKeyFour),
            ...generateOneColumnBarrier(
                context,
                context.read<GameBoardCubit>().barrierXThreePixel,
                context.read<GameBoardCubit>().barrierYThreePixel,
                Colors.blue[500],
                bottomKey: context.read<GameBoardCubit>().barrierKeyFive,
                scoreBarrierKey:
                    context.read<GameBoardCubit>().scoreBarrierKeyThree,
                topKey: context.read<GameBoardCubit>().barrierKeySix),
            context.read<GameBoardCubit>().gameStarted
                ? ScoreCounter(widget: widget)
                : const SizedBox(),
            !context.read<GameBoardCubit>().gameStarted
                ? TimerLast(timerForStart: timerForStart)
                : const SizedBox()
          ],
        );
      },
    );
  }

  List<Widget> generateOneColumnBarrier(
      BuildContext context, double xPosition, yPosition, Color? color,
      {required GlobalKey topKey,
      required GlobalKey bottomKey,
      required GlobalKey scoreBarrierKey}) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return [
      AnimatedPositioned(
        duration: const Duration(seconds: 0),
        left: xPosition,
        bottom: height - (yPosition),

        //top: 0,
        child: MyBarrier(
          height: height * .75,
          // height: yPosition,
          barrierKey: topKey,
          isBottom: false,
          color: color,
          isImage: true,
        ),
      ),
      AnimatedPositioned(
        duration: const Duration(seconds: 0),
        left: xPosition,
        //bottom: 0,
        top: yPosition + height * .2,
        child: MyBarrier(
          //  height: ((height - (yPosition + height * .2 + height * .15))) +
          //      height * .15,
          height: height * .75,
          barrierKey: bottomKey,
          isBottom: true,
          color: color,
          isImage: true,
        ),
      ),
      AnimatedPositioned(
        duration: const Duration(seconds: 0),
        left: xPosition + (width * .2 - width * .04),
        bottom: height - (yPosition + height * .2),
        child: ScoreBarrier(
          height: height * .2,
          barrierKey: scoreBarrierKey,
        ),
      ),
    ];
  }

  void blocListener(BuildContext context, GameBoardState state) async {
    if (state is GameBoardCompleted) {
      context.read<GameBoardCubit>().gameStarted = false;
      context.read<GameBoardCubit>().barrierTimer?.cancel();
      await context.read<GameBoardCubit>().faceDetector.close();
      await context.read<GameBoardCubit>().close();

      await controller?.pausePreview();
      // ignore: use_build_context_synchronously
      await AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              dismissOnTouchOutside: false,
              animType: AnimType.rightSlide,
              title: 'Game Over',
              desc: 'Your Score: ${context.read<GameBoardCubit>().count}',
              btnOkOnPress: () {
                Navigator.pop(context);
              },
              btnOkText: "Back Menu")
          .show();
    }
  }
}
