import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A persistent, draggable floating debug button that gives 1-tap access to
/// the Chucker HTTP Inspector across every screen in the application.
///
/// Features:
/// - Always visible across all routes, bottom tabs, and dialogs in debug mode.
/// - Fully draggable with touch/pointer tracking.
/// - Automatically snaps smoothly to the nearest screen edge on release.
/// - Safe-area and screen-boundary aware (never clips outside viewport).
/// - Emerald Green RentBD branded aesthetics with active HTTP pulse indicator.
class ChuckerFloatingButton extends StatefulWidget {
  const ChuckerFloatingButton({
    super.key,
    required this.child,
    this.enabled,
    this.onTapOverride,
  });

  /// The root child widget (typically the app Navigator/Router).
  final Widget? child;

  /// Optional override to enable/disable the button.
  /// If null, defaults to [showFloatingButton] && ([kDebugMode] || [ChuckerFlutter.showOnRelease]).
  final bool? enabled;

  /// Optional callback to override the default tap behavior (used for testing).
  final VoidCallback? onTapOverride;

  /// Global toggle allowing programmatic enable/disable of the floating debug button.
  static bool showFloatingButton = true;

  @override
  State<ChuckerFloatingButton> createState() => _ChuckerFloatingButtonState();
}

class _ChuckerFloatingButtonState extends State<ChuckerFloatingButton>
    with SingleTickerProviderStateMixin {
  static const double _buttonSize = 54.0;
  static const double _edgePadding = 12.0;

  Offset? _position;
  bool _isDragging = false;
  double _panDistance = 0.0;

  AnimationController? _snapController;
  Animation<Offset>? _snapAnimation;

  bool get _isEnabled {
    return widget.enabled ??
        (ChuckerFloatingButton.showFloatingButton &&
            (kDebugMode || ChuckerFlutter.showOnRelease));
  }

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (_snapAnimation != null) {
          setState(() {
            _position = _snapAnimation!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _snapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position == null) {
      final media = MediaQuery.of(context);
      final size = media.size;
      // Initial placement: middle-right side of the screen
      final initialX = size.width - _buttonSize - _edgePadding;
      final initialY = (size.height * 0.42).clamp(
        media.padding.top + _edgePadding,
        size.height - _buttonSize - media.padding.bottom - _edgePadding,
      );
      _position = Offset(initialX, initialY);
    }
  }

  Offset _clampToScreen(Offset pos, Size size, EdgeInsets padding) {
    final minX = padding.left + _edgePadding;
    final maxX = size.width - _buttonSize - padding.right - _edgePadding;
    final minY = padding.top + _edgePadding;
    final maxY = size.height - _buttonSize - padding.bottom - _edgePadding;

    final clampedX = pos.dx.clamp(minX, maxX < minX ? minX : maxX);
    final clampedY = pos.dy.clamp(minY, maxY < minY ? minY : maxY);
    return Offset(clampedX, clampedY);
  }

  void _snapToNearestEdge(Size size, EdgeInsets padding) {
    if (_position == null) return;
    final currentPos = _clampToScreen(_position!, size, padding);
    final minX = padding.left + _edgePadding;
    final maxX = size.width - _buttonSize - padding.right - _edgePadding;

    final targetX = (currentPos.dx < size.width / 2) ? minX : maxX;
    final targetPos = Offset(targetX, currentPos.dy);

    _snapAnimation = Tween<Offset>(
      begin: currentPos,
      end: targetPos,
    ).animate(
      CurvedAnimation(
        parent: _snapController!,
        curve: Curves.easeOutBack,
      ),
    );

    _snapController!.forward(from: 0.0);
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (widget.onTapOverride != null) {
      widget.onTapOverride!();
    } else {
      ChuckerFlutter.showChuckerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseChild = widget.child ?? const SizedBox.shrink();

    if (!_isEnabled) {
      return baseChild;
    }

    final media = MediaQuery.of(context);
    final size = media.size;
    final padding = media.padding;

    // Safety fallback position if somehow not initialized
    final effectivePosition = _position != null
        ? _clampToScreen(_position!, size, padding)
        : Offset(size.width - _buttonSize - _edgePadding, size.height * 0.42);

    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          baseChild,
          Positioned(
            left: effectivePosition.dx,
            top: effectivePosition.dy,
            child: _buildDraggableButton(context, size, padding),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableButton(
    BuildContext context,
    Size size,
    EdgeInsets padding,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onPanStart: (details) {
        _snapController?.stop();
        _panDistance = 0.0;
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        _panDistance += details.delta.distance;
        setState(() {
          final current = _position ?? Offset.zero;
          _position = _clampToScreen(
            current + details.delta,
            size,
            padding,
          );
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
        });
        if (_panDistance >= 10.0) {
          _snapToNearestEdge(size, padding);
        }
      },
      onPanCancel: () {
        setState(() {
          _isDragging = false;
        });
        _snapToNearestEdge(size, padding);
      },
      child: Semantics(
        label: 'Chucker HTTP Inspector (Tap to open, drag to move)',
        button: true,
        child: AnimatedScale(
          scale: _isDragging ? 1.10 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            key: const Key('chucker_floating_debug_button'),
            width: _buttonSize,
            height: _buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E293B), // Slate 800
                ],
              ),
              border: Border.all(
                color: AppColors.primaryLight,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.40),
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.wifi_tethering_rounded,
                      color: Color(0xFF34D399),
                      size: 20,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'API',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                // Active green pulse indicator in top-right
                Positioned(
                  top: 7,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.7),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
