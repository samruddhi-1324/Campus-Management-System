import 'package:flutter/material.dart';

enum ScreenSizeClass {
  compact,  // < 600 dp (Mobile portrait)
  medium,   // 600 - 1024 dp (Tablet, small window, split screen)
  expanded, // > 1024 dp (Desktop, laptop, maximized browser)
}

class AdaptiveLayoutHelper {
  static ScreenSizeClass getScreenSizeClass(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSizeClass.compact;
    } else if (width <= 1024) {
      return ScreenSizeClass.medium;
    } else {
      return ScreenSizeClass.expanded;
    }
  }

  static bool isCompact(BuildContext context) =>
      getScreenSizeClass(context) == ScreenSizeClass.compact;

  static bool isMedium(BuildContext context) =>
      getScreenSizeClass(context) == ScreenSizeClass.medium;

  static bool isExpanded(BuildContext context) =>
      getScreenSizeClass(context) == ScreenSizeClass.expanded;
}

class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context) expanded;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.compact,
    this.medium,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final sizeClass = AdaptiveLayoutHelper.getScreenSizeClass(context);
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return compact(context);
      case ScreenSizeClass.medium:
        return (medium ?? expanded)(context);
      case ScreenSizeClass.expanded:
        return expanded(context);
    }
  }
}
