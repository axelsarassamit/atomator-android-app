import 'package:flutter/material.dart';

const atomatorLogoAccent = Color(0xFFDDFA00);

/// The approved Canva artwork, used without redrawing or recoloring the robot.
class AtomatorMark extends StatelessWidget {
  final double size;
  const AtomatorMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.18),
    child: Image.asset(
      'assets/images/app_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Atomator robot with lightning bolt',
    ),
  );
}

class AtomatorBrand extends StatelessWidget {
  final double markSize;
  final bool vertical;
  const AtomatorBrand({super.key, this.markSize = 64, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Atomator',
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: atomatorLogoAccent,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Remote Fleet Management',
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
    return vertical
        ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AtomatorMark(size: markSize),
            const SizedBox(height: 16),
            text,
          ],
        )
        : Row(
          children: [
            AtomatorMark(size: markSize),
            const SizedBox(width: 14),
            Expanded(child: text),
          ],
        );
  }
}
