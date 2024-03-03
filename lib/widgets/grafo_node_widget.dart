import 'package:flutter/material.dart';
import 'package:grafo/core/grafo_event_hub.dart';
import 'package:grafo/core/grafo_state.dart';
import 'package:grafo/models/grafo_node.dart';

class GrafoNodeWidget extends StatefulWidget {
  const GrafoNodeWidget(
      {super.key,
      required this.index,
      required this.node,
      this.onTap,
      this.onMove,
      this.onHover});

  final int index;
  final GrafoNode node;
  final Function(int index)? onTap;
  final Function(int index, Offset delta)? onMove;
  final Function(int index, bool hover)? onHover;

  @override
  State<GrafoNodeWidget> createState() => _GrafoNodeWidgetState();
}

class _GrafoNodeWidgetState extends State<GrafoNodeWidget> {
  final size = const Size(100, 100);

  @override
  void initState() {
    super.initState();

    GrafoEventHub.subscribe(WorkflowTopic.pointerDown, (data) {
      final event = data.localPosition;
      final position = widget.node.position;
      final width = size.width;
      final height = size.height;
      if (position.dx < event.dx &&
          event.dx < position.dx + width &&
          position.dy < event.dy &&
          event.dy < position.dy + height) {
        GrafoState.pressedNodeIndex = widget.index;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.node.position.dx,
        top: widget.node.position.dy,
        child: MouseRegion(
          onEnter: (event) {
            widget.onHover?.call(widget.index, true);
          },
          onExit: (event) {
            widget.onHover?.call(widget.index, false);
          },
          child: InkWell(
            onTap: () {
              widget.onTap?.call(widget.node.id);
            },
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(
                  color: widget.node.selected ? Colors.red : Colors.black,
                  width: 2,
                ),
              ),
              child: Text('${widget.node.id}'),
            ),
          ),
        ));
  }
}
