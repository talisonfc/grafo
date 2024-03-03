library grafo;

import 'package:flutter/material.dart';
import 'package:grafo/models/grafo_connection.dart';
import 'package:grafo/models/grafo_node.dart';
import 'package:grafo/widgets/grafo_board.dart';

export 'models/grafo_connection.dart';
export 'models/grafo_node.dart';

class Grafo extends StatefulWidget {
  const Grafo({super.key, this.grafo = const []});

  final List<GrafoNode> grafo;

  @override
  State<StatefulWidget> createState() => _GrafoState();
}

class _GrafoState extends State<Grafo> {
  List<GrafoNode> workflow = [
    GrafoNode(id: 0, name: 'name', position: const Offset(100, 100)),
    GrafoNode(
      id: 1,
      name: 'name',
      position: const Offset(300, 100),
    ),
    GrafoNode(
      id: 2,
      name: 'name',
      position: const Offset(500, 100),
    ),
  ];

  List<GrafoConnection> connections = [
    GrafoConnection(from: 0, to: 1),
    GrafoConnection(from: 1, to: 2)
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Flex(direction: Axis.horizontal, children: [
      Expanded(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                final selectedNodes =
                    workflow.where((node) => node.selected).toList();
                if (selectedNodes.length == 2) {
                  final from = workflow.indexOf(selectedNodes[0]);
                  final to = workflow.indexOf(selectedNodes[1]);

                  setState(() {
                    workflow[from].selected = false;
                    workflow[to].selected = false;
                    connections.add(GrafoConnection(from: from, to: to));
                  });
                }
              },
              child: const Text('Conectar')),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                final selectedNodes =
                    workflow.where((node) => node.selected).toList();
                if (selectedNodes.length == 2) {
                  final from = workflow.indexOf(selectedNodes[0]);
                  final to = workflow.indexOf(selectedNodes[1]);
                  setState(() {
                    workflow[from].selected = false;
                    workflow[to].selected = false;
                    connections.removeWhere((connection) =>
                        connection == GrafoConnection(from: from, to: to) ||
                        connection == GrafoConnection(from: to, to: from));
                  });
                }
              },
              child: const Text('Desconectar')),
          Expanded(child: components())
        ],
      )),
      Expanded(
        flex: 4,
        child: DragTarget<GrafoNode>(
          onAcceptWithDetails: (data) {
            final position =
                Offset(data.offset.dx - size.width * 0.1, data.offset.dy);
            workflow.add(
                data.data.copyWith(id: workflow.length, position: position));
          },
          builder: (context, candidateData, rejectedData) {
            return GrafoBoard(
              nodes: workflow,
              connections: connections,
              onAddConnection: (connection) {
                connections.add(connection);
              },
              onRemoveConnection: (index) {
                setState(() {
                  connections.removeAt(index);
                });
              },
              onMove: (index, delta) {
                setState(() {
                  workflow[index].position += delta;
                });
              },
              onTap: (index) {
                final node = workflow[index];
                setState(() {
                  node.selected = !node.selected;
                });
              },
            );
          },
        ),
      )
    ]);
  }

  Widget components() {
    return GridView.builder(
      itemCount: 2,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        final component = Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: const Center(
            child: Text('Component'),
          ),
        );
        return Draggable(
            data: GrafoNode(
              id: 20,
              name: 'name',
              position: const Offset(0, 0),
            ),
            feedback: Material(
              child: SizedBox(
                width: 100,
                height: 100,
                child: component,
              ),
            ),
            child: component);
      },
    );
  }
}
