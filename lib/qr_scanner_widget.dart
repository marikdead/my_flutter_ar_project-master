import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool qrScanned = false;
  bool canScan = true;
  String scannedText = '';
  static const String correctQrCode = "Authentification QR token";

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    qrScanned = false;
    canScan = true;
    scannedText = '';
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (canScan) {
        setState(() {
          scannedText = scanData.code!;
        });
        if (scanData.code == correctQrCode) {
          qrScanned = true;
          canScan = false;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
                Navigator.pushNamed(context, '/listPage').then((_) {
                  setState(() {
                    qrScanned = false;
                    canScan = true;
                    scannedText = '';
                  });
                });
              });
              return AlertDialog(
                title: const Text('Добро пожаловать'),
              );
            },
          );
        } else {
          setState(() {
            canScan = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Неверный QR код')),
          );
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            canScan = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
