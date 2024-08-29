import 'package:flutter/material.dart';
import 'ARScreen.dart';
import 'enviromental/ar_route_points.dart';
import 'enviromental/ar_object_data.dart';

class RouteSelectionScreen extends StatefulWidget {
  @override
  _RouteSelectionScreenState createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  ARObjectData? startPoint;
  ARObjectData? endPoint;
  List<ARObjectData> shortestPath = [];
  bool debugMode = false; // Переключатель режима отладки
  List<String> debugLogs = []; // Логи для режима отладки

  void _selectStartPoint(ARObjectData point) {
    setState(() {
      startPoint = point;
      endPoint = null; // Сбрасываем конечную точку при выборе новой начальной
      shortestPath.clear(); // Очищаем путь при изменении начальной точки
      debugLogs.clear(); // Очищаем логи
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
                debugLogs.clear(); // Очищаем логи при смене режима
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
            InkWell(
              onTap: () => _showPointSelectionDialog(isStartPoint: true),
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
              InkWell(
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
                    _showRoutePreview(); // Показать маршрут
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
              SizedBox(height: 10), // Отступ между кнопками
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Переход на экран с указаниями (AREnvironmentScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AREnvironmentScreen(
                          routePoints: shortestPath, // Передаем найденный маршрут
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
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: pointsToShow.length,
              itemBuilder: (context, index) {
                final point = pointsToShow[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (isStartPoint) {
                      _selectStartPoint(point);
                    } else {
                      _selectEndPoint(point);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isStartPoint ? Colors.blueAccent : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      point.name,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Маршрут"),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: shortestPath.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(shortestPath[index].name),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
