import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/animation_utils.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  // User's color palette
  static const Color _headerFooter = Color(0xFF161617);
  static const Color _primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: _headerFooter,
        indicatorColor: _primary,
        animationDuration: AnimDurations.normal,
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
          // Center Post button with animated bounce
          NavigationDestination(
            icon: _AnimatedPostButton(isPrimary: false),
            selectedIcon: _AnimatedPostButton(isPrimary: true),
            label: 'Post',
          ),
          const NavigationDestination(
            icon: Icon(Icons.forum_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.forum, color: Colors.white),
            label: 'Forums',
          ),
          const NavigationDestination(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.notifications, color: Colors.white),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/post')) return 2;
    if (location.startsWith('/forums')) return 3;
    if (location.startsWith('/alerts')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.push('/post');
        break;
      case 3:
        // TODO: Navigate to forums
        break;
      case 4:
        context.go('/alerts');
        break;
    }
  }
}

/// Animated Post button with subtle bounce effect on press
class _AnimatedPostButton extends StatefulWidget {
  final bool isPrimary;

  const _AnimatedPostButton({required this.isPrimary});

  @override
  State<_AnimatedPostButton> createState() => _AnimatedPostButtonState();
}

class _AnimatedPostButtonState extends State<_AnimatedPostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Initial bounce when widget appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isPrimary && mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedPostButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPrimary && !oldWidget.isPrimary && mounted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}
