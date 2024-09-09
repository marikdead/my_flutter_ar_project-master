import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // Center the entire content
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Align elements to the top
            children: <Widget>[
              Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    'SKLADAR',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30), // Space between title and description
              Text(
                "АВТОМАТИЗАЦИЯ\nВНУТРИСКЛАДСКИХ\nОПЕРАЦИЙ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 70),// Push the button to the bottom
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Авторизоваться'),
              ),
              SizedBox(height: 20), // Add space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}