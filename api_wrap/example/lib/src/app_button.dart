import 'dart:async';

import 'package:flutter/material.dart';

class _AnimationMaterialStatesController extends MaterialStatesController {
  _AnimationMaterialStatesController({
    required this.animationController,
    required this.checkMounted,
  });

  final AnimationController animationController;
  final bool Function() checkMounted;

  @override
  void update(MaterialState state, bool add) {
    if (state == MaterialState.pressed) {
      if (add) {
        animationController.reverse();
      } else {
        if (animationController.isAnimating) {
          final milliseconds = animationController.value *
              (animationController.duration?.inMilliseconds ?? 0);
          Future.delayed(
            Duration(milliseconds: milliseconds.toInt()),
            () {
              if (!checkMounted()) return;
              animationController.forward();
            },
          );
        } else {
          animationController.forward();
        }
      }
    }
    super.update(state, add);
  }
}

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.isExtended = false,
    this.showLoading = true,
    this.allowTapDuringLoading = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.isElevated = false,
    this.isSmall = false,
    this.invertColors = false,
    this.underlineText = false,
    this.leftIcon,
    this.textColor,
    this.backgroundColor,
  });

  final String text;
  final FutureOr Function()? onTap;
  final bool isExtended;
  final bool showLoading;
  final bool allowTapDuringLoading;
  final bool isLoading;
  final bool isDisabled;
  final bool isElevated;
  final bool isSmall;
  final bool invertColors;
  final bool underlineText;
  final Color? textColor;
  final Color? backgroundColor;

  final Widget? leftIcon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !widget.isDisabled &&
              widget.onTap != null &&
              (!isLoading || widget.allowTapDuringLoading) &&
              !widget.isLoading
          ? () async {
              if (isLoading && !widget.allowTapDuringLoading) return;
              setState(() => isLoading = true);
              try {
                await widget.onTap!();
              } catch (_) {
                rethrow;
              } finally {
                if (context.mounted) setState(() => isLoading = false);
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: widget.isExtended ? const Size.fromHeight(0) : null,
        foregroundColor: widget.textColor,
        disabledForegroundColor: widget.textColor?.withOpacity(0.3),
        backgroundColor: widget.backgroundColor,
        disabledBackgroundColor: widget.backgroundColor?.withOpacity(0.3),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: widget.isSmall ? 6 : 14,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: (isLoading && widget.showLoading) || widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leftIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: widget.leftIcon,
                      ),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
