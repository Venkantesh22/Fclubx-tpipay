import 'package:flutter/material.dart';

class AddToCartAnimation {
  static void run({
    required BuildContext context,
    required GlobalKey imageKey,
    required GlobalKey cartKey,
    required Widget child,
    required VoidCallback onAnimationComplete,
  }) {
    final overlay = Overlay.of(context);

    // Get the position of the source image
    final RenderBox? imageBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;
    final imagePosition = imageBox.localToGlobal(Offset.zero);
    final imageSize = imageBox.size;
    final startOffset = Offset(
      imagePosition.dx + imageSize.width / 2,
      imagePosition.dy + imageSize.height / 2,
    );

    // Get the position of the cart
    final RenderBox? cartBox = cartKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartBox == null) return;
    final cartPosition = cartBox.localToGlobal(Offset.zero);
    final cartSize = cartBox.size;
    final endOffset = Offset(
      cartPosition.dx + cartSize.width / 2,
      cartPosition.dy + cartSize.height / 2,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _FlyingImage(
          startOffset: startOffset,
          endOffset: endOffset,
          child: child,
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: 1500), () {
      overlayEntry.remove();
      onAnimationComplete();
    });
  }
}

class _FlyingImage extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final Widget child;

  const _FlyingImage({
    required this.startOffset,
    required this.endOffset,
    required this.child,
  });

  @override
  State<_FlyingImage> createState() => _FlyingImageState();
}

class _FlyingImageState extends State<_FlyingImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _positionAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _bigScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
    ));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.7, 1.0, curve: Curves.easeIn),
    ));
    _bigScaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _positionAnimation.value;
        final scale = _scaleAnimation.value;
        final bigScale = _bigScaleAnimation.value;
        final currentScale = _controller.value < 0.6 ? bigScale : scale;

        return Positioned(
          left: offset.dx - 25,
          top: offset.dy - 25,
          child: Center(
            child: Transform.scale(
              scale: currentScale,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
