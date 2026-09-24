import 'package:flutter/material.dart';

/// A single swipe-revealed action.
///
/// Shared by the internal swipe primitive and every widget built on top of it
/// (e.g. `StarryMessageList` rows and `StarrySlidableDrawer`). This is the
/// public contract callers pass to describe trailing swipe actions.
class StarrySwipeAction {
  const StarrySwipeAction({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
}
