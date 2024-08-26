import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

class JustObject extends StatefulWidget {
  const JustObject({super.key});

  @override
  _JustObjectState createState() => _JustObjectState();
}

class _JustObjectState extends State<JustObject> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARNode? arrowNode;

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
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: onPlaceObjectButtonPressed,
              child: const Text('Разместить 3D объект'),
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
      showWorldOrigin: false,
      showAnimatedGuide: false,
      handleTaps: false,
    );
    this.arObjectManager!.onInitialize();
  }

  Future<void> onPlaceObjectButtonPressed() async {
    if (arObjectManager != null) {
      final newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "assets/arrow.glb",
        scale: Vector3(0.5, 0.5, 0.5),
        position: Vector3(0.0, -0.2, -1.0),
      );


      bool? didAddNode = await arObjectManager!.addNode(newNode);
      if (didAddNode!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Объект размещен и будет следовать за пользователем'),
          ),
        );
        setState(() {
          arrowNode = newNode;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось разместить объект'),
          ),
        );
      }
    }
  }
}
