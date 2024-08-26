import 'package:flutter/material.dart';
import 'package:my_flutter_ar_project/route_selection_screen.dart';
import 'ARScreen.dart';
import 'ar_image_anchor.dart';
import 'just_object_in_space.dart';
import 'my_ar_page.dart';
import 'duck_example.dart';
import 'local_and_web_objects.dart';
import 'qr_scanner_page.dart';
import 'list_page.dart';
import 'ar_page.dart';
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const MyHomePage(title: 'QR Code Scanner Home Page'),
        '/listPage': (context) => const ListPage(),
        '/arCameraPage': (context) => ArCameraPage(),
        '/myAr': (context) => MyArPage(),
        '/localObj': (context) => LocalAndWebObjectsWidget(),
        '/duck': (context) => ObjectGesturesWidget(),
        '/JustObject': (context) => JustObject(),
        '/ArImage': (context) => ArImage(),
        '/ArScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, ARObjectData>;
          return AREnvironmentScreen(
            startPoint: args['startPoint'] as ARObjectData,
            endPoint: args['endPoint'] as ARObjectData,
          );
        },
        '/routeSelection': (context) => RouteSelectionScreen(),
      },
    );
  }
}
