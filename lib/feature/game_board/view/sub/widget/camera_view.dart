import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class BuildCameraView extends StatelessWidget {
  const BuildCameraView(
      {super.key, required this.scale, required this.controller});
  final double scale;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );
  }
}
