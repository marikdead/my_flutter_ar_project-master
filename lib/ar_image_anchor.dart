import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vector_math/vector_math_64.dart' as vectorMath;
import 'dart:async';

class ArImage extends StatefulWidget {
  const ArImage({super.key});

  @override
  _ArImageState createState() => _ArImageState();
}

class _ArImageState extends State<ArImage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  String? scannedQRCode;
  String statusMessage = "Ожидание сканирования QR-кода...";
  MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  Timer? scannerTimer;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScanningCycle();
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    cameraController.dispose();
    scannerTimer?.cancel();
    super.dispose();
  }


  void _startScanningCycle() {
    scannerTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      _startScanning();
      await Future.delayed(const Duration(seconds: 5));
      _stopScanning();
    });
  }


  void _startScanning() {
    setState(() {
      isScanning = true;
      cameraController.start();
      statusMessage = "Сканирование QR-кода...";
    });
  }


  void _stopScanning() {
    setState(() {
      isScanning = false;
      cameraController.stop();
      statusMessage = "Сканирование остановлено, ожидание...";
    });
  }


  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager,
      ) {
    _initializeARManagers(arSessionManager, arObjectManager, arAnchorManager);
  }


  void _initializeARManagers(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      handleTaps: false,
    );

    arObjectManager?.onInitialize();

    print("AR Session Manager initialized");
  }


  void _onQRCodeDetected(BarcodeCapture barcodeCapture) {
    final Barcode? barcode = barcodeCapture.barcodes.isNotEmpty ? barcodeCapture.barcodes.first : null;
    final String? code = barcode?.rawValue;

    setState(() {
      scannedCode = code;
      if (code != null && code == '3D OBJECT HERE') {
        scannedQRCode = code;
        statusMessage = "QR-код обнаружен, добавление 3D-объекта...";
        _add3DObject();
      } else {
        statusMessage = "QR-код не соответствует ожидаемому значению.";
      }
    });
  }


  Future<void> _add3DObject() async {
    if (arObjectManager == null) {
      print("ARObjectManager is not initialized");
      setState(() {
        statusMessage = "Ошибка инициализации AR-менеджера.";
      });
      return;
    }

    final node = ARNode(
      type: NodeType.webGLB,
      uri: "https://jla.ovh/glb-jla.glb",
      scale: vectorMath.Vector3(0.3, 0.3, 0.3),
      position: vectorMath.Vector3(0.0, 0.0, -0.5),
      rotation: vectorMath.Vector4(0, 1, 0, 0),
    );

    bool didAddNode = (await arObjectManager!.addNode(node)) ?? false;
    if (didAddNode) {
      setState(() {
        statusMessage = "Объект успешно добавлен!";
      });
    } else {
      setState(() {
        statusMessage = "Не удалось добавить объект.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR зона'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          if (isScanning)
            MobileScanner(
              controller: cameraController,
              onDetect: _onQRCodeDetected,
            ),
          _buildStatusOverlay(),
          _buildScannedCodeOverlay(),
        ],
      ),
    );
  }


  Positioned _buildStatusOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          statusMessage,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  Positioned _buildScannedCodeOverlay() {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          scannedCode ?? "Сканируем QR-код...",
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
