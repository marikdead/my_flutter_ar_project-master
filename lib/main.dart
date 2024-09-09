import 'package:flutter/material.dart';
import 'package:my_flutter_ar_project/route_selection_screen.dart';
import 'ARScreen.dart';
import 'login_screen.dart';
import 'qr_scanner_page.dart';
import 'enviromental/ar_object_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => const MyHomePage(title: 'QR Code Scanner Home Page'),
        '/ArScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AREnvironmentScreen(
            routePoints: args['routePoints'] as List<ARObjectData>,
          );
        },
        '/routeSelection': (context) => RouteSelectionScreen(),
      },
    );
  }
}
