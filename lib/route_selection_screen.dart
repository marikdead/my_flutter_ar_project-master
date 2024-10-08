import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'enviromental/ar_object_data.dart';
import 'enviromental/ar_route_points.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'ARScreen.dart';

class RouteSelectionScreen extends StatefulWidget {
  @override
  _RouteSelectionScreenState createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  ARObjectData? startPoint;
  ARObjectData? endPoint;
  List<ARObjectData> shortestPath = [];
  bool debugMode = false;
  List<String> debugLogs = [];
  ARObjectData? scannedPoint;
  QRViewController? qrController;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _selectStartPoint(ARObjectData point) {
    setState(() {
      startPoint = point;
      endPoint = null;
      shortestPath.clear();
      debugLogs.clear();
    });
  }

  void _selectEndPoint(ARObjectData point) {
    setState(() {
      endPoint = point;
      shortestPath = findShortestPath(
        startPoint!,
        endPoint!,
        log: (String message) {
          if (debugMode) {
            setState(() {
              debugLogs.add(message);
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Выбор маршрута"),
        backgroundColor: Colors.blueAccent,
        actions: [
          Switch(
            value: debugMode,
            onChanged: (value) {
              setState(() {
                debugMode = value;
                debugLogs.clear();
              });
            },
            activeColor: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Начальная точка", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showQRScannerDialog(isStartPoint: true),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text(
                          startPoint?.name ?? "Выберите начальную точку",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            if (startPoint != null) ...[
              SizedBox(height: 30),
              Text("Конечная точка", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showPointSelectionDialog(isStartPoint: false),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            endPoint?.name ?? "Выберите конечную точку",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.green),
                    ],
                  ),
                ),
              ),
            ],
            Spacer(),
            if (startPoint != null && endPoint != null) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRoutePreview();
                  },
                  icon: Icon(Icons.visibility, size: 28),
                  label: Text(
                    "Показать маршрут",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AREnvironmentScreen(
                          routePoints: shortestPath,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.directions, size: 28),
                  label: Text(
                    "Построить маршрут",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            if (debugMode) ...[
              SizedBox(height: 20),
              Text("Логи отладки:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: debugLogs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(debugLogs[index]),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQRScannerDialog({required bool isStartPoint}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Используем StatefulBuilder для локального обновления состояния диалога
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text("Сканирование QR-кода"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    child: QRView(
                      key: GlobalKey(debugLabel: 'QR'),
                      onQRViewCreated: (QRViewController controller) {
                        this.qrController = controller;
                        controller.scannedDataStream
                            .asBroadcastStream()
                            .listen((scanData) {
                          ARObjectData? matchedPoint = arRoutePoints.firstWhere(
                                (point) => point.qrCode == scanData.code,
                            orElse: () => ARObjectData(
                                id: '',
                                name: '',
                                qrCode: '',
                                position: vector.Vector3.zero(),
                                modelUri: ''
                            ),
                          );

                          if (matchedPoint.name.isNotEmpty) {
                            setModalState(() { // Локальное обновление состояния диалога
                              scannedPoint = matchedPoint;
                            });
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  if (scannedPoint != null && scannedPoint!.name.isNotEmpty)
                    Text(
                      "Отсканированная точка: ${scannedPoint!.name}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  else
                    Text("Сканируйте QR-код"),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: (scannedPoint != null && scannedPoint!.name.isNotEmpty)
                      ? () {
                    Navigator.of(context).pop();
                    if (isStartPoint) {
                      _selectStartPoint(scannedPoint!);
                    } else {
                      _selectEndPoint(scannedPoint!);
                    }
                  }
                      : null,
                  child: Text("Выбрать точку"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Отмена"),
                ),
              ],
            );
          },
        );
      },
    );
  }







  void _showPointSelectionDialog({required bool isStartPoint}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<ARObjectData> pointsToShow = arRoutePoints;
        if (!isStartPoint && startPoint != null) {
          pointsToShow = pointsToShow.where((point) => point != startPoint).toList();
        }

        return AlertDialog(
          title: Text(isStartPoint ? "Выберите начальную точку" : "Выберите конечную точку"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pointsToShow.map((point) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (isStartPoint) {
                      _selectStartPoint(point);
                    } else {
                      _selectEndPoint(point);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isStartPoint ? Icons.location_on : Icons.flag,
                          color: isStartPoint ? Colors.blueAccent : Colors.green,
                        ),
                        SizedBox(height: 5),
                        Text(
                          point.name,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showRoutePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Предварительный просмотр маршрута"),
          content: SingleChildScrollView(
            child: Column(
              children: shortestPath.asMap().entries.map((entry) {
                int index = entry.key;
                ARObjectData point = entry.value;

                // Следующая точка, если это не последняя точка
                ARObjectData? nextPoint = index < shortestPath.length - 1
                    ? shortestPath[index + 1]
                    : null;

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blueAccent),
                      title: Text("${index + 1}. ${point.name}"),
                      // Если это не последняя точка, показываем шаг до следующей точки
                      subtitle: nextPoint != null
                          ? Text("${nextPoint.stepDescription}")
                          : null,
                    ),
                    if (nextPoint != null) // Если есть следующая точка, показываем стрелку вниз
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.blueAccent),
                          ),
                          Icon(Icons.arrow_downward, color: Colors.blueAccent),
                          Expanded(
                            child: Divider(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }




}
