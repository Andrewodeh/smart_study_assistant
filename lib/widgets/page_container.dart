import 'package:flutter/material.dart';

/// Centers page content with a max width on large screens.
///
/// Uses LayoutBuilder so that tight height constraints flow through
/// correctly — this means Column + Expanded children work inside it.
/// On screens narrower than [maxWidth], adds 24 px horizontal padding.
/// On wider screens, adds symmetric margins to cap the content at [maxWidth].
class PageContainer extends StatelessWidget {
  final Widget child;

  /// Maximum content width before horizontal margins kick in.
  final double maxWidth;

  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double hPad = constraints.maxWidth > maxWidth
            ? (constraints.maxWidth - maxWidth) / 2.0
            : 16.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 12),
          child: child,
        );
      },
    );
  }
}
