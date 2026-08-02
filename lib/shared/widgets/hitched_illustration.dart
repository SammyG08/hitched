import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HitchedIllustration extends StatelessWidget {
  const HitchedIllustration({
    required this.asset,
    this.width,
    this.height,
    this.semanticLabel,
    super.key,
  });

  const HitchedIllustration.mark({
    this.width = 132,
    this.height = 88,
    this.semanticLabel = 'Interlocking wedding rings',
    super.key,
  }) : asset = 'assets/illustrations/hitched_mark.svg';

  final String asset;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      semanticsLabel: semanticLabel,
    );
  }
}
