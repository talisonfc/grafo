enum WorkflowTopic { mousePosition, pointerDown, pointerUp, pointerMove }

class GrafoEventHub {
  GrafoEventHub._();

  static int indexNodeFocused = -1;

  static final Map<WorkflowTopic, List<void Function(dynamic event)>>
      _subscribers = <WorkflowTopic, List<void Function(dynamic event)>>{};

  static void publish(WorkflowTopic topic, dynamic event) {
    if (_subscribers.containsKey(topic)) {
      for (final subscriber in _subscribers[topic] ?? []) {
        subscriber(event);
      }
    }
  }

  static void subscribe(
    WorkflowTopic topic,
    void Function(dynamic event) subscriber,
  ) {
    if (!_subscribers.containsKey(topic)) {
      _subscribers[topic] = <void Function(dynamic event)>[];
    }
    _subscribers[topic]!.add(subscriber);
  }

  static clean() {
    _subscribers.clear();
  }
}
