import 'package:flappy_bird_face_detection/feature/game_board/view/game_board_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:shared_preferences/shared_preferences.dart';

import '../../game_board/cubit/game_board_cubit.dart';

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
    // TODO: implement initState
    getBestScore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
            buildBestScoreText(),
            SizedBox(height: height * .05),
            buildStartGameMethod(true, shadowColor, context),
          ],
        )),
      ),
    );
  }

  Listener buildStartGameMethod(
      bool isPressed, Color shadowColor, BuildContext context) {
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
                color: shadowColor,
                blurRadius: (isPressed ? 5 : 3) * i,
                inset: true),
          for (double i = 1; i < 5; i++)
            BoxShadow(
                spreadRadius: -1,
                color: shadowColor,
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
                  getBestScore();
                });
              });
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Colors.white, width: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              " Start Game ",
              style: TextStyle(fontSize: 25, color: Colors.white, shadows: [
                for (double i = 1; i < (isPressed ? 8 : 4); i++)
                  BoxShadow(color: shadowColor, blurRadius: 3 * i, inset: true)
              ]),
            )),
      ),
    );
  }

  getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final int? result = prefs.getInt(Pref.bestScore.name);
    if (result != null) {
      setState(() {});
      bestScore = result;
    }
  }

  Widget buildBestScoreText() {
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
