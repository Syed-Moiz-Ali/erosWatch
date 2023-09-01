import 'dart:async';
import 'package:flutter/material.dart';

class MyAnimatedContainer extends StatefulWidget {
  bool showButton;
  Function(int) seekButton;

  MyAnimatedContainer(
      {super.key, required this.showButton, required this.seekButton});

  @override
  _MyAnimatedContainerState createState() => _MyAnimatedContainerState();
}

class _MyAnimatedContainerState extends State<MyAnimatedContainer>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            widget.seekButton(10);
            setState(() {
              widget.showButton = true;
            });

            Future.delayed(
              const Duration(seconds: 2),
              () {
                setState(() {
                  widget.showButton = false;
                  print("showBackward: ${widget.showButton}");
                });
              },
            );
          },
          child: Container(
            height: screenHeight - 85,
            width: screenWidth / 2 - 30,
            color: Colors.transparent,
          ),
        ),
        Visibility(
          visible: widget.showButton,
          child: Container(
            height: screenHeight,
            width: screenWidth / 2 - 30,
            color: Colors.black45,
            child: Center(
                child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (_controller.value * screenWidth / 2) - screenWidth / 2,
                    0.0,
                  ),
                  child: Transform.rotate(
                    angle: _controller.value * 2 * 3.1415926,
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.replay_10_rounded,
                size: 70,
                color: Colors.white,
              ),
            )),
          ),
        ),
      ],
    );
  }

  final Duration _duration = const Duration(minutes: 1);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
