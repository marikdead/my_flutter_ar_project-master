import 'dart:math';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:async';
import 'enviromental/ar_object_data.dart';
import 'enviromental/ar_helper.dart';
import 'enviromental/ar_route_points.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';

class AREnvironmentScreen extends StatefulWidget {
  final ARObjectData startPoint;
  final ARObjectData endPoint;

  AREnvironmentScreen({required this.startPoint, required this.endPoint});

  @override
  _AREnvironmentScreenState createState() => _AREnvironmentScreenState();
}

class _AREnvironmentScreenState extends State<AREnvironmentScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  List<ARNode> nodes = [];
  ARNode? userPointer; // Указатель пользователя (стрелка)
  ARNode? routeArrow; // Стрелка между точками
  Timer? updateTimer;
  String currentStep = "Начните движение к первой точке";
  bool isOffRoute = false;
  int currentTargetIndex = 0;

  late List<ARObjectData> routePoints;

  @override
  void initState() {
    super.initState();

    // Рассчитываем маршрут на основе начальной и конечной точки
    routePoints = _calculateRoute(widget.startPoint, widget.endPoint);

    // Инициализация AR
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _initializeAR();
    });
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Environment'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOffRoute
                    ? Colors.red.withOpacity(0.6)
                    : (currentTargetIndex >= routePoints.length)
                    ? Colors.green.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Текущий шаг',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    isOffRoute
                        ? "Вернитесь на маршрут"
                        : currentTargetIndex >= routePoints.length
                        ? "Маршрут завершён!"
                        : currentStep,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeAR() {
    _addObjectsToScene();
    _addUserPointer();

    updateTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateUserPointerAndRouteArrow();
    });
  }

  List<ARObjectData> _calculateRoute(ARObjectData start, ARObjectData end) {
    int startIndex = arRoutePoints.indexOf(start);
    int endIndex = arRoutePoints.indexOf(end);

    if (startIndex < endIndex) {
      return arRoutePoints.sublist(startIndex, endIndex + 1);
    } else {
      return arRoutePoints.sublist(endIndex, startIndex + 1).reversed.toList();
    }
  }

  void _onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager anchorManager, ARLocationManager locationManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      customPlaneTexturePath: null,
      showWorldOrigin: true,
      handleTaps: false,
    );

    arObjectManager.onInitialize();

    _initializeAR();
  }

  void _addObjectsToScene() async {
    for (ARObjectData objectData in routePoints) {
      final node = ARNode(
        type: NodeType.webGLB,
        uri: objectData.modelUri,
        scale: vector.Vector3(1, 1, 1),
        position: objectData.position,
      );
      if (await arObjectManager.addNode(node) != null) {
        nodes.add(node);
      }
    }
  }

  void _addUserPointer() async {
    final pointerPosition = vector.Vector3(0, -0.5, -1); // Указатель пользователя перед камерой

    userPointer = ARNode(
      type: NodeType.webGLB,
      uri: "https://jla.ovh/glb-jla.glb", // 3D модель указателя пользователя
      scale: vector.Vector3(0.5, 0.5, 0.5),
      position: pointerPosition,
    );

    await arObjectManager.addNode(userPointer!);
  }

  void _updateUserPointerAndRouteArrow() async {
    final Matrix4? cameraPose = await arSessionManager.getCameraPose();

    if (cameraPose == null) {
      return;
    }

    final vector.Vector3 cameraPosition = vector.Vector3(
      cameraPose.getColumn(3).x,
      cameraPose.getColumn(3).y,
      cameraPose.getColumn(3).z,
    );

    final vector.Vector3 pointerOffset = vector.Vector3(0, -0.3, -0.5);
    final vector.Vector3 newPointerPosition = cameraPosition + cameraPose.getRotation().transformed(pointerOffset);

    userPointer!.position = newPointerPosition;

    // Обновляем стрелку между текущей и следующей точкой
    if (currentTargetIndex < routePoints.length) {
      vector.Vector3 targetPosition = routePoints[currentTargetIndex].position;
      vector.Vector3? nextPosition;

      if (currentTargetIndex + 1 < routePoints.length) {
        nextPosition = routePoints[currentTargetIndex + 1].position;
      }

      _updateRouteArrow(targetPosition, nextPosition, cameraPosition);
    }
  }

  void _updateRouteArrow(vector.Vector3 targetPosition, vector.Vector3? nextPosition, vector.Vector3 cameraPosition) async {
    if (routeArrow != null) {
      await arObjectManager.removeNode(routeArrow!); // Удаляем предыдущую стрелку
    }

    if (nextPosition != null) {
      // Создаем стрелку между текущей и следующей точкой
      vector.Vector3 midPoint = (targetPosition + nextPosition) * 0.5;
      vector.Vector3 direction = nextPosition - targetPosition;
      double distance = direction.length;

      direction.normalize();

      routeArrow = ARNode(
        type: NodeType.webGLB,
        uri: "https://jla.ovh/glb-jla.glb", // 3D модель стрелки
        scale: vector.Vector3(0.1, 0.1, distance),
        position: midPoint,
        rotation: vector.Vector4(0, 1, 0, atan2(direction.x, direction.z)),
      );

      await arObjectManager.addNode(routeArrow!);
    }

    // Поворот указателя пользователя в сторону текущей цели
    rotateArrowFromCameraTowards(userPointer!, targetPosition, cameraPosition);

    // Проверка достижения текущей цели
    if (cameraPosition.distanceTo(targetPosition) < 0.5) {
      _moveToNextTarget();
    }
  }

  void _moveToNextTarget() {
    setState(() {
      currentTargetIndex++;
      if (currentTargetIndex < routePoints.length) {
        currentStep = routePoints[currentTargetIndex].stepDescription;
      } else {
        currentStep = "Маршрут завершён!";
        isOffRoute = false;
      }
    });
  }
}
