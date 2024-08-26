import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';

bool isInsideEllipse(vector.Vector3 cameraPosition, vector.Vector3 p1, vector.Vector3 p2) {
  final double a = p1.distanceTo(p2) / 2; // Полуось эллипса по X
  final double b = a / 2; // Полуось эллипса по Z

  final vector.Vector3 center = (p1 + p2) * 0.5;
  final vector.Vector3 relativePosition = cameraPosition - center;

  final num distance = pow(relativePosition.x / a, 2) + pow(relativePosition.z / b, 2);

  return distance <= 1;
}

void rotateArrowFromCameraTowards(ARNode arrowNode, vector.Vector3 targetPosition, vector.Vector3 cameraPosition) {
  final direction = targetPosition - cameraPosition;
  direction.normalize();

  final angleY = atan2(direction.x, direction.z);
  final quaternion = vector.Quaternion.axisAngle(vector.Vector3(0, 1, 0), angleY);

  arrowNode.rotation = quaternion.asRotationMatrix();
}
