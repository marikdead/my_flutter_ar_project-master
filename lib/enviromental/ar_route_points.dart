import 'dart:collection';
import 'ar_object_data.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// Определение всех точек маршрута
List<ARObjectData> arRoutePoints = [
  ARObjectData(
    id: 'point1',
    name: 'Точка 1',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(0, 0, 0),
    stepDescription: 'Идите к точке 1',
  ),
  ARObjectData(
    id: 'point2',
    name: 'Точка 2',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(1, 0, 0),
    stepDescription: 'Идите к точке 2',
  ),
  ARObjectData(
    id: 'point3',
    name: 'Точка 3',
    modelUri: 'https://jla.ovh/glb-jla.glb',
    position: vector.Vector3(2, 0, 0),
    stepDescription: 'Идите к точке 3',
  ),
  // Добавьте остальные точки
];

// Определение связей между точками
List<ARRouteConnection> arRouteConnections = [
  ARRouteConnection(
    pointA: arRoutePoints[0],
    pointB: arRoutePoints[1],
    forwardStep: "Идите от точки 1 к точке 2",
    backwardStep: "Идите от точки 2 к точке 1",
  ),
  ARRouteConnection(
    pointA: arRoutePoints[1],
    pointB: arRoutePoints[2],
    forwardStep: "Идите от точки 2 к точке 3",
    backwardStep: "Идите от точки 3 к точке 2",
  ),
  // Добавьте остальные связи между точками
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
      return path.reversed.toList();
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
