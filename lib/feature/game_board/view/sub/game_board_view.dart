import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/sub/widget/live_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../../../main.dart';
import '../../cubit/game_board_cubit.dart';

class GameBoardView extends StatefulWidget {
  const GameBoardView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;

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

  //late Animation<double> animation;
  //late AnimationController animationController;
  @override
  void initState() {
    super.initState();

    timerForStart = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 3) {
        context.read<GameBoardCubit>().startGame();
        setState(() {});

        timerForStart.cancel();
      }
      setState(() {});
    });
    _cameraIndex = 1;
    _startLiveFeed();
  }

  late Timer timerForStart;

  @override
  void dispose() {
    _stopLiveFeed();
    timerForStart.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("body");

    return Scaffold(
      body: BuildLiveBody(
          controller: _controller,
          widget: widget,
          timerForStart: timerForStart),
      //  floatingActionButton: fab(),
    );
  }

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
      debugPrint("setstate 4");
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
