import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        double delay = index * 0.2;
        double value = (_controller.value - delay).clamp(0.0, 1.0);

        double scale = 0.6 + (value * 0.6);
        double opacity = 0.4 + (value * 0.6);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDot(0),
        buildDot(1),
        buildDot(2),
      ],
    );
  }
}