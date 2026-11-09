
import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NexaButtonVariant { primary, outline, text}

class NexaButton extends StatelessWidget {
  const NexaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NexaButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final NexaButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      NexaButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: NexaColors.lime,
          foregroundColor: NexaColors.ink,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: NexaText.bodyStrong,
        ),
        child: Text(label),
      ),
    NexaButtonVariant.outline => OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: NexaColors.white,
        foregroundColor: NexaColors.ink,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        side: const BorderSide(color: NexaColors.outline),
        textStyle: NexaText.bodyStrong,
      ),
      child: Text(label),
    ),
      NexaButtonVariant.text => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: NexaColors.ink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: NexaText.bodyStrong.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
        child: Text(label),
      ),
    };
  }
}