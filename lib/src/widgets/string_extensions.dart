extension CustomStringExtensions on String {
  int get getIntValue {
    return getDoubleValue.toInt();
  }

  double get getDoubleValue {
    var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");
    List<double> temp = doubleRE.allMatches(this).map((RegExpMatch m) {
      return double.parse(m[0]!);
    }).toList();
    if (temp.isEmpty) {
      return 0.0;
    } else {
      return temp.first;
    }
  }
}
