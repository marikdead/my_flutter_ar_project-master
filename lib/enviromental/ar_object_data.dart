import 'package:vector_math/vector_math_64.dart' as vector;

class ARObjectData {
  final String modelUri;
  final vector.Vector3 position;
  final String stepDescription;
  final String name; // Новое поле для названия объекта
  bool isTarget;

  ARObjectData(this.modelUri, this.position, this.stepDescription, {required this.name, this.isTarget = false});
}
