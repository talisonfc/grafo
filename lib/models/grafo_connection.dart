class GrafoConnection {
  final int from;
  final int to;
  bool selected = false;

  GrafoConnection({required this.from, required this.to});

  @override
  int get hashCode => from.hashCode ^ to.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GrafoConnection && other.from == from && other.to == to;
  }
}
