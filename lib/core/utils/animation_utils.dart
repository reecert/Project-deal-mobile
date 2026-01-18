import 'package:flutter/material.dart';

/// Animation constants for consistent, smooth animations throughout the app
class AnimDurations {
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Custom curves for smooth, creamy animations
class AnimCurves {
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve smoothIn = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
}

/// Fade + Slide transition for page navigation
class FadeSlideTransitionPage<T> extends Page<T> {
  final Widget child;
  final bool slideUp;

  const FadeSlideTransitionPage({
    required this.child,
    this.slideUp = false,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: AnimDurations.normal,
      reverseTransitionDuration: AnimDurations.fast,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimCurves.smooth,
        );

        final offsetTween = slideUp
            ? Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            : Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero);

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: offsetTween.animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

/// Slide up modal transition
class SlideUpTransitionPage<T> extends Page<T> {
  final Widget child;

  const SlideUpTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: AnimDurations.normal,
      reverseTransitionDuration: AnimDurations.fast,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimCurves.smooth,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

/// Animated wrapper for staggered fade-in effects
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool slideUp;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.slideUp = true,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AnimCurves.smooth,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideUp ? const Offset(0, 0.1) : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AnimCurves.smooth));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Animated scale wrapper for tap effects
class TapScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const TapScaleWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<TapScaleWidget> createState() => _TapScaleWidgetState();
}

class _TapScaleWidgetState extends State<TapScaleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimDurations.fastest,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: AnimCurves.smooth));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Animated counter for stats
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: AnimCurves.smooth,
      builder: (context, val, child) {
        return Text(val.toString(), style: style);
      },
    );
  }
}

/// Staggered grid/list animation controller
class StaggeredAnimationController {
  static Duration getDelay(int index, {int itemsPerRow = 2}) {
    return Duration(
      milliseconds: (index ~/ itemsPerRow) * 50 + (index % itemsPerRow) * 25,
    );
  }
}
