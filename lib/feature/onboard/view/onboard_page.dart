import 'package:flappy_bird_face_detection/feature/game_board/cubit/game_board_cubit.dart';
import 'package:flappy_bird_face_detection/feature/game_board/view/game_board_page.dart';

import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final Color shadowColor = Colors.green;
  int? bestScore;
  @override
  void initState() {
    getBestScore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // return const MyBookings();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: height * .05),
            Lottie.asset('assets/lottie/bird_start.json'),
            SizedBox(height: height * .05),
            BuildBestScoreText(bestScore: bestScore),
            SizedBox(height: height * .05),
            BuildStartGameMethod(onPressed: () {
              getBestScore();
            }),
          ],
        )),
      ),
    );
  }

  Future<void> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final int? result = prefs.getInt(Pref.bestScore.name);
    if (result != null) {
      setState(() {});
      bestScore = result;
    }
  }
}

class BuildStartGameMethod extends StatefulWidget {
  const BuildStartGameMethod({super.key, required this.onPressed});

  final VoidCallback onPressed;
  final Color shadowColor = Colors.green;

  @override
  State<BuildStartGameMethod> createState() => _BuildStartGameMethodState();
}

class _BuildStartGameMethodState extends State<BuildStartGameMethod> {
  bool isPressed = true;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() {
        isPressed = true;
      }),
      onPointerUp: (_) => setState(() {
        isPressed = false;
      }),
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
          for (double i = 1; i < 5; i++)
            BoxShadow(
                color: widget.shadowColor,
                blurRadius: (isPressed ? 5 : 3) * i,
                inset: true),
          for (double i = 1; i < 5; i++)
            BoxShadow(
                spreadRadius: -1,
                color: widget.shadowColor,
                blurRadius: (isPressed ? 5 : 3) * i,
                blurStyle: BlurStyle.outer)
        ]),
        child: TextButton(
            onHover: ((value) {
              setState(() {
                isPressed = value;
              });
            }),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameBoardPage(),
                  )).then((value) {
                setState(() {
                  widget.onPressed();
                });
              });
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: Colors.white, width: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              " Start Game ",
              style: TextStyle(fontSize: 25, color: Colors.white, shadows: [
                for (double i = 1; i < (isPressed ? 8 : 4); i++)
                  BoxShadow(
                      color: widget.shadowColor, blurRadius: 3 * i, inset: true)
              ]),
            )),
      ),
    );
  }
}

class BuildBestScoreText extends StatelessWidget {
  const BuildBestScoreText({super.key, required this.bestScore});

  final int? bestScore;

  @override
  Widget build(BuildContext context) {
    return bestScore != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Best Score: $bestScore ",
              style: const TextStyle(fontSize: 25, color: Colors.white),
            ),
          )
        : const SizedBox();
  }
}

class MyBookings extends StatelessWidget {
  const MyBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom paint Demo'),
      ),
      body: Container(
        child: Center(
          child: CustomPaint(
            size: Size(context.width * .2, context.height * .65),
            painter: CurvedPainterTop(),
            child: Image.asset(
              "assets/gif/2.png",
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedPainterTop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 15;
    const double curvedValue = 10;
    var path = Path();

    path.moveTo(size.width * .1, 0);
    path.lineTo(size.width * .9, 0);
    path.lineTo(size.width * .9, size.height * .96);
    path.lineTo(size.width, size.height * .96);
    path.lineTo(size.width, size.height - curvedValue);
    path.quadraticBezierTo(
        size.width, size.height, size.width - curvedValue, size.height);
    path.lineTo(curvedValue, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - curvedValue);
    path.lineTo(0, size.height * .96);
    path.lineTo(size.width * .1, size.height * .96);
    path.lineTo(size.width * .1, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 15;
    const double curvedValue = 10;
    var path = Path();
    path.moveTo(curvedValue, 0);

    path.lineTo(size.width - curvedValue, 0);
    path.quadraticBezierTo(size.width, 0, size.width, curvedValue);

    path.lineTo(size.width, size.height * .04 - curvedValue);
    path.quadraticBezierTo(
        size.width, size.height * .04, size.width * .8, size.height * .04);

    path.lineTo(size.width * .8, size.height * .04);
    path.lineTo(size.width * .8, size.height);
    path.lineTo(size.width * .2, size.height);
    path.lineTo(size.width * .2, size.height * .04);
    path.quadraticBezierTo(
        0, size.height * .04, 0, size.height * .04 - curvedValue);
    path.lineTo(0, size.height * .04);
    path.lineTo(0, curvedValue);
    path.quadraticBezierTo(0, 0, curvedValue, 0);

    //   path.lineTo(0, 0);

    // path.moveTo(0, 0);

    // path.lineTo(20, 0);
    // path.lineTo(20, 5);
    // path.lineTo(15, 5);
    // path.lineTo(15, 20);

    // path.lineTo(5, 20);
    // path.lineTo(5, 5);

    // path.lineTo(0, 5);
    // path.lineTo(0, 0);

    // path.moveTo(0, size.height * 0.7);
    // path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
    //     size.width * 0.5, size.height * 0.8);
    // path.quadraticBezierTo(size.width * 0.75, size.height * 0.9,
    //     size.width * 1.0, size.height * 0.8);
    // path.lineTo(size.width, size.height);
    // path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
