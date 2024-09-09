import 'dart:async';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'enviromental/ar_helper.dart';
import 'enviromental/ar_object_data.dart';
import 'dart:math';

class AREnvironmentScreen extends StatefulWidget {
  final List<ARObjectData> routePoints;

  AREnvironmentScreen({required this.routePoints});

  @override
  _AREnvironmentScreenState createState() => _AREnvironmentScreenState();
}

class _AREnvironmentScreenState extends State<AREnvironmentScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  List<ARNode> nodes = [];
  ARNode? userPointer; // Указатель пользователя (стрелка)
  Timer? updateTimer;
  String currentStep = "Начните движение к первой точке";
  bool isOffRoute = false;
  int currentTargetIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                    : (currentTargetIndex >= widget.routePoints.length)
                    ? Colors.green.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Текущий шаг',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    isOffRoute
                        ? "Вернитесь на маршрут"
                        : currentTargetIndex >= widget.routePoints.length
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

  void _onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      showAnimatedGuide: false,
      handleTaps: false,
    );

    arObjectManager.onInitialize();

    _initializeAR();
  }

  void _addObjectsToScene() async {
    for (int i = 0; i < widget.routePoints.length; i++) {
      ARObjectData objectData = widget.routePoints[i];

      // Определяем модель и масштаб в зависимости от того, является ли точка последней
      String modelUri;
      vector.Vector3 scale;
      if (i == widget.routePoints.length - 1) {
        // Для последней точки
        modelUri = objectData.modelUri;
        scale = vector.Vector3(0.05, 0.05, 0.05);  // Размер последней точки
      } else {
        // Для всех точек, кроме последней
        modelUri = "http://127.0.0.1:8080/arrow_point.glb";
        scale = vector.Vector3(0.1, 0.1, 0.1);  // Увеличенный размер для промежуточных точек
      }

      // Создание узла
      ARNode node = ARNode(
        type: NodeType.webGLB,
        uri: modelUri,
        scale: scale,
        position: objectData.position,
      );

      // Добавляем узел в сцену и сохраняем его, если успешно добавлен
      if (await arObjectManager.addNode(node) != null) {
        nodes.add(node);

        // Поворачиваем узел в сторону следующей точки, если это не последняя точка
        if (i < widget.routePoints.length - 1) {
          vector.Vector3 nextPosition = widget.routePoints[i + 1].position;
          _rotateNodeTowards(node, nextPosition);
        }
      }
    }
  }

  void _rotateNodeTowards(ARNode node, vector.Vector3 targetPosition) {
    // Определяем направление на следующую точку
    vector.Vector3 direction = targetPosition - node.position!;
    direction.normalize();

    // Вычисление углов для каждой оси
    double angleY = atan2(direction.y, sqrt(direction.x * direction.x + direction.z * direction.z));  // Угол по оси Y
    double angleX = atan2(direction.x, direction.z) - (pi / 2);  // Угол по оси X + 90 градусов

    // Установка поворота по всем осям (X и Y)
    node.eulerAngles = vector.Vector3(angleX, angleY, 0);  // Z-угол оставляем 0, но можно добавить поворот, если нужно
  }







  void _addUserPointer() async {
    final pointerPosition =
    vector.Vector3(0, -0.5, -1); // Указатель пользователя перед камерой

    userPointer = ARNode(
      type: NodeType.webGLB,
      uri:
      "http://127.0.0.1:8080/arrow.glb", // 3D модель указателя пользователя
      scale: vector.Vector3(0.1, 0.1, 0.1),
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
    final vector.Vector3 newPointerPosition =
        cameraPosition + cameraPose.getRotation().transformed(pointerOffset);

    userPointer!.position = newPointerPosition;

// Обновляем стрелку между текущей и следующей точкой
    if (currentTargetIndex < widget.routePoints.length) {
      vector.Vector3 targetPosition =
          widget.routePoints[currentTargetIndex].position;
      vector.Vector3? nextPosition;

      if (currentTargetIndex + 1 < widget.routePoints.length) {
        nextPosition = widget.routePoints[currentTargetIndex + 1].position;
      }

      _updateRouteArrow(targetPosition, nextPosition, cameraPosition);
    }
  }

  void _updateRouteArrow(vector.Vector3 targetPosition,
      vector.Vector3? nextPosition, vector.Vector3 cameraPosition) async {
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
      if (currentTargetIndex < widget.routePoints.length) {
        currentStep = widget.routePoints[currentTargetIndex].stepDescription!;
      } else {
        currentStep = "Маршрут завершён!";
        isOffRoute = false;
      }
    });
  }
}