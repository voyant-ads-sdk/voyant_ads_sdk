/// Base abstraction for defining height behavior of ad media.
///
/// Used to control how media (image/video/carousel) expands
/// within layout constraints.
sealed class HeightConstraint {
  /// Returns the resolved height value.
  double get height;
}

/// Expands media to fill all available vertical space.
///
/// Useful for flexible layouts like feeds or scrollable views.
class ExpandedHeightConstraint extends HeightConstraint {
  @override
  double get height => double.infinity;
}

/// Uses a fixed height for media.
///
/// Ensures consistent layout regardless of content.
class FixedHeightConstraint implements HeightConstraint {
  /// Exact height value in pixels.
  final double fixedHeight;

  /// Creates a fixed height constraint.
  FixedHeightConstraint(this.fixedHeight);

  @override
  double get height => fixedHeight;
}

/// Limits media to a maximum height.
///
/// Media can shrink but will never exceed [maxHeight].
class MaxHeightConstraint extends HeightConstraint {
  /// Maximum allowed height in pixels.
  final double maxHeight;

  /// Creates a max height constraint.
  MaxHeightConstraint(this.maxHeight);

  @override
  double get height => maxHeight;
}
