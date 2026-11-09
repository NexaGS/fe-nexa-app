import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme/nexa_text.dart';

class NexaLogo extends StatelessWidget {
  const NexaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoMark(),
        SizedBox(width: 10),
        Text('Nexa', style: NexaText.wordmark),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo_mark.svg',
      width: 32,
      height: 32,
      excludeFromSemantics: true,
    );
  }
}