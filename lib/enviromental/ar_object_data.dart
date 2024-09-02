import 'package:vector_math/vector_math_64.dart' as vector;

class ARObjectData {
  final String id;
  final String name;
  final String modelUri;
  final vector.Vector3 position;
  String? stepDescription; // Изменено на nullable, чтобы избежать LateInitializationError

  ARObjectData({
    required this.id,
    required this.name,
    required this.modelUri,
    required this.position,
    this.stepDescription,
  });

  void setStepDescription(String description) {
    stepDescription = description;
  }
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
    return point == pointA || point == pointB;
  }

  bool connects(ARObjectData a, ARObjectData b) {
    return (a == pointA && b == pointB) || (a == pointB && b == pointA);
  }

  ARObjectData getNextPoint(ARObjectData current) {
    if (current == pointA) {
      return pointB;
    } else {
      return pointA;
    }
  }

  String getStep(ARObjectData from, ARObjectData to) {
    if (from == pointA && to == pointB) {
      return forwardStep;
    } else if (from == pointB && to == pointA) {
      return backwardStep;
    }
    return '';
  }
}

class PathResult {
  final List<ARObjectData> points;
  final List<ARRouteConnection> connections;

  PathResult({required this.points, required this.connections});
}


