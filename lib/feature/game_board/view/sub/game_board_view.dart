import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../../../main.dart';
import '../../cubit/game_board_cubit.dart';

enum ScreenMode { liveFeed, gallery }

class GameBoardView extends StatefulWidget {
  GameBoardView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.bodyText,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final String? bodyText;

  final Function(InputImage inputImage) onImage;

  final CameraLensDirection initialDirection;

  @override
  // ignore: library_private_types_in_public_api
  _GameBoardViewState createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<GameBoardView>
    with TickerProviderStateMixin {
  late double barrierXOnePixel;
  late double barrierXTwoPixel;
  late double barrierXThreePixel;
  late double barrierYOnePixel;
  late double barrierYTwoPixel;
  late double barrierYThreePixel;

  CameraController? _controller;
  num _cameraIndex = 1;

  Timer? barrierTimer;

  //late Animation<double> animation;
  //late AnimationController animationController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barrierXOnePixel = MediaQuery.of(context).size.width;
      barrierXTwoPixel = MediaQuery.of(context).size.width * 1.8;
      barrierXThreePixel = MediaQuery.of(context).size.width * 2.6;
      double height = MediaQuery.of(context).size.height;

      barrierYOnePixel =
          height * .15 + Random().nextInt((height * .5).toInt()).toDouble();
      barrierYTwoPixel =
          height * .15 + Random().nextInt((height * .5).toInt()).toDouble();
      barrierYThreePixel =
          height * .15 + Random().nextInt((height * .5).toInt()).toDouble();
    });

    context.read<GameBoardCubit>().start();
    timerForStart = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 3) {
        startGame();
        setState(() {});
        timerForStart.cancel();
      }
      setState(() {});
    });

    _cameraIndex = 1;
    _startLiveFeed();
  }

  late Timer timerForStart;

  void startGame() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    context.read<GameBoardCubit>().gameStarted = true;
    barrierTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        if (barrierXOnePixel < -width * 0.2) {
          barrierXOnePixel = width * 2;
          barrierYOnePixel =
              height * .15 + Random().nextInt((height * .6).toInt()).toDouble();
        } else {
          barrierXOnePixel -= 2;
        }

        if (barrierXTwoPixel < -width * 0.2) {
          barrierXTwoPixel = width * 2;
          barrierYTwoPixel =
              height * .15 + Random().nextInt((height * .6).toInt()).toDouble();
        } else {
          barrierXTwoPixel -= 2;
        }

        if (barrierXThreePixel < -width * 0.2) {
          barrierXThreePixel = width * 2;
          barrierYThreePixel =
              height * .15 + Random().nextInt((height * .6).toInt()).toDouble();
        } else {
          barrierXThreePixel -= 2;
        }
      });
    });
  }

  @override
  void dispose() {
    _stopLiveFeed();
    barrierTimer?.cancel();
    //context.read<GameBoardCubit>().faceDetector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      //  floatingActionButton: fab(),
    );
  }

  Widget _body() => _liveFeedBody();

  Widget _liveFeedBody() {
    if (_controller == null) {
      return Container();
    }
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return BlocListener<GameBoardCubit, GameBoardState>(
      listener: buildBlocListener,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          buildCameraView(scale),
          if (context.read<GameBoardCubit>().currentBirdOffset != null)
            buildBirdImage(),
          ...generateOneColumnBarrier(
              context, barrierXOnePixel, barrierYOnePixel, Colors.blue[500],
              bottomKey: context.read<GameBoardCubit>().barrierKeyOne,
              scoreBarrierKey:
                  context.read<GameBoardCubit>().scoreBarrierKeyOne,
              topKey: context.read<GameBoardCubit>().barrierKeyTwo),
          ...generateOneColumnBarrier(
              context, barrierXTwoPixel, barrierYTwoPixel, Colors.blue[500],
              bottomKey: context.read<GameBoardCubit>().barrierKeyThree,
              scoreBarrierKey:
                  context.read<GameBoardCubit>().scoreBarrierKeyTwo,
              topKey: context.read<GameBoardCubit>().barrierKeyFour),
          ...generateOneColumnBarrier(
              context, barrierXThreePixel, barrierYThreePixel, Colors.blue[500],
              bottomKey: context.read<GameBoardCubit>().barrierKeyFive,
              scoreBarrierKey:
                  context.read<GameBoardCubit>().scoreBarrierKeyThree,
              topKey: context.read<GameBoardCubit>().barrierKeySix),
          buildScoreCounter(context),
          buildStartCounter()
        ],
      ),
    );
  }

  Transform buildCameraView(double scale) {
    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Positioned buildBirdImage() => Positioned(
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
            child: buildBirdGif(),
          ),
        ),
      );

  Widget buildBirdGifTwo() {
    return Container(
      decoration: BoxDecoration(
        //    color: const Color(0xff7c94b6),
        image: const DecorationImage(
          image: AssetImage("assets/gif/hakan.png"),
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

  Widget buildBirdGif() {
    return Image.asset(
      "assets/gif//hakan.png",
      key: context.read<GameBoardCubit>().customerPainterKey,
      width: 60,
      fit: BoxFit.fitWidth,
    );
  }

  Widget buildStartCounter() => !context.read<GameBoardCubit>().gameStarted
      ? Positioned.fill(
          //  top: 150,
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
  void buildBlocListener(BuildContext context, GameBoardState state) async {
    // TODO: implement listener
    if (state is GameBoardCompleted) {
      barrierTimer?.cancel();

      context.read<GameBoardCubit>().timerForFaceDetection.cancel();
      await context.read<GameBoardCubit>().faceDetector.close();
      await context.read<GameBoardCubit>().close();

      // _controller?.stopImageStream();
      //await _controller?.stopImageStream();
      await _controller?.pausePreview();
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

  Widget buildScoreCounter(BuildContext context) =>
      context.read<GameBoardCubit>().gameStarted
          ? Positioned.fill(
              top: 100,
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 10,
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.bodyText ?? "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          : const SizedBox();

  Future _startLiveFeed() async {
    var cameras = await availableCameras();
    final camera = cameras[_cameraIndex.toInt()];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex.toInt()];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
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
      top: 0,
      child: MyBarrier(
        height: yPosition,
        barrierKey: topKey,
        isBottom: false,
        color: color,
      ),
    ),
    AnimatedPositioned(
      duration: const Duration(seconds: 0),
      left: xPosition,
      bottom: 0,
      child: MyBarrier(
        height: ((height - (yPosition + height * .2 + height * .15))) +
            height * .15,
        barrierKey: bottomKey,
        isBottom: true,
        color: color,
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

class MyBarrier extends StatelessWidget {
  const MyBarrier(
      {super.key,
      required this.barrierKey,
      this.color,
      required this.height,
      required this.isBottom});
  final GlobalKey barrierKey;
  final Color? color;
  final double? height;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
          color: color ?? Colors.green,
          border: Border.all(color: Colors.green[700]!),
          borderRadius: isBottom
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
      key: barrierKey,
      height: height,
      width: width * 0.2,
    );
  }
}

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
