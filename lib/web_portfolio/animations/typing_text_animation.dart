import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// Cycles through a list of strings with a realistic typing and deleting animation.
class TypingTextAnimation extends StatefulWidget {
  final List<String> texts;
  final TextStyle textStyle;
  final Duration typingSpeed;
  final Duration deletingSpeed;
  final Duration pauseDuration;

  const TypingTextAnimation({
    super.key,
    required this.texts,
    required this.textStyle,
    this.typingSpeed = const Duration(milliseconds: 70),
    this.deletingSpeed = const Duration(milliseconds: 35),
    this.pauseDuration = const Duration(milliseconds: 1600),
  });

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation> {
  int _currentTextIndex = 0;
  String _displayedText = '';
  bool _isDeleting = false;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
    _startTyping();
  }

  void _startTyping() {
    if (widget.texts.isEmpty) return;
    final currentFullText = widget.texts[_currentTextIndex];

    if (!_isDeleting) {
      if (_displayedText.length < currentFullText.length) {
        _timer?.cancel();
        _timer = Timer(widget.typingSpeed, () {
          if (mounted) {
            setState(() {
              _displayedText = currentFullText.substring(0, _displayedText.length + 1);
            });
            _startTyping();
          }
        });
      } else {
        // Paused at full text before deleting
        _timer?.cancel();
        _timer = Timer(widget.pauseDuration, () {
          if (mounted) {
            setState(() {
              _isDeleting = true;
            });
            _startTyping();
          }
        });
      }
    } else {
      if (_displayedText.isNotEmpty) {
        _timer?.cancel();
        _timer = Timer(widget.deletingSpeed, () {
          if (mounted) {
            setState(() {
              _displayedText = _displayedText.substring(0, _displayedText.length - 1);
            });
            _startTyping();
          }
        });
      } else {
        // Moved to next word
        _isDeleting = false;
        _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) _startTyping();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            _displayedText,
            style: widget.textStyle,
          ),
        ),
        AnimatedOpacity(
          opacity: _showCursor ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            width: 3,
            height: (widget.textStyle.fontSize ?? 24) * 0.9,
            decoration: BoxDecoration(
              color: WebColors.primaryLight,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: WebColors.primaryLight.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
