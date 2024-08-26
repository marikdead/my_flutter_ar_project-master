import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';

class ArCameraPage extends StatefulWidget {
  ArCameraPage({Key? key}) : super(key: key);
  @override
  _ArCameraPageState createState() => _ArCameraPageState();
}

class _ArCameraPageState extends State<ArCameraPage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  bool _showFeaturePoints = false;
  bool _showPlanes = false;
  bool _showWorldOrigin = false;
  bool _showAnimatedGuide = true;
  String _planeTexturePath = "Images/triangle.png";
  bool _handleTaps = false;

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
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
        body: Container(
            child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
                showPlatformType: false,
              ),
              Align(
                alignment: FractionalOffset.bottomRight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Color(0xFFFFFFF).withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text('Feature Points'),
                        value: _showFeaturePoints,
                        onChanged: (bool value) {
                          setState(() {
                            _showFeaturePoints = value;
                            updateSessionSettings();
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Planes'),
                        value: _showPlanes,
                        onChanged: (bool value) {
                          setState(() {
                            _showPlanes = value;
                            updateSessionSettings();
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('World Origin'),
                        value: _showWorldOrigin,
                        onChanged: (bool value) {
                          setState(() {
                            _showWorldOrigin = value;
                            updateSessionSettings();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: _showFeaturePoints,
      showPlanes: _showPlanes,
      customPlaneTexturePath: _planeTexturePath,
      showWorldOrigin: _showWorldOrigin,
      showAnimatedGuide: _showAnimatedGuide,
      handleTaps: _handleTaps,
    );
    this.arObjectManager!.onInitialize();
  }

  void updateSessionSettings() {
    this.arSessionManager!.onInitialize(
      showFeaturePoints: _showFeaturePoints,
      showPlanes: _showPlanes,
      customPlaneTexturePath: _planeTexturePath,
      showWorldOrigin: _showWorldOrigin,
    );
  }
}