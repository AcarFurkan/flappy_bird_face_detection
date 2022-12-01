import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../product/components/coordinate_translator.dart';

part 'game_board_state.dart';

enum BirdRotation { up, down, normal }

enum Pref { bestScore, currentScore }

class GameBoardCubit extends Cubit<GameBoardState> {
  GameBoardCubit() : super(GameBoardInitial()) {
    // customInit();
  }
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

  void setBuildContext(BuildContext context) {
    buildContext = context;
  }

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

  customInit() {
    start();
  }

  late Timer timerForFaceDetection;
  start() {
    timerForFaceDetection =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) async {
      if (inputImage != null) {
        await processImageFace(inputImage!);
      }

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
    });
  }

  Offset? currentBirdOffset;
  BirdRotation birdRotation = BirdRotation.normal;

  //nose x axis position
  int x = 1;
  //nose y axis position
  int y = 1;
  Future<void> processImageFace(InputImage inputImage) async {
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
      // print("1111" * 50);
    }
  }

  final Size size1NoseBox = const Size(15.0, 15.0);

  bool checkFinish() {
    if (!gameStarted) return false;

    if (barrierKeyOne.currentContext != null && inputImage != null) {
      RenderBox box2 =
          barrierKeyOne.currentContext!.findRenderObject() as RenderBox;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
      if (collide == true) {
        isCountedOne = true;
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

      //   print('Containers collide: $collide');
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

      //   print('Containers collide: $collide');
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

      //   print('Containers collide: $collide');
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
