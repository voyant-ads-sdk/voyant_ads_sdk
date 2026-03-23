sealed class HeightConstraint {
  double get height;
}

class ExpandedHeightConstraint extends HeightConstraint {
  @override
  double get height => double.infinity;
}

class FixedHeightConstraint implements HeightConstraint {
  final double fixedHeight;
  FixedHeightConstraint(this.fixedHeight);

  @override
  double get height => fixedHeight;
}

class MaxHeightConstraint extends HeightConstraint {
  final double maxHeight;
  MaxHeightConstraint(this.maxHeight);

  @override
  double get height => maxHeight;
}
