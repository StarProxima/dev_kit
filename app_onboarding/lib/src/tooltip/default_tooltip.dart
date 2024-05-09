part of '../app_onboarding_entry.dart';

const _defaultHideAfterDuration = Duration(milliseconds: 5000);

class _DefaultAnimatedAutoTooltip extends StatefulWidget {
  const _DefaultAnimatedAutoTooltip({
    required this.settings,
    required this.appOnboardingState,
    this.hideAfterDuration,
  });

  final TooltipSettings settings;
  final AppOnboardingState appOnboardingState;
  final Duration? hideAfterDuration;

  @override
  State<StatefulWidget> createState() => _DefaultAnimatedAutoTooltipState();
}

class _DefaultAnimatedAutoTooltipState
    extends State<_DefaultAnimatedAutoTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final TooltipSettings settings;
  late final Animation<double> fadeTransition;
  late final Animation<double> scaleTransition;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final duration = widget.hideAfterDuration ??
        widget.settings.hideAfterDuration ??
        _defaultHideAfterDuration;
    animationController = AnimationController(
      vsync: this,
      duration: duration,
    )..forward();
    fadeTransition = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 1), weight: 4),
        TweenSequenceItem(tween: ConstantTween(1), weight: 92),
        TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 4),
      ],
    ).animate(animationController);
    scaleTransition = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 1), weight: 4),
        TweenSequenceItem(tween: ConstantTween(1), weight: 92),
        TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.2), weight: 4),
      ],
    ).animate(animationController);
    timer?.cancel();
    timer = Timer(
      duration,
      widget.appOnboardingState.showNext,
    );
    settings = widget.settings;
  }

  @override
  void dispose() {
    animationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = settings.backgroundColor ?? theme.primaryColor;
    final padding = settings.padding ??
        const EdgeInsets.only(
          top: 8,
          bottom: 12,
          left: 12,
          right: 12,
        );
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: fadeTransition,
        curve: Curves.easeIn,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: scaleTransition,
          curve: Curves.easeIn,
        ),
        child: AppOnboardingTooltip(
          direction: settings.tooltipDirection,
          backgroundColor: backgroundColor,
          arrowPosition: settings.arrowPosition,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        settings.tooltipText,
                        textAlign: TextAlign.start,
                        maxLines: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAnimatedTooltip extends StatefulWidget {
  const _DefaultAnimatedTooltip({
    required this.settings,
    required this.appOnboardingState,
  });

  final TooltipSettings settings;
  final AppOnboardingState appOnboardingState;

  @override
  State<_DefaultAnimatedTooltip> createState() =>
      _DefaultAnimatedTooltipState();
}

class _DefaultAnimatedTooltipState extends State<_DefaultAnimatedTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final TooltipSettings settings;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.5,
    )..forward();
    settings = widget.settings;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = settings.backgroundColor ?? theme.primaryColor;
    final padding = settings.padding ??
        const EdgeInsets.only(
          top: 8,
          bottom: 12,
          left: 12,
          right: 12,
        );
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeIn,
        ),
        child: AppOnboardingTooltip(
          direction: settings.tooltipDirection,
          backgroundColor: backgroundColor,
          arrowPosition: settings.arrowPosition,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        settings.tooltipText,
                        textAlign: TextAlign.start,
                        maxLines: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (settings.completeText != null)
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: ElevatedButton(
                            style: settings.completeButtonStyle,
                            onPressed: () {
                              settings.onCompleteTap?.call();
                              widget.appOnboardingState.startAutoHidden();
                            },
                            child: Text(
                              settings.completeText!,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: settings.skipButtonStyle,
                          onPressed: () {
                            settings.onSkipTap?.call();
                            widget.appOnboardingState.startAutoHidden();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(settings.skipText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton(
                          style: settings.nextButtonStyle,
                          onPressed: () async {
                            widget.appOnboardingState.hide();
                            await settings.onNextTap?.call();
                            widget.appOnboardingState.next();
                            widget.appOnboardingState.show();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${settings.nextText} '
                                '(${widget.appOnboardingState.currentIndex + 1}'
                                ' / '
                                '${widget.appOnboardingState.stepsLength - widget.appOnboardingState.countAutoHidden})',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter({
    required this.key,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final double borderRadius;
  final GlobalKey key;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 6.0;
    final paintBack = Paint()..color = backgroundColor;
    final path = Path()..addRect(Rect.largest);
    final rect = key.globalPaintBounds!;
    final a = rect.inflate(padding);
    final path2 = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          a,
          Radius.circular(borderRadius),
        ),
      );
    final resPath = Path.combine(PathOperation.difference, path, path2);
    canvas.drawPath(resPath, paintBack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension GlobalKeyEx on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject?.attached ?? false) {
      final translation = renderObject?.getTransformTo(null).getTranslation();
      if (translation != null && renderObject?.paintBounds != null) {
        return renderObject!.paintBounds;
      }
    }
    return null;
  }
}
