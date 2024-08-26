import 'package:vector_math/vector_math_64.dart' as vector;
import 'ar_object_data.dart';

// Список точек маршрута с уникальными названиями
final List<ARObjectData> arRoutePoints = [
  ARObjectData(
    "https://jla.ovh/glb-jla.glb",
    vector.Vector3(0, 0, -2),
    "Поверни направо и пройди до следующей точки",
    name: "Точка A",
  ),
  ARObjectData(
    "https://jla.ovh/glb-jla.glb",
    vector.Vector3(1, 0, -3),
    "Теперь поверни налево",
    name: "Точка B",
  ),
  ARObjectData(
    "https://jla.ovh/glb-jla.glb",
    vector.Vector3(-1, 0, -4),
    "Двигайся прямо",
    name: "Точка C",
  ),
  ARObjectData(
    "https://jla.ovh/glb-jla.glb",
    vector.Vector3(2, 0, -5),
    "Теперь двигайся к следующей точке",
    name: "Точка D",
  ),
  ARObjectData(
    "https://jla.ovh/glb-jla.glb",
    vector.Vector3(-2, 0, -6),
    "Продолжай движение вперед",
    name: "Точка E",
  ),
];
