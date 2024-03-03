import 'package:flutter/material.dart';
import 'package:grafo/grafo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlowDemo(),
    );
  }
}

class FlowDemo extends StatelessWidget {
  const FlowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('workflow demo'),
      ),
      body: Center(
          child: Grafo(
        grafo: [
          GrafoNode(
              id: 0,
              name: 'createASession',
              position: const Offset(100, 100),
              size: const Size(100, 100),
              children: [
                GrafoNode(
                    id: 1,
                    name: 'isANewUser?',
                    position: const Offset(300, 120),
                    size: const Size(100, 100),
                    children: [
                      GrafoNode(
                          id: 2,
                          name: 'getUserInfoByPhone',
                          position: const Offset(500, 100),
                          size: const Size(100, 100),
                          children: [
                            GrafoNode(
                                id: 6,
                                position: const Offset(900, 300),
                                size: const Size(100, 100),
                                name: 'replyGreeting')
                          ]),
                      GrafoNode(
                          id: 3,
                          position: const Offset(500, 300),
                          size: const Size(100, 100),
                          name: 'extractUserInfo',
                          children: [
                            GrafoNode(
                                id: 4,
                                name: 'saveUserInfo',
                                position: const Offset(700, 100),
                                size: const Size(100, 100),
                                children: [
                                  GrafoNode(
                                      id: 5,
                                      position: const Offset(900, 100),
                                      size: const Size(100, 100),
                                      name: 'replyGreeting')
                                ]),
                          ])
                    ])
              ])
        ],
      )),
    );
  }
}
