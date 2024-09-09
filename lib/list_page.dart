import 'package:flutter/material.dart';

class ButtonConfig {
  final String title;
  final VoidCallback onPressed;

  ButtonConfig({required this.title, required this.onPressed});
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {'name': 'Перемещение 1', 'description': 'Контрагент 1'},
      {'name': 'Перемещение 2', 'description': 'Контрагент 1'},
      {'name': 'Перемещение 3', 'description': 'Контрагент 3'},
      {'name': 'Перемещение 4', 'description': 'Контрагент 4'},
      {'name': 'Перемещение 5', 'description': 'Контрагент 5'},
      {'name': 'Перемещение 6', 'description': 'Контрагент 6'},
      {'name': 'Перемещение 7', 'description': 'Контрагент 7'},
      {'name': 'Перемещение 8', 'description': 'Контрагент 8'},
      {'name': 'Перемещение 9', 'description': 'Контрагент 9'},
      {'name': 'Перемещение 10', 'description': 'Контрагент 10'},
      {'name': 'Перемещение 11', 'description': 'Контрагент 11'},
      {'name': 'Перемещение 12', 'description': 'Контрагент 12'}
    ];

    final List<ButtonConfig> buttonConfigs = [
      ButtonConfig(
        title: 'Экран выбора маршрута',
        onPressed: () {
          Navigator.pushNamed(context, '/routeSelection');
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список задач'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['description']!,
                        style: const TextStyle(
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isExpanded ? buttonConfigs.length * 60.0 + 20.0 : 0,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        children: buttonConfigs.map((config) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: config.onPressed,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(config.title),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    icon: Icon(_isExpanded ? Icons.close : Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
