library flow;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grafo/core/grafo_event_hub.dart';
import 'package:grafo/core/grafo_helper.dart';
import 'package:grafo/core/grafo_state.dart';
import 'package:grafo/models/grafo_connection.dart';
import 'package:grafo/models/grafo_node.dart';
import 'package:grafo/widgets/grafo_connection_painter.dart';
import 'package:grafo/widgets/grafo_node_widget.dart';

class GrafoBoard extends StatefulWidget {
  const GrafoBoard(
      {super.key,
      this.nodes = const [],
      this.connections = const [],
      this.onTap,
      this.onMove,
      this.onAddConnection,
      this.onRemoveConnection});

  final List<GrafoNode> nodes;
  final List<GrafoConnection> connections;
  final Function(int index)? onTap;
  final Function(int index, Offset delta)? onMove;
  final Function(GrafoConnection)? onAddConnection;
  final Function(int index)? onRemoveConnection;

  @override
  State<StatefulWidget> createState() => _GrafoBoardState();
}

class _GrafoBoardState extends State<GrafoBoard> {
  bool isPressed = false;
  bool showConnector = false;
  int? nodeStartIndex, nodeEndIndex;
  int? nearestNodeIndex;
  double? nearestPointerDist;
  Offset? mousePosition;
  int? nearestConnectionIndex;
  double? nearestConnectionDist;

  @override
  void initState() {
    super.initState();
  }

  (double, double, double, double, Offset, Offset) position(
      Offset from, Offset to) {
    final width = (to.dx - from.dx).abs();
    final height = (to.dy - from.dy).abs();
    late double top;
    late double left;
    Offset start = Offset.zero;
    Offset end = Offset.zero;

    top = from.dy < to.dy ? from.dy : top = to.dy;
    left = from.dx < to.dx ? from.dx : to.dx;

    final dir = Offset(to.dx - from.dx, to.dy - from.dy);
    if (dir.dx > 0 && dir.dy > 0) {
      end = Offset(width, height);
    } else if (dir.dx > 0 && dir.dy < 0) {
      start = Offset(0, height);
      end = Offset(width, 0);
    } else if (dir.dx < 0 && dir.dy > 0) {
      start = Offset(width, 0);
      end = Offset(0, height);
    } else {
      start = Offset(width, height);
    }
    return (top, left, width, height, start, end);
  }

  (int, double) findNearestNode(Offset localPosition) {
    final tmp = [];
    for (int i = 0; i < widget.nodes.length; i++) {
      tmp.add({
        'index': i,
        'dist':
            GrafoHelper.distance(localPosition, widget.nodes[i].centerPosition)
      });
    }
    tmp.sort((a, b) => a['dist'].compareTo(b['dist']));
    final index = tmp.first['index'];
    final dist = tmp.first['dist'];
    return (index, dist);
  }

  (int, double) findNearstLine(Offset localPosition) {
    final tmp = [];
    for (int i = 0; i < widget.connections.length; i++) {
      final from = widget.nodes[widget.connections[i].from].centerPosition;
      final to = widget.nodes[widget.connections[i].to].centerPosition;
      final dist = distPointToLine(localPosition, from, to);
      tmp.add({'index': i, 'dist': dist});
    }
    tmp.sort((a, b) => a['dist'].compareTo(b['dist']));
    final index = tmp.first['index'];
    final dist = tmp.first['dist'];
    return (index, dist);
  }

  (double, double) coeficients(Offset start, Offset end) {
    final a = (end.dy - start.dy) / (end.dx - start.dx);
    final b = start.dy - a * start.dx;
    return (a, b);
  }

