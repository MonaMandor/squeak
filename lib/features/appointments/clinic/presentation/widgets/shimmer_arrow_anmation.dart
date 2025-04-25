
import 'package:flutter/material.dart';

class ShimmerArrowAnimation extends StatefulWidget {
  @override
  _ShimmerArrowAnimationState createState() => _ShimmerArrowAnimationState();
}

class _ShimmerArrowAnimationState extends State<ShimmerArrowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.white10,
                Colors.white,
                Colors.white10,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1 + _animation.value, 0), // Moves gradient
              end: Alignment(1 + _animation.value, 0),
            ).createShader(bounds);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                widthFactor: .4,
                child: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Align(
                widthFactor: .4,
                child: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Align(
                widthFactor: .4,
                child: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
