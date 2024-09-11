import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async'; // Import for Timer

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true; // Flag to control scanning
  Timer? _pauseTimer; // Timer for pausing the scanner
  int _secondsRemaining = 3; // Seconds remaining for the pause
  bool _hasScanned = false; // Flag to track if a QR code has been scanned

  @override
  void dispose() {
    controller?.dispose();
    _pauseTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center( // Center the entire column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png', // Replace with your logo asset path
                width: 50,
                height: 50,
                color: Colors.white, // Set logo color to white
              ),
              SizedBox(height: 16),
              Text(
                'Отсканируйте\nкод сотрудника',
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 32), // Add spacing between text and scanner
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300, // Set the scanner's width
                    height: 200, // Set the scanner's height
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                  if (!isScanning)
                    Container(
                      width: 300,
                      height: 200,
                      color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                      child: Center(
                        child: Text(
                          _secondsRemaining.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  CustomPaint(
                    size: Size(300, 200), // Set the size of the custom painter to match the scanner
                    painter: CornerPainter(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_hasScanned) {
        _hasScanned = true; // Set the flag to indicate a scan has occurred
        // Pause scanning for 3 seconds
        setState(() {
          isScanning = false;
          _secondsRemaining = 3;
        });
        _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsRemaining--;
            if (_secondsRemaining == 0) {
              timer.cancel();
              // Resume scanning after 3 seconds
              setState(() {
                isScanning = true;
              });
              controller.resumeCamera();
            }
          });
        });
      }
    });
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw the corners
    canvas.drawLine(Offset(0, 0), Offset(20, 0), paint); // Top left
    canvas.drawLine(Offset(0, 0), Offset(0, 20), paint); // Top left
    canvas.drawLine(Offset(size.width - 20, 0), Offset(size.width, 0), paint); // Top right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 20), paint); // Top right
    canvas.drawLine(Offset(0, size.height - 20), Offset(0, size.height), paint); // Bottom left
    canvas.drawLine(Offset(0, size.height), Offset(20, size.height), paint); // Bottom left
    canvas.drawLine(Offset(size.width - 20, size.height), Offset(size.width, size.height), paint); // Bottom right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - 20), paint); // Bottom right
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}