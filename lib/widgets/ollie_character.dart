import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OllieState { idle, reading, celebrating, confused }

/// Ollie the Owl character widget.
/// Uses emoji/animated containers as placeholder until Rive assets are added.
class OllieCharacter extends StatefulWidget {
  final OllieState state;
  final double size;

  const OllieCharacter({
    super.key,
    required this.state,
    this.size = 100,
  });

  @override
  State<OllieCharacter> createState() => _OllieCharacterState();
}

class _OllieCharacterState extends State<OllieCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _setupAnimation();
  }

  @override
  void didUpdateWidget(OllieCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _ctrl.stop();
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    switch (widget.state) {
      case OllieState.idle:
        _ctrl.duration = const Duration(seconds: 2);
        _scaleAnim = Tween(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
        );
        _rotateAnim = Tween(begin: 0.0, end: 0.0).animate(_ctrl);
        _ctrl.repeat(reverse: true);
        break;
      case OllieState.reading:
        _ctrl.duration = const Duration(milliseconds: 400);
        _scaleAnim = Tween(begin: 1.0, end: 1.0).animate(_ctrl);
        _rotateAnim =
            Tween(begin: -0.05, end: 0.05).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
        );
        _ctrl.repeat(reverse: true);
        break;
      case OllieState.celebrating:
        _ctrl.duration = const Duration(milliseconds: 600);
        _scaleAnim =
            Tween(begin: 1.0, end: 1.3).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
        );
        _rotateAnim = Tween(begin: 0.0, end: 0.0).animate(_ctrl);
        _ctrl.forward();
        break;
      case OllieState.confused:
        _ctrl.duration = const Duration(milliseconds: 500);
        _scaleAnim = Tween(begin: 1.0, end: 1.0).animate(_ctrl);
        _rotateAnim =
            Tween(begin: -0.15, end: 0.15).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
        );
        _ctrl.repeat(reverse: true);
        break;
    }
  }

  String get _emoji {
    switch (widget.state) {
      case OllieState.idle:
        return '🦉';
      case OllieState.reading:
        return '📖';
      case OllieState.celebrating:
        return '🎉';
      case OllieState.confused:
        return '🤔';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = _scaleAnim.value;
        final rotate = _rotateAnim.value;
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotate,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Text(
                  _emoji,
                  style: TextStyle(fontSize: widget.size * 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
