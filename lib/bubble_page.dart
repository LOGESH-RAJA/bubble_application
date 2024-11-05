import 'dart:math';
import 'package:flutter/material.dart';

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> {
  final ScrollController _controller = ScrollController();
  double _bubbleSize = 50.0; // Initial size of the red bubble
  bool _burst = false; // Indicates if the bubble has burst
  List<AnimatedBubble> _smallBubbles = []; // List to hold small bubbles
  double _redBubbleOpacity = 1.0; // Opacity for red bubble transition

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    // Check if at the bottom of the scroll
    if (_controller.position.pixels >= _controller.position.maxScrollExtent) {
      setState(() {
        _burst = true; // Trigger burst effect
        _generateSmallBubbles(); // Generate small bubbles
        _redBubbleOpacity = 0.0; // Fade out red bubble
      });
    } else if (_controller.position.pixels <= 0) {
      // Check if scrolled back to the top
      setState(() {
        _burst = false; // Reset burst effect
        _bubbleSize = 50.0; // Reset bubble size
        _smallBubbles.clear(); // Clear small bubbles
        _redBubbleOpacity = 1.0; // Restore red bubble opacity
      });
    } else {
      // Increase bubble size based on scroll position
      setState(() {
        _bubbleSize = 50.0 + (_controller.position.pixels / 5);
        _redBubbleOpacity = 1.0; // Make sure red bubble is fully visible
      });
    }
  }

  void _generateSmallBubbles() {
    _smallBubbles.clear(); // Clear previous bubbles
    for (int i = 0; i < 20; i++) {
      _smallBubbles.add(
        AnimatedBubble(
          key: ValueKey(i), // Unique key for each bubble
          size: 10.0 + (i * 2), // Vary bubble size
          duration: Duration(milliseconds: 600 + (i * 50)), // Vary duration
          angle: 2 * pi * (i / 20), // Calculate angle for circular distribution
          initialRadius:
              _bubbleSize / 2, // Start from the edge of the red bubble
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Scroll down to see the bubble effect!"),
      ),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _controller,
            child: Container(
              height: MediaQuery.of(context).size.height * 4,
              width: MediaQuery.of(context).size.width,
              color: Colors.amberAccent.shade100,
            ),
          ),
          // Main red bubble with gradient and fade-out transition
          Center(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _redBubbleOpacity,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: _burst ? 0 : _bubbleSize,
                height: _burst ? 0 : _bubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.withOpacity(0.7),
                      Colors.orange.withOpacity(0.5),
                      Colors.yellow.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: [0.3, 0.6, 0.9, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Display small bubbles when burst is true
          if (_burst)
            ..._smallBubbles.map((bubble) {
              final angle = bubble.angle;
              final x = (MediaQuery.of(context).size.width / 2) +
                  bubble.initialRadius * cos(angle) -
                  (bubble.size / 2);
              final y = (MediaQuery.of(context).size.height / 2) +
                  bubble.initialRadius * sin(angle) -
                  (bubble.size / 2);
              return Positioned(
                left: x,
                top: y,
                child: bubble,
              );
            }).toList(),
        ],
      ),
    );
  }
}

class AnimatedBubble extends StatefulWidget {
  final double size;
  final Duration duration;
  final double angle; // Angle for the position
  final double
      initialRadius; // Starting distance from the center (edge of red bubble)

  const AnimatedBubble({
    Key? key,
    required this.size,
    required this.duration,
    required this.angle,
    required this.initialRadius,
  }) : super(key: key);

  @override
  _AnimatedBubbleState createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _radiusAnimation = Tween<double>(
            begin: widget.initialRadius, end: widget.initialRadius + 50)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _radiusAnimation,
      builder: (context, child) {
        final double radius = _radiusAnimation.value;
        final double xOffset = radius * cos(widget.angle);
        final double yOffset = radius * sin(widget.angle);

        return Positioned(
          left: (MediaQuery.of(context).size.width / 2) +
              xOffset -
              widget.size / 2,
          top: (MediaQuery.of(context).size.height / 2) +
              yOffset -
              widget.size / 2,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.purple.withOpacity(0.5),
                      Colors.pink.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: [0.3, 0.6, 0.9, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
