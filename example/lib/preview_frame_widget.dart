import 'package:flutter/material.dart';

class PreviewFrameWidget extends StatelessWidget {
  final Widget child;
  final bool desktopVersion;

  const PreviewFrameWidget({
    super.key,
    required this.child,
    this.desktopVersion = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = 300;
      double height = 500;
      if (desktopVersion) {
        height = 700;
        width = 1000;
      }
      if (constraints.maxWidth < width) {
        width = constraints.maxWidth;
      }
      if (constraints.maxWidth < height) {
        height = constraints.maxWidth;
      }
      return UnconstrainedBox(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 8,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      );
    });
  }
}
