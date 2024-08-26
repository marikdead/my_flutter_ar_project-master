import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vectorMath;

class MyArPage extends StatefulWidget {
  const MyArPage({super.key});

  @override
  _MyArPageState createState() => _MyArPageState();
}

class _MyArPageState extends State<MyArPage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  String displayMessage = "Нажмите на экран, чтобы разместить объект";
  ARHitTestResult? hitResult;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR зона'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      hitResult != null
                          ? 'Hit Result: ${hitResult!.worldTransform.getColumn(3).x}, ${hitResult!.worldTransform.getColumn(3).y}, ${hitResult!.worldTransform.getColumn(3).z}'
                          : 'Hit Result: None',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager,
      ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      showAnimatedGuide: false,
      handleTaps: true,
    );

    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = (List<ARHitTestResult> hitTestResults) async {
      setState(() {
        displayMessage = "Произошло касание!";
      });

      if (hitTestResults.isNotEmpty) {
        hitResult = hitTestResults.first;

        print("Hit detected at position: ${hitResult!.worldTransform.getColumn(3)}");

        final newNode = ARNode(
          type: NodeType.webGLB,
          uri: "https://jla.ovh/glb-jla.glb",
          scale: vectorMath.Vector3(0.3, 0.3, 0.3),
          position: vectorMath.Vector3(
            hitResult!.worldTransform.getColumn(3).x,
            hitResult!.worldTransform.getColumn(3).y + 0.2,
            hitResult!.worldTransform.getColumn(3).z,
          ),
          rotation: vectorMath.Vector4(0, 1, 0, 0),
        );

        bool didAddNode = (await arObjectManager!.addNode(newNode)) ?? false;
        if (didAddNode) {
          setState(() {
            displayMessage = "Объект успешно добавлен!";
          });
        } else {
          setState(() {
            displayMessage = "Не удалось добавить объект.";
          });
        }
      } else {
        setState(() {
          displayMessage = "Не удалось найти поверхность для размещения.";
        });
      }
    };
  }
}
