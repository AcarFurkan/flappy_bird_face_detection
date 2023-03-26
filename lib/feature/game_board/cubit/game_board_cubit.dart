import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../product/components/coordinate_translator.dart';

part 'game_board_state.dart';

enum BirdRotation { up, down, normal }

enum Pref { bestScore, currentScore }

class GameBoardCubit extends Cubit<GameBoardState> {
  GameBoardCubit() : super(GameBoardInitial()) {
    // customInit();
  }

  ///
  ///
  Timer? barrierTimer;

  late double barrierXOnePixel;
  late double barrierXTwoPixel;
  late double barrierXThreePixel;
  late double barrierYOnePixel;
  late double barrierYTwoPixel;
  late double barrierYThreePixel;
  void setBuildContext(BuildContext context) {
    buildContext = context;
  }

  void customInit(BuildContext context) {
    setBuildContext(context);
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
  }

  void startGame() {
    gameStarted = true;
    barrierTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      moveBarrier();
      checkGame();
    });
  }

  void moveBarrier() {
    double width = MediaQuery.of(buildContext!).size.width;
    double height = MediaQuery.of(buildContext!).size.height;

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
    emit(GameBoardInitial());
  }

  ///
  ///

  BuildContext? buildContext;
  bool gameStarted = false;

  final GlobalKey customerPainterKey = GlobalKey();

  GlobalKey scoreBarrierKeyOne = GlobalKey();
  GlobalKey scoreBarrierKeyTwo = GlobalKey();
  GlobalKey scoreBarrierKeyThree = GlobalKey();

  GlobalKey barrierKeyOne = GlobalKey();
  GlobalKey barrierKeyTwo = GlobalKey();
  GlobalKey barrierKeyThree = GlobalKey();
  GlobalKey barrierKeyFour = GlobalKey();
  GlobalKey barrierKeyFive = GlobalKey();
  GlobalKey barrierKeySix = GlobalKey();

  bool isCountedOne = false;
  bool isCountedTwo = false;
  bool isCountedThree = false;

  InputImage? inputImage;
  List<Offset> writeTrial = [];
  final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
    //  enableLandmarks: true,
    enableContours: true,
  ));
  //final PoseDetector _poseDetector =
  //    PoseDetector(options: PoseDetectorOptions());

  CustomPaint? customPaint;
  String? text;

  bool isBottomPass = false;
  bool isTopPass = false;
  int count = 0;

  void checkGame() async {
    _onCheckPassed();
    bool isFinish = checkFinish();
    if (isFinish) {
      final prefs = await SharedPreferences.getInstance();

      final int? bestScore = prefs.getInt(Pref.bestScore.name);
      if (bestScore == null) {
        prefs.setInt(Pref.bestScore.name, count);
      } else if (bestScore < count) {
        prefs.setInt(Pref.bestScore.name, count);
      }
    }
  }

  Offset? currentBirdOffset;
  BirdRotation birdRotation = BirdRotation.normal;

  //nose x axis position
  int x = 1;
  //nose y axis position
  int y = 1;
  bool isBusy = false;
  Future<void> processImageFace(InputImage inputImage) async {
    if (isBusy) return;
    // moveBarrier();

    isBusy = true;
    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      this.inputImage = inputImage;
      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
        if (buildContext != null) {
          x = faces.first.contours[FaceContourType.noseBottom]?.points[1].x ??
              0;
          y = faces.first.contours[FaceContourType.noseBottom]?.points[1].y ??
              0;

          /* final painter = FacePainter(faces, inputImage.inputImageData!.size,
              inputImage.inputImageData!.imageRotation, buildContext!);*/
          /*customPaint = CustomPaint(
            painter: painter,
            key: customerPainterKey,
          );*/
          for (var element in faces) {
            element.boundingBox;
            element.boundingBox.center;

            element.landmarks[FaceLandmarkType.noseBase]?.position.x;
            element.landmarks[FaceLandmarkType.noseBase]?.position.y;
            //canvas.drawImage(image, , paint);
            Offset newBirdOffset = Offset(
              translateX(
                  double.parse((element
                          .contours[FaceContourType.noseBottom]?.points[1].x
                          .toString() ??
                      "0")),
                  inputImage.inputImageData!.imageRotation,
                  MediaQuery.of(buildContext!).size,
                  inputImage.inputImageData!.size),
              translateY(
                  double.parse((element
                          .contours[FaceContourType.noseBottom]?.points[1].y
                          .toString() ??
                      "0")),
                  inputImage.inputImageData!.imageRotation,
                  MediaQuery.of(buildContext!).size,
                  inputImage.inputImageData!.size),
            );
            if (currentBirdOffset == null) {
              currentBirdOffset = newBirdOffset;
              birdRotation = BirdRotation.normal;
            } else {
              if (newBirdOffset.dy < currentBirdOffset!.dy) {
                birdRotation = BirdRotation.up;
                currentBirdOffset = newBirdOffset;
              } else if (newBirdOffset.dy > currentBirdOffset!.dy) {
                birdRotation = BirdRotation.down;
                currentBirdOffset = newBirdOffset;
              } else {
                birdRotation = BirdRotation.normal;
                currentBirdOffset = newBirdOffset;
              }
            }
          }
        } else {
          customPaint = null;
        }
      } else {
        text = 'Poses found: ${faces.length}\n\n';
        customPaint = null;
      }

      emit(GameBoardInitial());
    } catch (e) {
      isBusy = false;
    }
    isBusy = false;
  }

  final Size size1NoseBox = const Size(15.0, 15.0);

  //TODO: BURDA ISCOUNTEDONE A GEREK VAR MI CONTROLL ET
  bool checkFinish() {
    if (!gameStarted) return false;

    if (barrierKeyOne.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyOne.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      // if (position2.dx < 0) {
      //   isCountedOne = false;
      // }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        //  isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    if (barrierKeyTwo.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyTwo.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      // if (position2.dx < 0) {
      //   isCountedOne = false;
      // }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        // isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    if (barrierKeyThree.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyThree.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      // if (position2.dx < 0) {
      //   isCountedOne = false;
      // }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        //  isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    if (barrierKeyFour.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyFour.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      // if (position2.dx < 0) {
      //   isCountedOne = false;
      // }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        // isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    if (barrierKeyFive.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyFive.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      // if (position2.dx < 0) {
      //   isCountedOne = false;
      // }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        //  isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    if (barrierKeySix.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeySix.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      //   if (position2.dx < 0) {
      //     isCountedOne = false;
      //   }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (collide == true) {
        //   isCountedOne = true;
        emit(GameBoardCompleted());
        return true;
      }
    }
    return false;
  }

  void _onCheckPassed() {
    if (!gameStarted) return;
    if (scoreBarrierKeyOne.currentContext != null && inputImage != null) {
      RenderBox box2 =
          scoreBarrierKeyOne.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      if (position2.dx < 0) {
        isCountedOne = false;
      }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (!isCountedOne) {
        if (collide == true) {
          isCountedOne = true;

          count++;

          emit(GameBoardInitial());
        }
      }
    }
    if (scoreBarrierKeyTwo.currentContext != null && inputImage != null) {
      RenderBox box2 =
          scoreBarrierKeyTwo.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      if (position2.dx < 0) {
        isCountedTwo = false;
      }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (!isCountedTwo) {
        if (collide == true) {
          isCountedTwo = true;

          count++;

          emit(GameBoardInitial());
        }
      }
    }
    if (scoreBarrierKeyThree.currentContext != null && inputImage != null) {
      RenderBox box2 =
          scoreBarrierKeyThree.currentContext!.findRenderObject() as RenderBox;
      final size2 = box2.size;
      var screenSize =
          MediaQuery.of(buildContext!).size; //?? const Size(360.0, 780.0);

      final position2 = box2.localToGlobal(Offset.zero);
      if (position2.dx < 0) {
        isCountedThree = false;
      }

      Offset position1 = Offset(
          translateX(
              double.parse(x.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size),
          translateY(
              double.parse(y.toString()),
              inputImage!.inputImageData!.imageRotation,
              screenSize,
              inputImage!.inputImageData!.size));
      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1NoseBox.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1NoseBox.height > position2.dy);

      if (!isCountedThree) {
        if (collide == true) {
          isCountedThree = true;

          count++;

          emit(GameBoardInitial());
        }
      }
    }
  }
}