  double distPointToLine(Offset point, Offset start, Offset end) {
    final (a, b) = coeficients(start, end);
    final dist = (a * point.dx - point.dy + b).abs() / sqrt(a * a + b * b);
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            LogicalKeyboardKey.delete == event.logicalKey) {
          if (nearestConnectionIndex != null) {
            widget.onRemoveConnection?.call(nearestConnectionIndex!);
          }
        }
        return KeyEventResult.handled;
      },
      child: Listener(
        onPointerDown: (event) {
          GrafoEventHub.publish(WorkflowTopic.pointerDown, event);
          isPressed = true;
          if (nearestConnectionIndex != null) {
            widget.connections[nearestConnectionIndex!].selected = true;
          }
        },
        onPointerUp: (event) {
          isPressed = false;
          GrafoState.pressedNodeIndex = null;
        },
        onPointerSignal: (event) {},
        onPointerHover: (event) {
          final localPosition = event.localPosition;
          final (indexNode, distToNode) = findNearestNode(localPosition);
          if (distToNode > 100) {
            setState(() {
              nearestNodeIndex = null;
            });
          } else if (nearestNodeIndex != indexNode && distToNode < 100) {
            setState(() {
              nearestNodeIndex = indexNode;
              nearestPointerDist = distToNode;
            });
          }

          final (indexLine, distToLine) = findNearstLine(localPosition);

          if (distToLine < 0.05) {
            setState(() {
              nearestConnectionIndex = indexLine;
              nearestConnectionDist = distToLine;
            });
          } else {
            if (nearestConnectionIndex != null) {
              setState(() {
                nearestConnectionIndex = null;
                nearestConnectionDist = null;
              });
            }
          }
        },
        onPointerMove: (event) {
          setState(() {
            mousePosition = event.localPosition;
          });
          if (GrafoState.pressedNodeIndex != null) {
            widget.onMove!(GrafoState.pressedNodeIndex!, event.delta);
          }
          GrafoEventHub.publish(WorkflowTopic.mousePosition, event);
        },
        child: MouseRegion(
          // cursor: isPressed ? SystemMouseCursors.grab : MouseCursor.defer,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                ...widget.connections.asMap().map((index, connection) {
                  final from = widget.nodes[connection.from].centerPosition;
                  final to = widget.nodes[connection.to].centerPosition;

                  final (top, left, width, height, start, end) =
                      position(from, to);

                  return MapEntry(
                      index,
                      Positioned(
                          top: top,
                          left: left,
                          width: width,
                          height: height,
                          child: CustomPaint(
                            painter: GrafoConnectionPainer(
                                isHover: index == nearestConnectionIndex,
                                isSelected: connection.selected,
                                showBoundary: false,
                                start: start,
                                end: end),
                          )));
                }).values,
                ...widget.nodes
                    .asMap()
                    .map((index, node) => MapEntry(
                        index,
                        GrafoNodeWidget(
                            index: index,
                            node: node,
                            onMove: widget.onMove,
                            onHover: (index, hover) {
                              if (hover) {}
                            },
                            onTap: (id) {
                              widget.onTap!(index);
                            })))
                    .values,
                if (showConnector &&
                    nearestNodeIndex != null &&
                    mousePosition != null)
                  Builder(builder: (context) {
                    final (top, left, width, height, start, end) = position(
                        widget.nodes[nearestNodeIndex!].centerPosition,
                        mousePosition!);

                    return Positioned(
                      top: top,
                      left: left,
                      width: width,
                      height: height,
                      child: CustomPaint(
                        painter: GrafoConnectionPainer(
                            showBoundary: true, start: start, end: end),
                      ),
                    );
                  }),
                if (nearestNodeIndex != null)
                  Positioned(
                      top: widget.nodes[nearestNodeIndex!].position.dy - 50,
                      left: widget.nodes[nearestNodeIndex!].position.dx - 50,
                      width: widget.nodes[nearestNodeIndex!].size.width + 100,
                      height: widget.nodes[nearestNodeIndex!].size.height + 100,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 50 - 12,
                              child: Listener(
                                child: const Icon(Icons.arrow_upward_rounded),
                                onPointerDown: (event) {
                                  setState(() {
                                    nodeStartIndex = nearestNodeIndex;
                                    showConnector = true;
                                  });
                                },
                                onPointerMove: (event) {
                                  if (mousePosition != null) {
                                    final (index, _) =
                                        findNearestNode(mousePosition!);
                                    if (nodeStartIndex != index) {
                                      nodeEndIndex = index;
                                    }
                                  }
                                },
                                onPointerUp: (event) {
                                  if (nodeEndIndex != nodeStartIndex) {
                                    widget.onAddConnection!(GrafoConnection(
                                        from: nodeStartIndex!,
                                        to: nodeEndIndex!));
                                  }
                                  setState(() {
                                    nodeStartIndex = null;
                                    showConnector = false;
                                  });
                                },
                              )),
                          Positioned(
                              top: 50 - 12,
                              child: IconButton(
                                  icon: const Icon(Icons.arrow_back_outlined),
                                  onPressed: startCreateConnection)),
                          Positioned(
                              top: 50 - 12,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded),
                                onPressed: startCreateConnection,
                              )),
                          Positioned(
                              bottom: 0,
                              left: 50 - 12,
                              child: IconButton(
                                  icon:
                                      const Icon(Icons.arrow_downward_outlined),
                                  onPressed: startCreateConnection)),
                        ],
                      ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void startCreateConnection() {
    // print('start create');
  }
}
