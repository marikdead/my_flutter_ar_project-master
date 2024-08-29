import 'package:vector_math/vector_math_64.dart' as vector;

class ARObjectData {
  final String id;
  final String name;
  final String modelUri;
  final vector.Vector3 position;
  final String stepDescription;

  ARObjectData({
    required this.id,
    required this.name,
    required this.modelUri,
    required this.position,
    required this.stepDescription,
  });
}

class ARRouteConnection {
  final ARObjectData pointA;
  final ARObjectData pointB;
  final String forwardStep;
  final String backwardStep;

  ARRouteConnection({
    required this.pointA,
    required this.pointB,
    required this.forwardStep,
    required this.backwardStep,
  });

  bool contains(ARObjectData point) {
    return pointA == point || pointB == point;
  }

  ARObjectData getNextPoint(ARObjectData current) {
    if (current == pointA) return pointB;
    if (current == pointB) return pointA;
    throw ArgumentError('Точка не связана с данной связью');
  }

  String getStep(ARObjectData current) {
    if (current == pointA) return forwardStep;
    if (current == pointB) return backwardStep;
    throw ArgumentError('Точка не связана с данной связью');
  }
}
