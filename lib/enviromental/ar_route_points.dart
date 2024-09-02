import 'dart:collection';
import 'ar_object_data.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// Определение всех точек маршрута
List<ARObjectData> arRoutePoints = [
  ARObjectData(
    id: 'point1',
    name: 'Въезд',
    modelUri: 'http://127.0.0.1:8080/map_pointer.glb',
    position: vector.Vector3(0, -0.5, -1),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point2',
    name: 'Центральная линия (Въезд)',
    modelUri: 'http://127.0.0.1:8080/map_pointer.glb',
    position: vector.Vector3(0, -0.5, -9),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point3',
    name: 'Крайний левый блок мест',
    modelUri: 'http://127.0.0.1:8080/map_pointer.glb',
    position: vector.Vector3(-12, -0.5, -9),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point4',
    name: 'Место 279',
    modelUri: 'http://127.0.0.1:8080/map_pointer.glb',
    position: vector.Vector3(-17, -0.5, -14),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point5',
    name: 'Точка 5',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(1, 0, 0),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point6',
    name: 'Точка 6',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(2, 0, 0),
    stepDescription: '',
  ),ARObjectData(
    id: 'point7',
    name: 'Точка 7',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(0, 0, 1),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point8',
    name: 'Точка 8',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(0, 0, 2),
    stepDescription: '',
  ),
  ARObjectData(
    id: 'point9',
    name: 'Точка 9',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(0, 0, 3),
    stepDescription: '',
  ),

];


List<ARRouteConnection> arRouteConnections = [
  ARRouteConnection(
    pointA: arRoutePoints[0],
    pointB: arRoutePoints[1],
    forwardStep: "Идите от точки 2 к точке 1",
    backwardStep: "Пройдите вперед",
  ),
  ARRouteConnection(
    pointA: arRoutePoints[1],
    pointB: arRoutePoints[2],
    forwardStep: "Идите от точки 3 к точке 2",
    backwardStep: "Поверните налево и пройдите до следующей метки",
  ),
  ARRouteConnection(
    pointA: arRoutePoints[1],
    pointB: arRoutePoints[4],
    forwardStep: "Идите от точки 5 к точке 2",
    backwardStep: "Идите от точки 2 к точке 5",
  ),
  ARRouteConnection(
    pointA: arRoutePoints[2],
    pointB: arRoutePoints[3],
    forwardStep: "Идите от точки 3 к точке 2",
    backwardStep: "Поверните направо",
  ),
  
];

// Функция для поиска кратчайшего пути между двумя точками с включением отладки
List<ARObjectData> findShortestPath(ARObjectData start, ARObjectData end, {Function(String)? log}) {
  Map<ARObjectData, ARObjectData?> previousPoints = {};
  Queue<ARObjectData> queue = Queue<ARObjectData>();
  queue.add(start);
  previousPoints[start] = null;

  if (log != null) log('Начало поиска пути от ${start.name} до ${end.name}');

  while (queue.isNotEmpty) {
    ARObjectData? current = queue.removeFirst();

    if (current == end) {
      List<ARObjectData> path = [];
      while (current != null) {
        path.add(current);
        current = previousPoints[current];
      }
      if (log != null) log('Путь найден: ${path.map((p) => p.name).join(' -> ')}');
      return _assignStepsToPath(path.reversed.toList());
    }

    if (log != null) log('Обработка точки ${current.name}');

    for (ARRouteConnection connection in arRouteConnections) {
      if (connection.contains(current)) {
        ARObjectData next = connection.getNextPoint(current);
        if (!previousPoints.containsKey(next)) {
          queue.add(next);
          previousPoints[next] = current;
          if (log != null) log('Добавление точки ${next.name} в очередь');
        }
      }
    }
  }

  if (log != null) log('Путь не найден');
  return []; // Если путь не найден
}

// Функция для добавления шага в существующую точку с условием связи
List<ARObjectData> _assignStepsToPath(List<ARObjectData> path) {
  for (int i = 0; i < path.length - 1; i++) {
    ARObjectData current = path[i];
    ARObjectData next = path[i + 1];

    for (ARRouteConnection connection in arRouteConnections) {
      if (connection.connects(current, next)) {
        if (current.stepDescription!.isEmpty) {
          current.setStepDescription(connection.getStep(current, next));
        }
        if (next.stepDescription!.isEmpty) {
          next.setStepDescription(connection.getStep(next, current));
        }
        break;
      }
    }
  }
  return path;
}
