import 'package:event_bus/event_bus.dart';

class EventBusService {
  static EventBus? _instance;

  EventBus getInstance() {
    _instance ??= EventBus(sync: true);
    return _instance!;
  }
}
