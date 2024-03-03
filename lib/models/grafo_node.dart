import 'dart:ui';

class GrafoNode {
  final int id;
  final String? name;
  Offset position;
  final Size size;
  bool selected;

  GrafoNode(
      {this.id = 0,
      this.name,
      List<GrafoNode>? children,
      this.selected = false,
      this.position = const Offset(0, 0),
      this.size = const Size(100, 100)});

  @override
  String toString() {
    return '$id';
  }

  GrafoNode copyWith(
      {int? id, Offset? position, String? name, Size? size, bool? selected}) {
    return GrafoNode(
        id: id ?? this.id,
        name: name ?? this.name,
        size: size ?? this.size,
        selected: selected ?? this.selected,
        position: position ?? this.position);
  }

  Offset get centerPosition {
    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }
}
